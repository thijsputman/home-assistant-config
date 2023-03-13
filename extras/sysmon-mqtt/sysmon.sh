#!/usr/bin/env bash

set -eo pipefail

# Defaults for optional settings (from global environment)

: "${SYSMON_HA_DISCOVER:=true}"
: "${SYSMON_INTERVAL:=30s}"

# Positional parameters

mqtt_host="${1:?"Missing MQTT-broker hostname!"}"
device_raw="${2:?"Missing device name!"}"

# Test the broker (assumes Mosquitto) — exits on failure
mosquitto_sub -C 1 -h "$mqtt_host" -t \$SYS/broker/version

device=$(echo "${device_raw//[^A-Za-z0-9_]/}" | tr '[:upper:]' '[:lower:]')
if [ -z "$device" ] ; then
  echo "Invalid device name '$device_raw'!" ; exit 1
fi

ha_discover(){

  local name=${1}
  local attribute=${2}
  local unit=${3}
  local class_icon=${4}

  # Attempt to retrieve existing UUID; otherwise generate a new one

  if config=$(mosquitto_sub -h "$mqtt_host" -C 1 -W 3 \
    -t "homeassistant/sensor/sysmon/${device}_${attribute}/config" \
    2> /dev/null) ; then
    unique_id=$(echo "$config" | jq -r -c '.unique_id')
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
			"name": "$name",
			"object_id": "${device}_${attribute}",
			"unique_id": "$unique_id",
			$class_icon_property
			"state_topic": "sysmon/$device/state",
			"unit_of_measurement": "$unit",
			"value_template":
				"{{ (value_json.$attribute | float(0)) | round(2) }}",
			"availability": {
				"topic": "sysmon/$device/connected",
				"payload_available": "1",
				"payload_not_available": "0"
			}
		}
		EOF
  ) # N.B., Use tabs instead of spaces!

  mosquitto_pub -r -q 1 -h "$mqtt_host" \
    -t "homeassistant/sensor/sysmon/${device}_${attribute}/config" \
    -m "$payload" || true
}

if [ "$SYSMON_HA_DISCOVER" == true ] ; then

  ha_discover 'CPU temperature' cpu_temp '°C' temperature
  ha_discover 'CPU load' cpu_load '%' 'mdi:chip'
  ha_discover 'Memory usage' mem_used '%' 'mdi:memory'

fi

mosquitto_pub -r -q 1 -h "$mqtt_host" \
  -t "sysmon/$device/connected" -m 1 || true

trap goodbye INT HUP TERM EXIT

goodbye(){
  rc="$?"
  mosquitto_pub -r -q 1 -h "$mqtt_host" \
    -t "sysmon/$device/connected" -m 0 || true
  # Reset EXIT-trap to prevent running twice (due to "set -e")
  trap - EXIT
  exit "$rc"
}

cpu_cores=$(nproc --all)

while true; do

  # CPU temperature
  cpu_temp=$(awk '{printf "%3.2f", $0/1000 }' < \
    /sys/class/thermal/thermal_zone0/temp)

  # Load (1-minute load / # of cores)
  cpu_load=$(uptime | \
    awk "match(\$0, /load average: ([0-9\.]*),/, \
      result){printf \"%3.2f\", result[1]*100/$cpu_cores}")

  # Memory usage (1 - total / available)
  mem_used=$(free | awk 'NR==2{printf "%3.2f", (1-($7/$2))*100 }')

  payload=$(tr -s ' ' <<- EOF
		{
			"cpu_temp": "$cpu_temp",
			"cpu_load": "$cpu_load",
			"mem_used": "$mem_used"
		}
		EOF
  ) # N.B., Tabs instead of spaces!

  mosquitto_pub -h "$mqtt_host" \
    -t "sysmon/$device/state" -m "$payload" || true

  sleep "$SYSMON_INTERVAL" &
  wait $!

done
