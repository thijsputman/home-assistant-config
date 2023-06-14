# Piper / Wyoming

Still early days, but seems to be working just fine...

I'm running the
[`wyoming-piper` container](https://hub.docker.com/r/rhasspy/wyoming-piper) on a
separate machine and am using it in Home Assistant for all my TTS needs. See
[`📄 docker-compose.yml`](./docker-compose.yml) for details.

Currently building the container directly from
[GitHub](https://github.com/rhasspy/wyoming-addons/tree/master/piper) as the one
published on [Docker Hub](https://hub.docker.com/r/rhasspy/wyoming-piper) hasn't
yet been updated to version
[1.0.0](https://github.com/rhasspy/piper/releases/tag/v1.0.0).

## Tuning

More details on the available parameters in the Home Assistant documentation:

<https://github.com/home-assistant/addons/blob/master/piper/DOCS.md>

Note that for use as command-line arguments, underscores should be replaced with
hyphens (e.g. `length_scale` becomes `--length-scale`).
