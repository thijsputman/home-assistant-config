#!/usr/bin/env sh

set -e

mqtt_host="${1:?"Missing MQTT-broker hostname!"}"
mqtt_topic="${2:?"Missing MQTT-topic!"}"
ping_host="${3:-8.8.8.8}"
count="${4:-4}"

# Ensure single instance of the script
if [ -f /tmp/ping2mqtt.lock ] ; then
  exit 69
fi

# Store lock-file in /tmp (non-persistent storage). The script is executed upon
# "wanup" (WAN up), which can happen any number of times while the device is
# running. The lock-file prevents spawning an infinite number of scripts.
touch /tmp/ping2mqtt.lock

while true; do

  # Idea courtesy of https://stackoverflow.com/a/59353917. Word-splitting is
  # required for this to work; hence the disabled ShellCheck warning...
  # shellcheck disable=SC2046
  set -- $(ping -c "$count" "$ping_host" | \
    grep round-trip | grep -oE "[[:digit:]]+\.[[:digit:]]{3}")

  mosquitto_pub -h "$mqtt_host" -t "$mqtt_topic" -m "$2"

  sleep 1m

done
