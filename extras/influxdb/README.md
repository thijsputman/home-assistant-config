# InfluxDB Notebooks

Using the
[Node.js Notebooks](https://marketplace.visualstudio.com/items?itemName=donjayamanne.typescript-notebook)
VS Code extension.

Before attempting to use the notebooks, ensure you install their dependencies:

```shell
cd extras/influxdb
npm install
```

## Changes / Notes

- **14-4-2021 @ 11:15 CET** – replaced `power_dishwasher_actual` with
  `power_88_actual` (as the former sensor got deleted). The measurements
  communicated should remain (broadly) unchanged (i.e. comparable)
- **27-4-2021 @ 06:00 CET** – measurements for `sensor.power_88_actual` and
  `sensor.power_86_actual` are missing due to
  [an odd issue with the Zigbee-network](../../docs/deCONZ.md#ikea-tradfri-repeater-april-2021)
  (resolved on 1-5-2021 @ 19:30 CET)
- **4-5-2021 @ 17:30 CET** – the value for `sensor.power_lights_all` now also
  includes the stand-by consumption of all Zigbee bulbs
- **14-7-2021 @ 16:00 CET** – added `sensor.gas_consumption` which should be
  preferred over the (still present) `sensor.hourly_gas_consumption` sensor.
  Home Assistant 2021.7
  [removed the hourly gas consumption reading from the DSMR integration](https://github.com/home-assistant/core/pull/52147);
  it was reintroduced using the Derivative integration. Until 19-7-2021 @ 16:00
  CET the values were computed differently (higher derivative over a shorter
  timespan) compared to the values as previously computed by the DSMR
  integration.
- **18-7-2021 @ 15:00 CET** – No data for `sensor.weewx_wind_speed` recorded due
  to a climbing plant getting in the way (resolved on 21-7-2021 @ 18:00 CET)
- **3-12-2021 @ 12:00 CET** - Renamed `sensor.ups_power` to
  `sensor.ups_power_usage`; renamed `sensor.power_lights_all` to
  `sensor.power_all_lights`
- **12-12-2021 @ 16:30 CET** – `sensor.power_sonair_combined` now also includes
  power consumption for the (exhaust) fan in the Attic
- **23-1-2022 @ 03:20 CET** – NVMe drive hosting the Home Assistant database
  detached/crashed; it appears all data came through regardless (recovered
  23-1-2022 @ 12:00 CET)
- **15-2-2022 @ 19:00 CET** – Reduced precision from `ns` to `s`; sub-second
  precision seems a bit overkill for what I have in mind (the most frequently
  updating sensors do so every 30 seconds)
- **5-5-2022 @ 03:00 CET** – Multi-sensor Attic (`sensor.temperature_3`) started
  intermittently reporting errant temperature values (-100 ºC). This coincided
  with an upgrade of deCONZ (which apparently suffered from a bug specifically
  effecting these multi-sensors). Nonetheless, after replacing the sensor's
  battery (around 11:00 CET that same day) the issue disappeared.
- **13-5-2022 @ 00:00 CET** – `sensor.dd_wrt_1_wan_in_mbps` and
  `sensor.dd_wrt_1_wan_out_mbps` became unavailable due to an issue with the
  SNMP integration. The underlying issue was fixed by upgrading Home Assistant
  to version 2022.5.5 on 20-5-2022 @ 06:00.
- **8-6-2022 @ 12:30 CET** – Internet connectivity was down until around 15:30
  CET; no data came through to Influx Cloud during that period.
- **8-6-2022 @ 21:00 CET** – Ping sensor on DD-WRT-1
  (`sensor.dd_wrt_1_google_dns_roundtrip_time`) was down until around 23:00 CET.
- **26-7-2022 @ 10:40 CET** – No data for `sensor.weewx_wind_speed` recorded due
  to the Wisteria getting in the way, again 😇 (resolved on 26-7-2022 @ 21:00
  CET)
