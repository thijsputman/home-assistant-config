# deCONZ

- [REST-command scratch-pad](#rest-command-scratch-pad)
- [Custom Device Description Files (DDF)](#custom-device-description-files-ddf)

## REST-command scratch-pad

Using the wonderful
[`vscode-restclient`](https://github.com/Huachao/vscode-restclient) VS Code
extension.

For the scratch-pad to work, `DECONZ_BASEURL` and `DECONZ_KEY` should be defined
a `📄 .env` file in the same folder.

## Custom Device Description Files (DDF)

Custom DDFs in [`📂 devices`](./devices/) — move into the `devices` folder of
the running deCONZ instance (and then be picked up automatically based on their
filenames):

- [`📄 _TZ3000_r6buo8ba.json`](./devices/_TZ3000_r6buo8ba.json) — Tuya ZigBee
  Smart Power Plug 16A (`TS011F` / `_TZ3000_r6buo8ba`). Taken from
  [deconz-rest-plugin#5633](https://github.com/dresden-elektronik/deconz-rest-plugin/issues/5633#issuecomment-1152560580)
  (originally a different manufacturer, but works fine with this one too)
