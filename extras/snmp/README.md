# Simple Network Management Protocol

Used to monitor a variety of Raspberry Pi and DD-WRT devices.

The below configurations provide public (i.e., no authorisation required)
read-only access to a limited set of metrics.

- [Raspberry Pi](#raspberry-pi)
- [DD-WRT](#dd-wrt)

## Raspberry Pi

Copy [`📄 snmpd.conf`](./rpi/snmpd.conf) to `📂 /etc`; copy
[`📄 cputemp.sh`](./rpi/cputemp.sh) to `📂 /usr/local/sbin` and ensure it's
executable (`chmod +x`).

Enable/start the `snmpd` daemon (`systemctl enable snmpd`).

The following information is exposed:

- CPU utilisation
- CPU temperature
- memory utilisation

## DD-WRT

Don't enable SNMP in the DD-WRT GUI. Instead, copy
[`📄 snmpd.conf`](./dd-wrt/snmpd.conf) to `📂 /jffs/etc/snmp` (this assume JFFS
is available).

Start the `snmpd` daemon via the GUI; add the below to the startup script (under
`Administration / Commands`):

```shell
snmpd -c /jffs/etc/snmp/snmpd.conf
```

The following information is exposed:

- CPU utilisation
- list of network adapters
- Total octets in/out for all network adapters
