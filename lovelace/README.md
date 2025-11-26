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
- [`card-mod.js?v=3.4.6`](https://github.com/thomasloven/lovelace-card-mod/releases/tag/3.4.6)
- [`compass-card.js?v=3.2.2`](https://github.com/tomvanswam/compass-card/releases/tag/v3.2.2)
- [`hass-hue-icons.js?v=1.2.51`](https://github.com/arallsopp/hass-hue-icons/releases/tag/v1.2.51)
- `home-assistant-sun-card.js?v=0.1.4`
- [`layout-card.js?v=2.4.7`](https://github.com/thomasloven/lovelace-layout-card/releases/tag/v2.4.7)
- [`logbook-card.js?v=2.5.5`](https://github.com/royto/logbook-card/releases/tag/2.5.5)
- [`mini-graph-card-bundle.js?v=0.13.0`](https://github.com/kalkih/mini-graph-card/releases/tag/v0.13.0)
- [`paper-buttons-row.js?v=2.3.1`](https://github.com/jcwillox/lovelace-paper-buttons-row/releases/tag/2.3.1)
- [`slider-entity-row.js?v=17.5.0`](https://github.com/thomasloven/lovelace-slider-entity-row/releases/tag/17.5.0)
- [`vacuum-card.js?v=2.11.0`](https://github.com/denysdovhan/vacuum-card/releases/tag/v2.11.0)
  - Including the changes from
    [`denysdovhan/vacuum-card#1025`](https://github.com/denysdovhan/vacuum-card/pull/1025)

## Custom CSS

- [`📄 /www/lovelace-home.css`](/www/lovelace-home.css)
