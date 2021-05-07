# deCONZ (Phoscon ConBee II)

- [Device-compatibility](#device-compatibility)
  - [Xiaomi Mi Smart Plug (`lumi.plug.mmeu01`)](#xiaomi-mi-smart-plug-lumiplugmmeu01)
  - [BlitzWolf Smart Socket (`TS0121`)](#blitzwolf-smart-socket-ts0121)
- [Timeline](#timeline)
  - [Incident April 2021](#incident-april-2021)

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

## Timeline

### Incident April 2021

An odd incident started on April 26 around 23:00: The `TRADFRI Signal Repeater`
dropped from the network (crashed?). Once power-cycled the device came back up
without issues.

That night just after 06:00 both `innr SP220` smart-plugs and one of the
`Heiman WarningDevice` (the new one – which had been in the network for about
one week) dropped from the network. The innr plugs worked fine just prior to
dropping from the network (one of them was toggled on successfully at 06:00
sharp by an automation).

Power-cycling the innr smart-plugs got them back working again. The Heiman unit
has been dead since the incident (doesn't pair even tough its light indicates it
is in pairing-mode).

Also, one of the two new Aqara motion sensors (`lumi.sensor_motion.aq2`) dropped
from the network too (had to press the button on the device four a couples
seconds to get it to re-pair via a search in the deCONZ GUI).

It appears that at roughly the same time (although I only noticed this a week
later) both `Blitzwolf` smart-plugs (`TS0121`) lost their _Electrical
Measurement_ cluster (no more power readings were reported – the cumulative
measurement, which comes from a different cluster, kept updating just fine).
Neither of the units responded to "read" requests for any of their clusters via
the deCONZ GUI anymore. Power-cycling both units appears to have restored full
functionality.

For now everything appears stable again. I still intended to see if I can
somehow resuscitate the Heiman unit. If not I'll chalk it down as an "early
failure" and order a new one.

Furthermore, next time this happens perhaps first restart deCONZ to see if that
resolves the issue?
