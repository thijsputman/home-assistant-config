# ESPHome

Some initial ESPHome-related matters.

I'm currently running ESPHome on a separate Raspberry Pi from where Home
Assistant is running (mainly to facilitate bootstrapping devices via serial
cable).

- [Bootstrap](#bootstrap)
- [Configuration templates](#configuration-templates)
  - [M5Stack Atom Lite - Bluetooth Proxy](#m5stack-atom-lite---bluetooth-proxy)

## Bootstrap

To bootstrap a device, create a configuration file for it based on one of the
below templates and `scp` that into ESPHome's `📂 /config` folder.

To generate API encryption keys, use:

```shell
head -c 32 /dev/urandom | base64
```

Once the device is flashed, adopt the _newly_ added device in ESPHome and delete
the (now "Offline") bootstrapped device.

Copy the bootstrap configuration into the newly adopted device, with these
modifications:

- Leave the adopted device's `substitutions:`-section as-is
- Change `name_add_mac_suffix:` from `true` to **`false`**

When done properly, a second flash (of the adopted device) shouldn't be
necessary.

## Configuration templates

### M5Stack Atom Lite - Bluetooth Proxy

Using a handful of M5Stack Atom Lite's a Bluetooth proxies around the house.

Use [`📄 m5stack-atom-lite.yaml`](./m5stack-atom-lite.yaml) to bootstrap them.
