#!/usr/bin/env bash

set -eo pipefail

mqtt_host="${1:?"Missing MQTT-broker hostname!"}"
samples="${2:-3}"

while true; do

  signal=0
  snr=0

  while IFS= read -r line; do

    if [[ ! $line =~ ^('FE:'|'status')\  ]]; then
      echo 'Invalid femon output!'
      exit 1
    fi

    if [[ $line =~ 'signal'\ +([0-9]{1,3})'%' ]]; then
      signal=$((signal + BASH_REMATCH[1]))
    fi

    if [[ $line =~ 'snr'\ +([0-9]{1,3})'%' ]]; then
      snr=$((snr + BASH_REMATCH[1]))
    fi

  done < <(femon -H -c "$samples")

  # Integer arithmetic suffices...
  signal=$((signal / samples))
  snr=$((snr / samples))

  mosquitto_pub -h "$mqtt_host" -t "femon/signal" -m "$signal"
  mosquitto_pub -h "$mqtt_host" -t "femon/snr" -m "$snr"

  sleep 1m

done
