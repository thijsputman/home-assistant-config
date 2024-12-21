# AndroidTV `adb`-server

Ever since upgrading my NVIDIA Shield TV to **Android 11**, it started behaving
less well in combination with Home Assistant's
[AndroidTV integration](https://www.home-assistant.io/integrations/androidtv/).

In essence it works fine, but while switched `on` the player's state randomly
jumps to `standby` for 10-second intervals every couple of minutes. This
behaviour can be worked around in most automations, but the fact of the matter
remains the player's state is often incorrect...

~~Anecdotal evidence suggests that running a "native" `adb`-server (instead of
the Python implementation provided with Home Assistant) might resolve the issue.
As such, this Docker-container tools up an `adb`-server specifically for that
purpose.~~

Further investigation shows it's most probably "Shield Experience 9.1"-related
(aka, the Android 11 upgrade), with a likely fix incoming via
[**python-androidtv/#329**](https://github.com/JeffLIrion/python-androidtv/pull/329).

Anyway...

- [`adb`-server](#adb-server)
  - ["Remote" connections](#remote-connections)
- [Setup](#setup)
  - [Keys](#keys)
- [See Also](#see-also)

## `adb`-server

The principle behind the container is simple: It starts an `adb`-server and
subsequently attempts to `adb connect` to a given AndroidTV-device every
30-seconds (`connect` is a no-op if already connected). This ensures there's
always an active ADB-connection to the AndroidTV.

The Home Assistant integration uses its Python-client to communicate with the
already/always connected "native" `adb`-instance.

An additional benefit of holding the ADB-connection "outside" of Home Assistant
is, that it's now possible for other clients to utilise it too — Home Assistant
doesn't hold an exclusive lock on the connection anymore...

As such, there might be some merit to keeping ADB running this way; regardless
of what originally prompted the approach.

### "Remote" connections

To "remotely" connect a client to the `adb`-server running in the container, do
the following:

```shell
export ANDROID_ADB_SERVER_ADDRESS=127.0.0.1
adb devices # Should show a connected AndroidTV device
```

This works from the machine running the container. Note that it is required to
use `127.0.0.1`. Using `localhost` will cause `adb` to automatically spawn a
server (defeating the purpose).

Actual remote connections are also possible. In that case, ensure the
container's port-forwarding (see below) is setup as `5037:5037/tcp` (_without_
the leading `127.0.0.:` as that limits it to local connections only). Note that
configuration access in this way poses a substantial security-risk to your
Android device...

Alternatively, you can use SSH to forward port 5037 onto another host on-demand
(without the need to expose it your entire network):

```shell
ssh -g -L 5037:127.0.0.1:5037 -N adb-host.local
```

You can now simply connect to ADB as if it were running on localhost.

## Setup

Use the below `📄 docker-compose.yml` (start using `docker-compose up -d`):

```yaml
version: "2.3"
services:
  androidtv:
    image: androidtv
    # Point to the location of the Dockerfile
    build: ./extras/androidtv
    restart: unless-stopped
    network_mode: bridge
    ports:
      # Remove "127.0.0.1:" if you intended to access adb remotely
      - 127.0.0.1:5037:5037/tcp
    volumes:
      # This folder should contain "adbkey" and "adbkey.pub"; if omitted, new
      # keys are generated every time the container is created
      - ./extras/androidtv/keys:/androidtv/keys
    environment:
      # Hostname or IP address of your AndroidTV device; port 5555 is assumed
      - ANDROIDTV_DEVICE=android-tv.local
      # Optional: Enable verbose output; normally only "adb" messages are
      # logged — <https://developer.android.com/studio/command-line/variables>
      - ADB_TRACE=all
      # Optional: Drop permissions to the provided UID/GID-combination
      - PUID=1000
      - PGID=1000
```

### Keys

Home Assistant's AndroidTV integration by default keeps its keys in
`📂 .storage` (named `📄 androidtv_adbkey` and `📄 androidtv_adbkey.pub`).
Rename those to `📄 adbkey` and `📄 adbkey.pub` respectively and feed them into
the container (see above) to prevent having to reauthenticate with your
AndroidTV-device.

## See Also

- [`📄 docs/ANDROIDTV.md`](/docs/ANDROIDTV.md)
