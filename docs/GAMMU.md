# Gammu

Instructions on setting up Gammu via a Docker container running
[`sms2mqtt`](https://hub.docker.com/r/domochip/sms2mqtt) using a `Huawei E3372h`
USB-stick LTE-modem.

- [Activate SIM-card](#activate-sim-card)
- [Setup Huawei-stick](#setup-huawei-stick)
- [Test Gammu](#test-gammu)
- [Potential conflict with SNMPd](#potential-conflict-with-snmpd)

## Activate SIM-card

Easiest way to activate is to simply put it in a mobile phone.

Disable the SIM PIN and send one SMS message to ensure it's properly activated.
I haven't been able to get Gammu to accept the PIN (as such, disabling it seems
to best/easiest solution).

The lights on the Huawei-stick have the following meaning:

- Green (slowly blinking) — connecting
- Blue (slowly blinking) — connected

## Setup Huawei-stick

```shell
apt install usb-modeswitch
```

Find the Huawei-stick and use its vendor ID and product ID to setup a `udev`
rule:

```shell
lsusb -vt
```

**`📄 /etc/udev/rules.d/10-gsm-modem.rules`**

```conf
ACTION=="add" \
, ATTRS{idVendor}=="12d1" \
, ATTRS{idProduct}=="1f01" \
, RUN+="/sbin/usb_modeswitch -X -v 12d1 -p 1f01"
```

USB mode-switch will switch the stick from `h` (Hisense) mode into `s` (stick)
mode and provide a plain LTE-modem over USB. In Hisense-mode, a local network
adapter with a local HTTP server is used as bridge instead (more convenient for
end-user, not suitable for Gammu). It is also possible to reflash the firmware
(a bit of a hassle), so this mode-switch is easier...

More details:

- <https://www.home-assistant.io/integrations/sms/>
- <https://www.0xf8.org/2017/01/flashing-a-huawei-e3372h-4g-lte-stick-from-hilink-to-stick-mode/>

## Test Gammu

Once the stick is properly setup, restart the machine. It appears executing the
mode-switch command manually works but somehow doesn't add the USB modem.

Note that installing Gammu on the local machine is only required for testing
purposes. Once setup properly, Gammu will run inside a Docker container...

```shell
apt install gammu
```

Find the TTY to use:

```shell
ls -l /dev/*USB*
```

Or better, use the below to find a "fixed" reference to the modem:

```shell
ls -l /dev/serial/by-id/
```

There are three Huawei devices listed: `if00`, `if01` and `if02`. `if01` Does
nothing, `if02` works but is very slow, `if00` appears to be the one to use...

**`📄 ~/.gammurc`**

```conf
[gammu]
device = /dev/serial/by-id/usb-HUAWEI_MOBILE_HUAWEI_MOBILE-if00-port0
connection = at
```

```shell
gammu identify gammu networkinfo
gammu sendsms TEXT 0123456789 -text "Hello World!"
```

## Potential conflict with SNMPd

After setting up the Huawei-stick, `snmpd` started crashing every couple of days
with the following message:

```log
Aug 23 21:21:40 pi4 snmpd[1897]: IfIndex of an interface changed. Such interfaces will appear multiple times in IF-MIB.
Aug 23 21:21:40 pi4 snmpd[1897]: ioctl 35111 returned -1
Aug 23 21:21:40 pi4 snmpd[1897]: ioctl 35091 returned -1
...
Aug 25 17:48:02 pi4 snmpd[1897]: ioctl 35091 returned -1
Aug 25 17:48:02 pi4 snmpd[1897]: ioctl 35105 returned -1
Aug 25 17:53:05 pi4 snmpd[1897]: error on subcontainer 'ifTable container' remove (-1)
Aug 25 17:53:08 pi4 systemd[1]: snmpd.service: Main process exited, code=killed, status=11/SEGV
Aug 25 17:53:08 pi4 systemd[1]: snmpd.service: Failed with result 'signal'.
```

Seemed too much of a coincidence to not be related to the Huawei-stick. Solution
seems to be to remove the `wwan0` interface (exposed by the Huawei-stick) from
the system:

```shell
udevadm info --path=/sys/class/net/wwan0
udevadm test --action="add" /devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.4/1-1.4:1.3/net/wwan0 2>&1 | less
```

Source: <https://unix.stackexchange.com/a/467085>
