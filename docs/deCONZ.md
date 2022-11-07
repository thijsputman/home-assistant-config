# deCONZ (Phoscon ConBee II)

- [Heiman Siren](#heiman-siren)
- [Smart plugs](#smart-plugs)
  - [Tuya Smart Power Plug 16A](#tuya-smart-power-plug-16a)
  - [Xiaomi Mi Smart Plug (`lumi.plug.mmeu01`)](#xiaomi-mi-smart-plug-lumiplugmmeu01)
  - [BlitzWolf Smart Socket (`TS0121`)](#blitzwolf-smart-socket-ts0121)
- [IKEA Tradfri Repeater](#ikea-tradfri-repeater)
  - [Update — May/June 2021](#update--mayjune-2021)

As a general caution, if Zigbee-entities become `unavailable` after restarting
deCONZ (without restarting Home Assistant), **_reload_** the integration before
trying anything else...

## Heiman Siren

To pair, press reset for 5 seconds. The light blinks green a couple times (and
an electric "hum" starts). Then press reset for 2 seconds (rapid green blinking;
long blink on pair). Pair both as light and as sensor (i.e., pair twice) through
deCONZ.

If the device keeps "buzzing", press reset for 2 seconds and (re)discover the
sensor. That should stop the electric "hum" (in two out of the three devices I
have; the third one keeps buzzing regardless).

If/when the siren stops working properly, leave it unplugged for a couple days
(so the internal battery fully drains) and try again...

Note that there's an issue in deCONZ versions prior to `2.17` which causes these
(newly) added sensors to go offline after 24-hours. Doesn't impact the
functioning of the siren (so the offline sensors can easily be disabled in Home
Assistant to work around the issue).

## Smart plugs

### Tuya Smart Power Plug 16A

There appear to be many incarnations around (same device; same form factor —
different manufacturer). I own both `_TZ3000_ew3ldmgx` and `_TZ3000_r6buo8ba`
units and both work like a charm: No difficulties in pairing and discovering the
consumption sensors; no need to pair multiple times and/or manually discover
sensors...

Simply pair as a `Light` in deCONZ and they work.

Note that for `_TZ3000_r6buo8ba` a custom DDF needs to be loaded. See
[`📂 extras/deconz/devices/`](../extras/deconz/README.md) for more details.

### Xiaomi Mi Smart Plug (`lumi.plug.mmeu01`)

As of end of 2021, this plug appears to out of stock / not available anymore.

Once paired, they generally work as intended with deCONZ `2.9.2` or above –
including the power consumption measurements. Several of my units show
intermittent issues: Mainly after deCONZ reboots they start dropping off the
network. Power-cycling the units appears to mostly resolve the issue; as does
repairing them.

Pairing is a bit of hassle:

#### deCONZ `2.11.5`

Once the device is paired (with or without all of its additional sensors),
there's no more need to remove and re-add it until all sensors show up. Instead,
restart discovery on the device (keep its button pressed for 5 seconds – blinks
red once and then starts rapidly blinking blue) and start a **sensor** search
from the Phoscon GUI (instead of the initial _light_ search used to pair the
device).

Make sure the device is powered _on_ (it powers itself off when you keep its
button pressed for 5 seconds) _before_ you start the sensor search.

This search should almost immediately return a new sensor. Needs to be done
twice, once for the `power` and once for the `consumption` sensor (even if one
of them was already found during initial pairing). The procedure is comperable
with the [BlitzWolf](#blitzwolf-smart-socket-ts0121) procedure described
below...

There should be 4 clusters showing up (`01`, `15`, `16`, and `F2`) for the plug
to work properly.

Additionally, it appears not necessary anymore to manually delete additional
sensors upon deleting the main `light`-entity; deCONZ seems to be taking care of
this automatically now.

#### Original instructions

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

This unit appears (again, through limited testing) to have similar problems as
the [Xiaomi unit](#xiaomi-mi-smart-plug-lumiplugmmeu01) – different instructions
apply though:

> Resetting the device (initializing pairing sequence by holding power button
> for more than 5 seconds) while having pairing mode/sensor search active in
> Phoscon some kind of "re-joined" the plug to the ConBee/ZigBee mesh.

Reference:

- <https://github.com/dresden-elektronik/deconz-rest-plugin/issues/2988#issuecomment-791972997>

## IKEA Tradfri Repeater

An odd incident occurred on April 26th 2021 at around 23:00: The
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

### Update — May/June 2021

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

After a prolonged power outage, the Heiman warning-device again didn't come back
online; effectively showing the same symptoms as described above. The other
Heiman warning-device came back online just fine. It seems the device was
somewhat broken to begin with. At the same time, the `TRADFRI Signal Repeater`
also kept causing issues. So, both devices were removed from the network and
scrapped.
