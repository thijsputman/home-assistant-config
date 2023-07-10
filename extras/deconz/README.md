# deCONZ

- [REST-command scratch-pad](#rest-command-scratch-pad)
- [Custom Device Description Files (DDF)](#custom-device-description-files-ddf)
  - [Tuya Smart Watering Timer (`_TZE200_a7sghmms`)](#tuya-smart-watering-timer-_tze200_a7sghmms)

## REST-command scratch-pad

Using the wonderful
[`vscode-restclient`](https://github.com/Huachao/vscode-restclient) VS Code
extension.

For the scratch-pad to work, `DECONZ_BASEURL` and `DECONZ_KEY` should be defined
a `📄 .env` file in the same folder.

## Custom Device Description Files (DDF)

Custom DDFs in [`📂 devices`](./devices/):

- [`📄 _TZ3000_r6buo8ba.json`](./devices/_TZ3000_r6buo8ba.json) — Tuya ZigBee
  Smart Power Plug 16A (`TS011F` / `_TZ3000_r6buo8ba`). Taken from
  [deconz-rest-plugin#5633](https://github.com/dresden-elektronik/deconz-rest-plugin/issues/5633#issuecomment-1152560580)
  (originally a different manufacturer, but works fine with this one too)
- [`📄 _TZE200_a7sghmms.json`](./devices/_TZE200_a7sghmms.json) – see
  [Tuya Smart Watering Timer](#tuya-smart-watering-timer-_tze200_a7sghmms)

Copy these into the `devices`-folder of the deCONZ instance
(`/opt/deCONZ/devices` for the Docker-container). They're picked up
automatically after a deCONZ restart (or directly when manually loading them in
the DDF editor).

### Tuya Smart Watering Timer (`_TZE200_a7sghmms`)

Multiple variants of the device appear to be available (names; vendors – always
the same physical appearance and "manufacturer" string though). I have
[this version from AliExpress](https://nl.aliexpress.com/item/1005005196816776.html).

The DDF is based on
[deconz-rest-plugin#6143](https://github.com/dresden-elektronik/deconz-rest-plugin/issues/6143);
using the below `INFO_L2`-output. It's identical to
[deconz-rest-plugin#6944](https://github.com/dresden-elektronik/deconz-rest-plugin/issues/6944)
(which I only came across later 🤐). Once
[deconz-rest-plugin#6947](https://github.com/dresden-elektronik/deconz-rest-plugin/pull/6947)
(the PR for **#6944**) gets merged, my custom DDF is – in principle – not needed
anymore.

Note that I've omitted the "advanced" features (e.g. irrigation cycle and device
mode) from the DDF as – apart from exposing their values in the REST API – they
don't appear have much use/benefit. Proper support for these features in the
deCONZ API (and Home Assistant for that matter) appears to be quite some way
off...

#### `INFO_L2`

```conf
# Open/close the valve
TY_DATA_REPORT: seq ..., dpid: 0x02, type: 0x01, length: 1, val: 1
TY_DATA_REPORT: seq ..., dpid: 0x02, type: 0x01, length: 1, val: 0

# The volume (L) of water fed through the valve; resets to zero when opened.
# I've compared the consumption measurement with my home water meter's reading
# and it appears it accurately reports the volume dispensed in litres.
TY_DATA_REPORT: seq ..., dpid: 0x6F, type: 0x02, length: 4, val: 0

# Battery level
TY_DATA_REPORT: seq ..., dpid: 0x6C, type: 0x02, length: 4, val: 100

# Unknown; both appear always be zero zero
TY_DATA_REPORT: seq ..., dpid: 0x6A, type: 0x02, length: 4, val: 0
TY_DATA_REPORT: seq ..., dpid: 0x67, type: 0x02, length: 4, val: 0
```

#### Further Details

Water consumption is using `ZHAConsumption` with its value multiplied by `1,000`
and the `device_class` forced to `water` in Home Assistant to get a proper
representation of the volume (in litres) fed through the system. See
[homebridge-deconz#138](https://github.com/ebaauw/homebridge-deconz/issues/138#issuecomment-1535456569)
for a related discussion as to why this is necessary.

For `swversion` to be properly reported,
[`📄 tuya_swversion.js`](./devices/tuya_swversion.js) should also be placed in
the `devices`-folder. This file is taken from
[`📂 deconz-rest-plugin/tree/master/devices/tuya`](https://github.com/dresden-elektronik/deconz-rest-plugin/tree/master/devices/tuya).

For more details regarding the peculiarities of Tuya DDFs, see:
[DDF support Tuya manufacturer specific cluster](https://github.com/dresden-elektronik/deconz-rest-plugin/wiki/DDF-support-Tuya-manufacturer-specific-cluster-&-How-to-know-which-datapoints-a-Tuya-device-provides%3F)
in the
[deCONZ wiki](https://github.com/dresden-elektronik/deconz-rest-plugin/wiki).
