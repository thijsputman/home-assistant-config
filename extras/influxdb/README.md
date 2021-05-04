# InfluxDB scratch-pad

## Changes / Notes

- **14-4-2021 @ 11:15 CET** – replaced `power_dishwasher_actual` with
  `power_88_actual` (as the former sensor got deleted). The measurements
  communicated should remain (broadly) unchanged (i.e. comparable).
- **27-4-2021 @ 06:00 CET** – measurements for `sensor.power_88_actual` and
  `sensor.power_86_actual` are missing due to
  [an odd issue with the Zigbee-network](../deconz/README.md#incident-april-2021)
  (resolved 1-5-2021 @ 19:30 CET)
- **4-5-2021 17:30 CET** – the value for `sensor.power_lights_all` now also
  includes the stand-by consumption of all Zigbee bulbs
