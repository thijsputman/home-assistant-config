#!/usr/bin/env bash

set -eo pipefail

mqtt_host="${1:?"Missing MQTT-broker hostname!"}"
device="${2:?"Missing device name!"}"

mqtt_register(){

  local name=${1}
  local attribute=${2}
  local unit=${3}
  local class_icon=${4}

  if config=$(mosquitto_sub -h "$mqtt_host" -C 1 -W 3 \
    -t "homeassistant/sensor/sysmon_${device}_${attribute}/config" \
    2> /dev/null) ; then
    unique_id=$(echo "$config" | jq -r -c '.unique_id')
  else
    unique_id=""
  fi

  if [[ "$unique_id" =~ ^[0-9a-z-]{36}$ ]] ; then
    unique_id="\"unique_id\": \"$unique_id\","
  else
    unique_id="\"unique_id\": \"$(cat /proc/sys/kernel/random/uuid)\","
  fi

  if [ -n "$class_icon" ] ; then
    if [[ "$class_icon" =~ ^mdi: ]] ; then
      class_icon="\"icon\": \"$class_icon\","
    else
      class_icon="\"device_class\": \"$class_icon\","
    fi
  else
    class_icon=""
  fi

  local payload
  payload=$(tr -s ' ' <<- EOF
		{
			"name": "$name",
			"object_id": "${device}_${attribute}",
			$unique_id
			$class_icon
			"state_topic": "homeassistant/sensor/sysmon_${device}/state",
			"unit_of_measurement": "$unit",
			"value_template":
				"{{ (value_json.$attribute | int(0)) / 100 | round(2) }}",
			"availability": {
				"topic": "sysmon/$device/connected",
				"payload_available": "1",
				"payload_not_available": "0"
			}
		}
		EOF
  ) # N.B., Use tabs instead of spaces!

  mosquitto_pub -r -h "$mqtt_host" \
    -t "homeassistant/sensor/sysmon_${device}_${attribute}/config" \
    -m "$payload" || true
}

# Test the broker (assumes Mosquitto)
mosquitto_sub -h "$mqtt_host" -C 1 -t \$SYS/broker/version

mqtt_register 'CPU temperature' cpu_temp '°C' temperature
mqtt_register 'CPU load' cpu_load '%' 'mdi:chip'
mqtt_register 'Memory usage' mem_used '%' 'mdi:memory'

mosquitto_pub -r -h "$mqtt_host" -t "sysmon/$device/connected" -m 1 || true

trap goodbye INT HUP TERM EXIT

goodbye(){
  rc="$?"
  mosquitto_pub -r -h "$mqtt_host" -t "sysmon/$device/connected" -m 0 || true
  # Reset EXIT-trap to prevent running twice (due to "set -e")
  trap - EXIT
  exit "$rc"
}

cpu_cores=$(nproc --all)

while true; do

  # CPU temperature
  cpu_temp=$(awk '{printf "%d", $0/10 }' < \
    /sys/class/thermal/thermal_zone0/temp)

  # Load (1-minute load / # of cores)
  cpu_load=$(uptime | \
    awk "match(\$0, /load average: ([0-9\.]*),/, \
      result){printf \"%d\", result[1]*10000/$cpu_cores}")

  # Memory usage (1 - total / available)
  mem_used=$(free | awk 'NR==2{printf "%d", (1-($7/$2))*10000 }')

  payload=$(tr -s ' ' <<- EOF
		{
			"cpu_temp": "$cpu_temp",
			"cpu_load": "$cpu_load",
			"mem_used": "$mem_used"
		}
		EOF
  ) # N.B., Tabs instead of spaces!

  mosquitto_pub -h "$mqtt_host" \
    -t "homeassistant/sensor/sysmon_$device/state" -m "$payload" || true

  sleep 30s &
  wait $!

done
