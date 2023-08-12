# Piper / Wyoming

Still early days, but seems to be working just fine...

I'm running the
[`wyoming-piper` container](https://hub.docker.com/r/rhasspy/wyoming-piper) on a
separate machine and am using it in Home Assistant for all my TTS needs. See
[`📄 docker-compose.yml`](./docker-compose.yml) for detailed configuration.

❗ **N.B.** As of Home Assistant **2023.8**, it appears
[version **`1.2.0`** of `wyoming-piper`](https://github.com/home-assistant/core/issues/97439#issuecomment-1656805050)
is required.

As of version `1.2.0`, voice models are automatically downloaded from Hugging
Face and it is thus possible to dynamically choose/switch models from within
Home Assistant (take note of the caveats below).

Two caveats (as of `1.2.0`):

1. A default voice model still needs to be provided to `piper` (e.g.
   `--voice en_US-amy-low`), otherwise the container will not start
2. After on-demand downloading of an additional voice model, `wyoming-piper`
   seems to run itself into the ground. To resolve: Restart the container _and_
   reload the
   [Home Assistant Piper integration](https://www.home-assistant.io/integrations/piper/)
   – now the new voice model works (rinse and repeat for further models)

## Tuning

More details on the available parameters in the Home Assistant documentation:

<https://github.com/home-assistant/addons/blob/master/piper/DOCS.md>

Note that for use as command-line arguments, underscores should be replaced with
hyphens (e.g. `length_scale` becomes `--length-scale`).
