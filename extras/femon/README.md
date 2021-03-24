# `femon` – DVB-T frontend signal monitor

Simple script to monitor DVB-T signal-strength and signal-to-noise ratio (using
`femon`) and push them to an MQTT-broker.

## Usage

```shell
./femon.sh mqtt-broker [samples]
```

Provide the hostname of your (local) MQTT-broker using `mqtt-broker` and
optionally the number of `samples` per measurement (the average of the samples
is send to the broker).

Measurements are communicated to the MQTT-broker every 60 seconds on the
`femon/signal` and `femon/snr` topics respectively.

## Docker

The easiest way to continuously run the script is via the provided
`📄 Dockerfile`.

From within the `📁 /extras/femon` directory, run:

```shell
docker build -t femon .
```

**N.B.** The `📄 Dockerfile` in this repository builds an `aarch64` container
(modifying it to support another architecture should be trivial though).

Extend your `📄 docker-compose.yaml` with with the below (or create a new one):

```Dockerfile
version: "2.3"
services:
  # DVB-T frontend signal monitor
  femon:
    image: femon
    restart: unless-stopped
    devices:
      - /dev/dvb:/dev/dvb
    environment:
      - MQTT_BROKER=mqtt.example
    # Optional, but highly recommended – see below
    # - PUID=
    # - PGID=
```

Use `PUID` and `PGID` to provide the user id and group id to run the script
under (e.g. your local user, or a user specifically created for this purpose).
Should there be a privilege-escalation, this user/group determines how bad the
escalation will be...

If you omit them, the container will pick the first available UID/GID
combination (most likely `1000:1000` – which on an Ubuntu CloudInit-install
would map to the default `ubuntu` user).
