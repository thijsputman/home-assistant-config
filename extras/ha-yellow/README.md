# Home Assistant Yellow

- [Ubuntu Server 22.04](#ubuntu-server-2204)
  - [Setup](#setup)
  - [Impact](#impact)

## Ubuntu Server 22.04

Although running Ubuntu Server works fine "out-of-the-box", some additional
tweaks are required to get all of the features of the Yellow to function.

The below is loosley based on:
<https://community.home-assistant.io/t/pi-os-instead-of-ha-os-on-yellow/473695/10>

### Setup

Retrieve **`bcm2711-rpi-cm4-ha-yellow.dtb`** from Home Assistant OS and place it
under `📂 /boot/firmware`.

The copy of
[`📄 bcm2711-rpi-cm4-ha-yellow.dtb`](./boot/bcm2711-rpi-cm4-ha-yellow.dtb) in
this repository is taken from
[HA OS 10.1](https://github.com/home-assistant/operating-system/releases/tag/10.1)
— it works well with Ubuntu Server 22.04.2 (`5.15.0-1027-raspi aarch64`).

#### `cmdline.txt`

In `📄 /boot/firmware/cmdline.txt`:

- Append `console=ttyAMA2,115200n8` (after `console=tty1`)
- Remove `fixrtc` (after validating the RTC is working properly —
  [see below](#impact))

#### `config.txt`

Replace `📄 /boot/firmware/config.txt` with the
[`📄 config.txt`](./boot/config.txt) in this repository.

This is based on HA OS'
[`📄 config.txt`@92da6b6](https://github.com/home-assistant/operating-system/blob/92da6b64c7f1e9e86de801225a7864b534999510/buildroot-external/board/raspberrypi/yellow/config.txt),
with small tweaks to properly boot Ubuntu.

### Impact

After a reboot, the following changes should be observed:

- The orange LED shows a blinking heartbeat — it (and the other LEDs) can now be
  controlled as usual via `📂 /sys/class/leds`
- The real-time clock (RTC) works — `sudo hwclock --verbose`
  - After the _second_ reboot, verify using `sudo dmesg | grep rtc` that the
    system clock gets properly set and remove `fixrtc` from
    [`📄 cmdline.txt`](#cmdlinetxt)
- The Silicon Labs MGM210P is available under `/dev/ttyAMA1`
