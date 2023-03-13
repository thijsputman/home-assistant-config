# `sysmon-mqtt` — Simple system monitoring over MQTT

The `sysmon-mqtt`-script is used on a variety of single board computers (mainly
Raspberry Pis) to provide basic performance metrics to Home Assistant.

These used to be retrieved via SNMP (and for
[some devices](../dd-wrt/README.md#SNMP) they still are). That works fine, but
felt a bit archaic and somewhat overkill for the purpose: Not all metrics were
directly addressable via SNMP (e.g., retrieving CPU temperature required
defining a custom OID and calling a shell-script) and most other metrics
required further processing in Home Assistant to be usable.

Hence, `sysmon-mqtt`: A simple shell-script to capture a handful of common
metrics and push them over MQTT to Home Assistant.

- [Metrics](#metrics)
  - [Home Assistant discovery](#home-assistant-discovery)
- [Setup](#setup)
  - [Broker](#broker)
- [Usage](#usage)
  - [Docker](#docker)
  - [`systemd`](#systemd)

## Metrics

Currently, the following metrics are provided:

- `cpu_load` — the 1-minute load as a percentage of maximum nominal load (e.g.
  for a quad-core system, 100% represents a 1-minute load of 4.0)
- `cpu_temp` — CPU temperature in degrees Celcius (read from
  `/sys/class/thermal/thermal_zone0/temp`)
- `mem_used` — Memory in use (_excluding_ buffers and caches) as a percentage of
  total available memory

The metrics are provided as a JSON-object in the `sysmon/[device-name]/state`
topic.

A `sysmon/[device-name]/connected` topic (with value `0` or `1`) is provided as
an indication of whether the script is active.

### Home Assistant discovery

By default, the script publishes
[Home Assistant discovery](https://www.home-assistant.io/integrations/mqtt/#mqtt-discovery)
messages to the `homeassistant/sensors/sysmon` topic.

These messages are retained. Any new instance of the script started with an
already present `device-name` will re-use the existing sensor-entity `unique_id`
values (and thus "adopt" the previous instance's sensors in Home Assistant).
This behaviour is intended to allow "fixed" sensor-entities in Home Assistant
(which can easily be customised via the GUI).

To unregister (a set of) metrics from Home Assistant, simply remove their
topics/messages from the `homeassistant/sensors/sysmon` tree with (for example)
`mosquitto_pub`.

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
./sysmon.sh [mqtt-broker] [device-name]
```

- `mqtt-broker` — hostname or IP address of the MQTT broker
- `device-name` — name of the device to monitor; this value is used to construct
  MQTT topic names _and_ the sensor names used in Home Assistant (use only
  lowercase alphanumeric characters and underscores)

The following _optional_ environment variables can be used to further influence
the script's behaviour:

- `SYSMON_HA_DISCOVER` (default: `true`) — set to `false` to disable publishing
  Home Assistant discovery messages
- `SYSMON_INTERVAL` (default: `30s`) — set the interval at which metrics are
  reported; the value is passed to `sleep` directly, so anything it accepts as
  its duration will do

### Docker

The simplest (if somewhat overkill) way of running the script is via the
Docker-container published on
[Docker Hub](https://hub.docker.com/r/thijsputman/sysmon-mqtt) or
[GHCR](https://github.com/thijsputman/home-assistant-config/pkgs/container/sysmon-mqtt).
Container images are available for `amd64`, `arm64` and `armhf`.

Use the below `📄 docker-compose.yml` and start using `docker-compose up -d`:

```yaml
version: "2.3"
services:
  sysmon-mqtt:
    image: thijsputman/sysmon-mqtt:latest
    restart: unless-stopped
    environment:
      - MQTT_BROKER=
      - DEVICE_NAME=
    # Optional: Drop permissions to the provided UID/GID-combination
    # - PUID=1000
    # - PGID=1000
```

The optional environment variables provided above can of course be passed into
the Docker-container to further modify its behaviour.

### `systemd`

Alternatively, it's trivial to run the script as a `systemd` service using
something along the lines of the below configuration:

**`📄 /etc/systemd/system/sysmon-mqtt.service`**

```conf
[Unit]
Description=Simple system monitoring over MQTT
After=network.target

[Service]
Type=simple
Restart=on-failure
# Update the below match your environment
User=[user]
ExecStart=/usr/bin/env bash /home/[user]/sysmon.sh [mqtt-broker] [device-name]

[Install]
WantedBy=multi-user.target
```

Reload, enable and start the service:

```shell
sudo systemctl daemon-reload
sudo systemctl enable sysmon-mqtt.service
sudo systemctl start sysmon-mqtt.service
```
