#!/usr/bin/env bash

# Gave up on trying to get snmpwalk to work properly; the below only returns
# when retrieved through snmpget – something to solve another time...

if [ "$1" = "-g" ] && [ "$2" = ".1.3.6.1.4.1.8072.9999.9999.314.1" ] ; then
  echo .1.3.6.1.4.1.8072.9999.9999.314.1
  echo gauge
  cat /sys/class/thermal/thermal_zone0/temp
fi
