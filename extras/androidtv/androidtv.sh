#!/usr/bin/env bash

set -eo pipefail

device="${1:?"Missing AndroidTV device!"}"

while true; do

  adb connect "$device:5555"
  sleep 30s &
  wait $!

done
