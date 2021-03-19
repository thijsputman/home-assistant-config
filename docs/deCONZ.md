# deCONZ (Phoscon ConBee II)

- [Device-compatibility](#device-compatibility)
  - [Xiaomi Mi Smart Plug (`lumi.plug.mmeu01`)](#xiaomi-mi-smart-plug-lumiplugmmeu01)
  - [BlitzWolf Smart Socket (`TS0121`)](#blitzwolf-smart-socket-ts0121)

As a general caution, if Zigbee-entities become `unavailable` after restarting
deCONZ (without restarting Home Assistant), **_reload_** the integration before
trying anything else...

## Device-compatibility

### Xiaomi Mi Smart Plug (`lumi.plug.mmeu01`)

Once paired, it works as intended with deCONZ 2.9.2 (February 2021) or above –
including the power consumption measurements.

Pairing is a bit of hassle though:

It appears (through limited testing) to work best if the plug is drawing power
while being paired (i.e. switch on the device connected to the plug). If pairing
is successful, one "light" and two senors (`power` and `consumption`) should
appear. You can see the "light" in the Phoscon App, the sensors can be retrieved
from the REST API. It might take a couple minutes for the sensors to start
reporting (sensible) measurements.

If no sensors appear _or_ they appear not to be reporting sensible data _or_
they appear multiple times:

Delete the "light" via the Phoscon App and delete all remaining sensors via the
REST API and try again.

Multiple attempts might be required.

**N.B.** This appears to be somewhat of a generic issue – sensor entities
getting left behind after removing certain devices. Similar instructions might
apply to both related and unrelated device-types.

Reference:

- <https://github.com/dresden-elektronik/deconz-rest-plugin/issues/4238#issuecomment-774679112>
- <https://github.com/dresden-elektronik/deconz-rest-plugin/issues/2583>

### BlitzWolf Smart Socket (`TS0121`)

This unit appears (again, through limited testing) has similar problems as the
[Xiaomi unit](#xiaomi-mi-smart-plug-lumiplugmmeu01) – different instructions
apply though:

> Resetting the device (initializing pairing sequence by holding power button
> for more than 5 seconds) while having pairing mode/sensor search active in
> Phoscon some kind of "re-joined" the plug to the ConBee/ZigBee mesh.

Reference:

- <https://github.com/dresden-elektronik/deconz-rest-plugin/issues/2988#issuecomment-791972997>
