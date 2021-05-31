# deCONZ (Phoscon ConBee II)

- [Device-compatibility](#device-compatibility)
  - [Xiaomi Mi Smart Plug (`lumi.plug.mmeu01`)](#xiaomi-mi-smart-plug-lumiplugmmeu01)
  - [BlitzWolf Smart Socket (`TS0121`)](#blitzwolf-smart-socket-ts0121)
- [Notes](#notes)
  - [IKEA Tradfri Repeater (April 2021)](#ikea-tradfri-repeater-april-2021)

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

## Notes

### IKEA Tradfri Repeater (April 2021)

An odd incident occurred on April 26th at around 23:00: The
`TRADFRI Signal Repeater` dropped from the network (crashed?). Once power-cycled
the device came back up without issue.

The following morning just after 06:00 both `innr SP220` smart-plugs and one of
the `Heiman WarningDevice` (the new one – which had been in the network for
about one week) dropped from the network. The innr plugs worked fine just prior
to dropping from the network (one of them was toggled on successfully at 06:00
sharp by an automation).

Power-cycling the innr smart-plugs got them back working again. The Heiman unit
remained dead after power-cycling; turns out its internal battery needs to be
fully drained for the device to reset (which appears to take significantly more
than the 4 hours quoted in the manual – see below). Using the reset button on
the Heiman unit had no effect...

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

#### Update – End of May

After leaving the Heiman device unplugged for a couple weeks (to force its
internal battery to fully drain), it was successfully joined back into the
Zigbee-network. After recharging its battery, it was moved into its original
location again in the afternoon.

Interestingly, that evening _exactly_ the same incident repeated itself: The
`TRADFRI Signal Repeater` dropped from the network without warning. This time,
instead of power-cycling the repeater, it was unplugged and no further action
was taken. This appears to have been a better resolution: A week later all
devices in the network are still functioning properly; no outages or strange
behaviours have been observed.

The signal repeater was located physically very close to the Heiman unit.
**Conclusion**: It appears that somehow the `TRADFRI Signal Repeater` and the
`Heiman WarningDevice` don't play nice in close proximity? 😕
