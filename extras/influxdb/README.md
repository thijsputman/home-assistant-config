# InfluxDB scratch-pad

## Changes / Notes

- **14-4-2021 @ 11:15 CET** – replaced `power_dishwasher_actual` with
  `power_88_actual` (as the former sensor got deleted). The measurements
  communicated should remain (broadly) unchanged (i.e. comparable)
- **27-4-2021 @ 06:00 CET** – measurements for `sensor.power_88_actual` and
  `sensor.power_86_actual` are missing due to
  [an odd issue with the Zigbee-network](../../docs/deCONZ.md#ikea-tradfri-repeater-april-2021)
  (resolved on 1-5-2021 @ 19:30 CET)
- **4-5-2021 17:30 CET** – the value for `sensor.power_lights_all` now also
  includes the stand-by consumption of all Zigbee bulbs
- **14-7-2021 16:00 CET** – added `sensor.gas_consumption` which should be
  preferred over the (still present) `sensor.hourly_gas_consumption` sensor.
  Home Assistant 2021.7
  [removed the hourly gas consumption reading from the DSMR integration](https://github.com/home-assistant/core/pull/52147);
  it was reintroduced using the Derivative integration. Until 19-7-2021 @ 16:00
  CET the values were computed differently (higher derivative over a shorter
  timespan) compared to the values as previously computed by the DSMR
  integration.
- **18-7-2021 15:00 CET** – No data for `sensor.weewx_wind_speed` recorded due
  to a climbing plant getting in the way (resolved on 21-7-2021 @ 18:00 CET)
- **3-12-2021 12:00 CET** - Renamed `sensor.ups_power` to
  `sensor.ups_power_usage`; renamed `sensor.power_lights_all` to
  `sensor.power_all_lights`
