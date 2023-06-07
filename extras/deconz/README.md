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

Custom DDFs in [`📂 devices`](./devices/) — move into the `devices` folder of
the running deCONZ instance (picked up automatically by deCONZ after a restart,
or can be manually loaded via the DDF editor):

- [`📄 _TZ3000_r6buo8ba.json`](./devices/_TZ3000_r6buo8ba.json) — Tuya ZigBee
  Smart Power Plug 16A (`TS011F` / `_TZ3000_r6buo8ba`). Taken from
  [deconz-rest-plugin#5633](https://github.com/dresden-elektronik/deconz-rest-plugin/issues/5633#issuecomment-1152560580)
  (originally a different manufacturer, but works fine with this one too)

### Tuya Smart Watering Timer (`_TZE200_a7sghmms`)

[`📄 _TZE200_a7sghmms.json`](./devices/_TZE200_a7sghmms.json)

Available on AliExpress: <https://nl.aliexpress.com/item/1005005196816776.html>

Based on
[deconz-rest-plugin#6143](https://github.com/dresden-elektronik/deconz-rest-plugin/issues/6143);
using the following `INFO_L2`-output:

```conf
# Open/close the valve
TY_DATA_REPORT: seq ..., dpid: 0x02, type: 0x01, length: 1, val: 1
TY_DATA_REPORT: seq ..., dpid: 0x02, type: 0x01, length: 1, val: 0

# The volume (L) of water fed through the valve; resets to zero when opened
TY_DATA_REPORT: seq ..., dpid: 0x6F, type: 0x02, length: 4, val: 0

# Battery level
TY_DATA_REPORT: seq ..., dpid: 0x6C, type: 0x02, length: 4, val: 100

# Unknown; both appear always be zero zero
TY_DATA_REPORT: seq ..., dpid: 0x6A, type: 0x02, length: 4, val: 0
TY_DATA_REPORT: seq ..., dpid: 0x67, type: 0x02, length: 4, val: 0
```

I've (roughly) validated the consumption measurement with my water meter and it
appears it reports the volume in (whole) litres.

Water consumption is using `ZHAConsumption` with its value multiplied by `1,000`
and the `device_class` forced to `water` in Home Assistant to get a proper
representation of the volume (in litres) fed through the system.
