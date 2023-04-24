# Lovelace Dashboard

This folder contains a single Lovelace dashboard (`home`) which manages my
entire home. It's used on all mobile devices and a tablet mounted on the Kitchen
wall.

Lovelace mode is set to `storage` to allow for easy experimentation and
prototyping via the UI. The only drawback is that custom Javascript modules and
custom CSS are thus also managed through the UI and not included as part of the
YAML configuration in this repository.

Below is an overview of the currently loaded custom Javascript modules and
custom CSS.

## Javascript modules

- `aarlo-glance.js?v=0.2.6.1`
- [`auto-entities.js?v=1.12.1`](https://github.com/thomasloven/lovelace-auto-entities)
- `card-mod.js?v=3.2.0`
- `compass-card.js?v=1.6.1`
- `hass-hue-icons.js?v=1.2.20`
- `home-assistant-sun-card.js?v=0.1.4`
- `layout-card.js?v=2.4.4`
- `logbook-card.js?v=1.9.3`
- `mini-graph-card-bundle.js?v=0.11.0`
- `paper-buttons-row.js?v=2.1.2`
- `simple-thermostat.js?v=2.5.0`
- `slider-entity-row.js?v=17.2.1`
- `vacuum-card.js?v=2.6.2`

## Custom CSS

- [`📄 /www/lovelace-home.css`](/www/lovelace-home.css)
