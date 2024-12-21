# AndroidTV

- [Application list](#application-list)
- [State detection rules](#state-detection-rules)
  - [Plex — `com.plexapp.android`](#plex--complexappandroid)

## Application list

| Application name | Application ID                      |
| ---------------- | ----------------------------------- |
| Disney+          | `com.disney.disneyplus`             |
| Dispatch         | `com.spauldhaliwal.dispatch`        |
| Geforce NOW      | `com.nvidia.geforecenow`            |
| HBO Max          | `com.hbo.hbonow`                    |
| Live Channels    | `com.google.android.tv`             |
| Netflix          | `com.netflix.ninja`                 |
| NPO Start        | `nl.uitzendinggemist`               |
| Plex             | `com.plexapp.android`               |
| Prime Video      | `com.amazon.amazonvideo.livingroom` |
| Shield TV        | `com.nvidia.shield.remote`          |
| Spotify          | `com.spotify.tv.android`            |
| YouTube          | `com.google.android.youtube.tv`     |

## State detection rules

Most common apps are either included in the
[`androidtv`](https://github.com/JeffLIrion/python-androidtv) package, or nicely
follow the device's `media_session_state`. For the one's that don't, there's
custom state detection rules below.

### Plex — `com.plexapp.android`

```json
[
  { "playing": { "media_session_state": 3, "wake_lock_size": 1 } },
  { "paused": { "media_session_state": 3 } },
  "idle"
]
```
