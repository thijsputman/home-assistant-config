# DD-WRT

- [Ping to MQTT](#ping-to-mqtt)
  - [Setup](#setup)
  - [Usage](#usage)
- [SNMP](#snmp)
  - [Setup](#setup-1)
  - [Usage](#usage-1)

## Ping to MQTT

Simple (POSIX-compliant) shell-script that pings a host-name once every minute
and publishes the average roundtrip time (by default based on four pings) to
MQTT.

Used on my DD-WRT router and access-points to monitor network/Internet
performance. There's a ping sensor running in Home Assistant too, but its
roundtrip times vary based on the load on the underlying (RPi 4) device. As such
they are a less useful indication of overall network performance...

- [Ping to MQTT](#ping-to-mqtt)
  - [Setup](#setup)
  - [Usage](#usage)
- [SNMP](#snmp)
  - [Setup](#setup-1)
  - [Usage](#usage-1)

### Setup

Requires JFFS (or some other form of persistent storage) and Entware installed
on the DD-WRT unit.

```shell
opkg install mosquitto-client-nossl
```

Copy the provided folder structure onto `📁 /jffs` and update
`📄 /jffs/etc/config/ping2mqtt.wanup` with your MQTT hostname and the MQTT topic
to publish to (and optionally change the number of pings and the ping target).

Note that `.wanup` entails the script is run (i.e. pinging starts) whenever the
WAN connection goes up. In case of an access-point, using `.startup` might be
more appropriate (i.e. WAN up might never occur on those devices). See
<https://wiki.dd-wrt.com/wiki/index.php/Script_Execution> for more details.

### Usage

```shell
./ping2mqtt.sh mqtt-host mqtt-topic [ping-host] [count]
```

By default the `ping-host` is `8.8.8.8` (Google Public DNS) and `count` is `4`.

The script will run indefinitely; pinging and publishing to MQTT (approximately)
once per minute.

The script uses a (naive) locking approach to prevent spawning multiple
instances (as WAN up can occur an infinite number of times on a running DD-WRT
unit). A lock-file is written to `/tmp` (non-persistent storage; cleared at
reboot) and upon start the script will abort if the lock-file is present.

When receiving `INT`, `HUP`, `TERM` or `EXIT` the script will attempt to remove
the lock-file. This covers the most common termination scenarios and thus
entails the lock-file should be removed in those cases. The `EXIT` trap
specifically should ensure the script cleans up after itself in case one of the
commands it attempts to execute fails.

## SNMP

The below configuration provides public (i.e., no authorisation required)
read-only access to a limited set of metrics.

### Setup

Don't enable SNMP in the DD-WRT GUI. Instead, copy
[`📄 snmpd.conf`](./jffs/etc/snmp/snmpd.conf) to `📂 /jffs/etc/snmp` (this
assume JFFS is available). Start the `snmpd` daemon via the GUI; add the below
to the startup script (under `Administration / Commands`):

```shell
snmpd -c /jffs/etc/snmp/snmpd.conf
```

### Usage

The below table provides an overview of the metrics currently used in Home
Assistant.

| Type    | Description          | OID                         |
| ------- | -------------------- | --------------------------- |
| CPU     | 1-minute load        | `1.3.6.1.4.1.2021.10.1.3.1` |
| Memory  | Real available (KiB) | `1.3.6.1.4.1.2021.4.6.0`    |
| Memory  | Cached (KiB)         | `1.3.6.1.4.1.2021.4.14.0`   |
| Memory  | Buffer (KiB)         | `1.3.6.1.4.1.2021.4.15.0`   |
| Network | WAN in (octets)      | `1.3.6.1.2.1.2.2.1.10.5`    |
| Network | WAN out (octets)     | `1.3.6.1.2.1.2.2.1.16.5`    |

To come to an approximation of the percentage "memory available", sum the three
memory metrics in the above table (`real`, `cached` and `buffer`) and compute
that as a fraction of the total memory installed in the system.
