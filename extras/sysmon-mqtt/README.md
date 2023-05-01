# `sysmon-mqtt` — Simple system monitoring over MQTT

The `sysmon-mqtt`-script is used on a variety of single board computers (mainly
Raspberry Pis) to provide basic performance metrics to Home Assistant.

These used to be retrieved via SNMP (and for
[some devices](../dd-wrt/README.md#snmp) they still are). That works fine, but
felt a bit archaic and somewhat overkill for the purpose: Not all metrics were
directly addressable via SNMP (e.g., retrieving CPU temperature required
defining a custom OID and calling a shell-script) and most other metrics
required further processing in Home Assistant to be usable.

Hence, `sysmon-mqtt`: A simple shell-script to capture a handful of common
metrics and push them over MQTT to Home Assistant.

- [Metrics](#metrics)
  - [Heartbeat](#heartbeat)
  - [Home Assistant discovery](#home-assistant-discovery)
  - [APT-check](#apt-check)
- [Setup](#setup)
  - [Broker](#broker)
- [Usage](#usage)
  - [Docker](#docker)
  - [`systemd`](#systemd)

## Metrics

Currently, the following metrics are provided:

- `cpu_load` — the 1-minute load as a percentage of maximum nominal load (e.g.
  for a quad-core system, 100% represents a 1-minute load of 4.0)
- `cpu_temp` — CPU temperature in degrees Celsius (read from
  `/sys/class/thermal/thermal_zone0/temp`)
- `mem_used` — Memory in use (_excluding_ buffers and caches) as a percentage of
  total available memory
- `uptime` — Uptime in seconds
- `bandwidth` — Average bandwidth (receive and transmit) for individual network
  adapters in kbps during the monitoring interval
- `apt` — Number of APT packages that can upgraded
  - This assumes a Debian(-derived) distribution; the APT-related metrics are
    automatically disabled when no `apt`-binary is present
- `reboot_required` — Reports `1` if a system reboot is required as a result of
  APT package upgrades

The metrics are provided as a JSON-object in the `sysmon/[device-name]/state`
topic.

### Heartbeat

A persistent `sysmon/[device-name]/connected` topic is provided as an indication
of whether the script is active. Its value works as a "heartbeat": It contains
the Unix timestamp of the most recent reporting iteration, `-1` while the script
is initialising, and `0` if the script was gracefully shutdown.

In case a stale timestamp is present, it may be assumed the script (or the
machine its running on) has crashed / dropped from the network. Stale is best
defined as three times the reporting interval. For the default configuration
that would amount to 90 seconds.

When the script starts, a heartbeat of `-1` is reported until the script's
_second_ iteration. This is done to allow the metrics to stabilise (e.g.,
bandwidth is averaged over the reporting interval; during the first interval it
always reports `0`).

### Home Assistant discovery

By default, the script publishes
[Home Assistant discovery](https://www.home-assistant.io/integrations/mqtt/#mqtt-discovery)
messages to the `homeassistant/sensors/sysmon` topic.

These messages are retained. Any new instance of the script started with an
already present `device-name` will re-use the existing sensor-entity `unique_id`
values (and thus "adopt" the previous instance's sensors in Home Assistant).
This behaviour is intended to allow "fixed" sensor-entities in Home Assistant
(which can easily be customised via the GUI).

The `apt`-metric is presented as a Home Assistant
[Update-entity](https://www.home-assistant.io/integrations/update.mqtt/). For
its "entity-picture" to show, copy the images from
[`📂 /www/sysmon-mqtt`](/www/sysmon-mqtt) into your Home Assistant's local
webroot.

To unregister (a set of) metrics from Home Assistant, simply remove their
topics/messages from the `homeassistant/sensors/sysmon` tree with (for example)
`mosquitto_pub`.

### APT-check

The APT update check refreshes its status once per hour; by default it stores
this status in a temporary file. It is possible to change this behaviour by
setting the `SYSMON_APT_CHECK` environment variable to a filename of your choice
(eg. `~/.apt-check`). In this way, APT-check's status output can be used by
other scripts.

The contents of the status file are as follows:

```text
<# of package upgrades available>

"The following packages can be upgraded:\n\<list of upgradable packages>"
```

The first line is either `0` or a positive integer, the second line is empty and
the third line contains a list of upgradable packages. The third line is
JSON-encoded and (due to a Home Assistant imposed limit) restricted to a maximum
of 255-characters (_prior_ to JSON-encoding).

While APT-check refreshes its status, the file is empty. This is done to prevent
leaving stale information in case of failures. There is thus a small chance of a
race-condition: To prevent this, wait until the status file has a non-zero size
before continuing...

## Setup

The script depends on `bash`,
**[`gawk`](https://www.gnu.org/software/gawk/manual/gawk.html)**, `jq` and
`mosquitto-clients`.

**N.B.**, alternative versions of `awk` are _not_ supported; you need
[GNU `awk`](https://www.gnu.org/software/gawk/manual/gawk.html).

The script has been tested on recent versions of various Linux distributions
(Ubuntu, Raspberry Pi OS, Armbian and Alpine) on both ARM and RISC-V based
devices. Given its relative simplicity, it probably works on any Linux device
where the above dependencies are available.

### Broker

The script assumes the MQTT broker to be [**Mosquitto**](https://mosquitto.org/)
(and uses this assumption to validate the broker configuration).

Furthermore, the script relies on
[MQTT-persistence](https://mosquitto.org/man/mosquitto-conf-5.html) to persist
`unique_id` values for Home Assistant sensor-entities in between restarts (of
either the script or the MQTT broker). Ensure the broker has persistence (for at
least QoS level-1 messages) enabled. Otherwise, the unique ids used in Home
Assistant will be dynamic (causing duplicate entities to be created after each
restart)...

## Usage

From the shell:

```shell
./sysmon.sh mqtt-broker device-name [network-adapters]
```

- `mqtt-broker` — hostname or IP address of the MQTT-broker
- `device-name` — **human-friendly** name of the device being monitored (e.g.,
  "My Raspberry Pi"); a low-fidelity version (`my_raspberry_pi`) is
  automatically generated and used to construct MQTT-topics and Home Assistant
  entity-ids
- `network-adapters` (optional) — one or more network adapters to monitor as a
  space-delimited list (e.g., `'eth0 wlan0'`; mind the quotes when specifying
  more than one adapter)

The following _optional_ environment variables can be used to further influence
the script's behaviour:

- `SYSMON_HA_DISCOVER` (default: `true`) — set to `false` to disable publishing
  to Home Assistant discovery topic
- `SYSMON_HA_TOPIC` (default: `homeassistant`) — base for the Home Assistant
  discovery topic
- `SYSMON_INTERVAL` (default: `30`) — set the interval (in seconds) at which
  metrics are reported
- `SYSMON_APT` (default: `true`) — set to `false` to disable reporting
  APT-related metrics (`apt` and `reboot_required`)
  - Automatically disabled when no `apt`-binary is present, _or_ when running
    inside a Docker-container (see below)
- `SYSMON_APT_CHECK` (default: `<temporary file>`) — override the location of
  the file used to store APT-check's status

### Docker

The simplest (if slightly constrained) way of running the script is via the
Docker-container published on
[Docker Hub](https://hub.docker.com/r/thijsputman/sysmon-mqtt) and
[GHCR](https://github.com/thijsputman/home-assistant-config/pkgs/container/sysmon-mqtt).
Container images are available for `amd64`, `arm64` and `armhf`.

For bandwidth monitoring to work, you'll need to mount the host's `/sys`-sysfs
into the container (as is done in the below
[`📄 docker-compose.yml`](#docker-composeyml)). Alternatively, you can use
`network_mode: host`.

The `/sys`-approach is preferred as it's more flexible (i.e., it can be used to
gather additional information such as the device model) and offers better
security: The container's network remains isolated; instead it gains _read-only_
access to `/sys` with Docker's AppArmor policies applied to prevent access to
sensitive information.

These AppArmor policies currently _prevent_ reporting the device model from
inside the container though 😵 — see
[moby#434199](https://github.com/moby/moby/issues/43419) for details. Until that
issue is resolved, you'll need to run a privileged container (easiest, if
slightly too broad, is via `privileged: true`) which is **_not_** worth the risk
just to have the device model reported.

If you don't care about bandwidth monitoring (and/or the device model), the
`/sys`-mount can be removed.

Finally, the APT-related metrics are automatically _disabled_ when running
inside a Docker-container. They would report the container's state instead of
the host's state and thus make no sense. Attempting to "push" this information
into the container is unwieldy/infeasible (and probably undesirable too).

#### `docker-compose.yml`

```yaml
version: "2.3"
services:
  sysmon-mqtt:
    image: thijsputman/sysmon-mqtt:latest
    restart: unless-stopped
    # Mount host's /sys-sysfs (read-only) into the container
    volumes:
      - /sys:/sys:ro
    environment:
      - MQTT_BROKER=
      - DEVICE_NAME=
      # Optional: Specify network adapters for bandwidth monitoring
      - NETWORK_ADAPTERS=
      # Optional: Drop permissions to the provided UID/GID-combination
      - PUID=
      - PGID=
```

The optional environment variables provided above can of course be passed into
the Docker-container to further modify its behaviour.

### `systemd`

Alternatively, it's possible to run the script as a `systemd`-service using
something along the lines of the below configuration:

**`📄 /etc/systemd/system/sysmon-mqtt.service`**

```conf
[Unit]
Description=Simple system monitoring over MQTT
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=120
StartLimitBurst=3

[Service]
Type=simple
Restart=on-failure
RestartSec=30
# Update the below match your environment
User=[user]
ExecStart=/usr/bin/env bash /home/<user>/sysmon.sh \
  mqtt-broker "Device Name" [network-adapters]
# Optional: Provide additional environment variables
Environment=""

[Install]
WantedBy=multi-user.target
```

This unit configuration aims to start `sysmon-mqtt` _after_ the network comes
online. For this to work properly, the output of the below command should be
`enabled` on your system.

```shell
systemctl is-enabled systemd-networkd-wait-online.service
```

Reload, enable and start the service:

```shell
sudo systemctl daemon-reload
sudo systemctl enable sysmon-mqtt
sudo systemctl start sysmon-mqtt
```

To facilitate this setup process, a setup-script (suitable for Debian(-derived)
distributions) is provided: [`📄 install.sh`](./install.sh). Once installed,
running the script again will pull the latest version of `📄 sysmon.sh` from
GitHub.

The script requires `mqtt-broker` and `"Device Name"` to be provided. As an
optional third argument, a list of network adapters to monitor can also be
passed in:

```shell
./install.sh mqtt-broker "Device Name" "eth0 wlan0"
```

For the very brave, the script can be run from GitHub directly:

```shell
curl -fsSL https://github.com/thijsputman/home-assistant-config/raw/main/\
extras/sysmon-mqtt/install.sh | sudo -E bash -s - \
mqtt-broker "Device Name" "eth0 wlan0"
```
