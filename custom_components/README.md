# 📂 `custom_components`

## Custom components

- [📁 `aarlo`](https://github.com/twrecked/hass-aarlo) **@**
  [`v0.7.4b18`](https://github.com/twrecked/hass-aarlo/releases/tag/v0.7.4b18)
- [📁 `afvalwijzer`](https://github.com/xirixiz/homeassistant-afvalwijzer) **@**
  [`2023.06.01`](https://github.com/xirixiz/homeassistant-afvalwijzer/releases/tag/2023.06.01)
- [📁 `xiaomi_miot`](https://github.com/al-one/hass-xiaomi-miot) **@**
  [`v0.7.10`](https://github.com/al-one/hass-xiaomi-miot/releases/tag/v0.7.10)

## "Disabled" components

Override built-in components with an empty / "no-op" component to disable them.

### Bluetooth Proxy related

The [Bluetooth Proxy](https://esphome.github.io/bluetooth-proxies/)
functionality doesn't (yet) allow for discovery to be disabled.

It seems one of our neighbours owns a nearly infinite amount of Oral B Bluetooth
toothbrushes (or somehow keeps resetting theirs) and quite some LED BLE
compatible light bulbs.

As we have neither, and I was getting fed up having to ignore a newly discored
device nearly daily, both extensions are "disabled":

- [📁 `led_ble`](./led_ble/)
- [📁 `oralb`](./oralb/)
