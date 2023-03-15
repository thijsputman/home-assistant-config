#!/usr/bin/env bash

set -eo pipefail

# Defaults for optional settings (from global environment)

: "${SYSMON_HA_DISCOVER:=true}"
: "${SYSMON_HA_TOPIC:=homeassistant}"
: "${SYSMON_INTERVAL:=30}"

# Positional parameters

mqtt_host="${1:?"Missing MQTT-broker hostname!"}"
device_name="${2:?"Missing device name!"}"
read -r -a eth_adapters <<< "$3"

# Test the broker (assumes Mosquitto) — exits on failure
mosquitto_sub -C 1 -h "$mqtt_host" -t \$SYS/broker/version

# Clean parameters to be used in MQTT-topic names — reduce them to lowercase
# alphanumeric and underscores; exit if nothing remains

mqtt_clean(){

  param=$(echo "${1//[^A-Za-z0-9_ -]/}" |
    tr -s ' -' _ | tr '[:upper:]' '[:lower:]')

  if [ -z "$param" ] ; then
    echo "Invalid parameter '$1' supplied!" ; exit 1
  fi

  echo "$param"
}

device=$(mqtt_clean "$device_name")
ha_topic=$(mqtt_clean "$SYSMON_HA_TOPIC")

ha_discover(){

  local name=${1}
  local attribute=${2}
  local unit=${3}
  local class_icon=${4}

  # Attempt to retrieve existing UUID; otherwise generate a new one

  if config=$(mosquitto_sub -h "$mqtt_host" -C 1 -W 3 \
    -t "${ha_topic}/sensor/sysmon/${device}_${attribute//\//_}/config" \
    2> /dev/null) ; then
    unique_id=$(jq -r -c '.unique_id' <<< "$config" 2> /dev/null) \
      || true # This ensures invalid JSON-payloads are ignored
  else
    unique_id=""
  fi

  if ! [[ "$unique_id" =~ ^[0-9a-z-]{36}$ ]] ; then
    unique_id=$(cat /proc/sys/kernel/random/uuid)
  fi

  # Select between "icon" and "device_class"

  if [ -n "$class_icon" ] ; then
    if [[ "$class_icon" =~ ^mdi: ]] ; then
      class_icon_property="\"icon\": \"$class_icon\","
    else
      class_icon_property="\"device_class\": \"$class_icon\","
    fi
  else
    class_icon_property=""
  fi

  # Construct discovery-payload

  local payload
  payload=$(tr -s ' ' <<- EOF
    {
      "name": $(echo -n "$device_name $name" | jq -R -s '.'),
      "object_id": "${device}_${attribute//\//_}",
      "unique_id": "$unique_id",
      "device": {
          "identifiers": "sysmon_${device}",
          "name": $(echo -n "$device_name" | jq -R -s '.'),
          "manufacturer": "sysmon-mqtt"
      },
      $class_icon_property
      "state_topic": "sysmon/$device/state",
      "unit_of_measurement": "$unit",
      "value_template":
        "{{ (value_json.${attribute//\//.} | float(0)) | round(2) }}",
      "availability": {
        "topic": "sysmon/$device/connected",
        "payload_available": "1",
        "payload_not_available": "0"
      }
    }
		EOF
  ) # N.B., EOF-line should be indented with tabs!

  mosquitto_pub -r -q 1 -h "$mqtt_host" \
    -t "${ha_topic}/sensor/sysmon/${device}_${attribute//\//_}/config" \
    -m "$payload" || true
}

if [ "$SYSMON_HA_DISCOVER" == true ] ; then

  ha_discover 'CPU temperature' cpu_temp '°C' temperature
  ha_discover 'CPU load' cpu_load '%' 'mdi:chip'
  ha_discover 'Memory usage' mem_used '%' 'mdi:memory'

  for adapter in "${eth_adapters[@]}" ; do

    ha_discover "Bandwidth in (${adapter})" "bandwidth/${adapter}/rx" \
      'kbit/s' data_rate
    ha_discover "Bandwidth out (${adapter})" "bandwidth/${adapter}/tx" \
      'kbit/s' data_rate

  done

fi

trap goodbye INT HUP TERM EXIT

goodbye(){
  rc="$?"
  mosquitto_pub -r -q 1 -h "$mqtt_host" \
    -t "sysmon/$device/connected" -m 0 || true
  # Reset EXIT-trap to prevent running twice (due to "set -e")
  trap - EXIT
  exit "$rc"
}

_join() { local IFS="$1" ; shift ; echo "$*" ; }

cpu_cores=$(nproc --all)
rx_prev=() ; tx_prev=()
second_loop=false

while true ; do

  # CPU temperature
  cpu_temp=$(awk '{printf "%3.2f", $0/1000 }' < \
    /sys/class/thermal/thermal_zone0/temp)

  # Load (1-minute load / # of cores)
  cpu_load=$(uptime | \
    awk "match(\$0, /load average: ([0-9\.]*),/, \
      result){printf \"%3.2f\", result[1]*100/$cpu_cores}")

  # Memory usage (1 - total / available)
  mem_used=$(free | awk 'NR==2{printf "%3.2f", (1-($7/$2))*100 }')

  # Bandwith (in kbps; measured over the "sysmon interval")

  payload_bw=()

  for i in "${!eth_adapters[@]}" ; do

    adapter="${eth_adapters[i]}"

    # Attempt to strip $adapter down to a single path-component; exits if the
    # adapter doesn't exist
    rx=$(cat "/sys/class/net/${adapter%%/*}/statistics/rx_bytes")
    tx=$(cat "/sys/class/net/${adapter%%/*}/statistics/tx_bytes")

    # Only run when "prev" is initialised
    if [ "${#rx_prev[@]}" -eq "${#eth_adapters[@]}" ] ; then

      payload_bw+=("$(tr -s ' ' <<- EOF
        "$adapter": {
          "rx": "$(
            echo $(((rx-rx_prev[i])/10#$SYSMON_INTERVAL)) |
              awk '{printf "%.2f", $1*8/1000}'
            )",
          "tx": "$(
            echo $(((tx-tx_prev[i])/10#$SYSMON_INTERVAL)) |
              awk '{printf "%.2f", $1*8/1000}'
          )"
        }
				EOF
      )") # N.B., EOF-line should be indented with tabs!

    # Otherwise send an empty payload
    else printf -v payload_bw '"%s": {"rx": "0", "tx": "0"}' "$adapter" ; fi

    rx_prev[i]=$rx
    tx_prev[i]=$tx

  done

  payload=$(tr -s ' ' <<- EOF
    {
      "cpu_temp": "$cpu_temp",
      "cpu_load": "$cpu_load",
      "mem_used": "$mem_used",
      "bandwidth": {
        $(_join , "${payload_bw[@]}")
      }
    }
		EOF
  ) # N.B., EOF-line should be indented with tabs!

  mosquitto_pub -h "$mqtt_host" \
    -t "sysmon/$device/state" -m "$payload" || true

  # Publish "connected" after the _second_ payload is sent — this prevents
  # periodic metrics (e.g. bandwidth) from needlessly dropping to zero in Home
  # Assistant's graphs...

  if [ -v second_loop ] && [ "$second_loop" == true ] ; then

    mosquitto_pub -r -q 1 -h "$mqtt_host" \
      -t "sysmon/$device/connected" -m 1 || true
    unset second_loop

  elif [ -v second_loop ] ; then second_loop=true ; fi

  # Force $SYSMON_INTERVAL to base10; exits in case of invalid value
  sleep "$((10#$SYSMON_INTERVAL))s" &
  wait $!

done
