# Home Assistant Configuration

[![Lint codebase](https://github.com/thijsputman/home-assistant-config/actions/workflows/linter.yml/badge.svg?branch=main)](https://github.com/thijsputman/home-assistant-config/actions/workflows/linter.yml)
[![Docker — sysmon-mqtt](https://github.com/thijsputman/home-assistant-config/actions/workflows/docker-sysmon-mqtt.yml/badge.svg)](https://github.com/thijsputman/home-assistant-config/actions/workflows/docker-sysmon-mqtt.yml)

The _live_ configuration of my personal Home Assistant instance.

## Development

### Linter / Pre-commit hook

A combination of [Prettier](https://prettier.io/),
[`markdownlint-cli`](https://github.com/igorshubovych/markdownlint-cli),
[`yamllint`](https://github.com/adrienverge/yamllint),
[ShellCheck](https://www.shellcheck.net/), and
[`hadolint`](https://github.com/hadolint/hadolint) is used via a pre-commit hook
to ensure consistent formatting and – where possible – more elaborate
sanity-checking.

To set up the pre-commit hook, follow the below instructions. This assumes a
system running Ubuntu with NPM, and Python3/`pip` already installed:

```shell
sudo apt install jq
sudo apt install shellcheck

pip install --user yamllint
# or, even better
pip install --user pipx
pipx install yamllint

# Assumes ~/.local/bin is on your $PATH
arch=$(dpkg --print-architecture)
wget -O ~/.local/bin/hadolint \
  "https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-${arch}"
chmod +x ~/.local/bin/hadolint

{
  echo "#!/bin/sh"
  echo "exec .github/hooks/linter.sh"
} > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Extras

Apart from the Home Assistant configuration, this repository contains several
"extras" that form a part of my Home Assistant setup too.

Thee most relevant ones are:

- [📦 TC66C – MQTT Bridge](https://github.com/thijsputman/tc66c-mqtt)
- [📦 Simple system monitoring over MQTT](./extras/sysmon-mqtt/README.md)

For a complete overview see the [`📁 extras/`](./extras/README.md) folder.

## Further Reading

- [`📄 TODO`](./TODO)
- [`📁 custom_components/`](./custom_components/README.md)
- [`📁 docs/`](./docs/README.md)
- [`📁 lovelace/`](./lovelace/README.md)

## License

This repository is licensed under a
[Creative Commons Zero v1.0 Universal license](./LICENSE), except for the
contents of the [`📁 docs/`](./docs) and the [`📁 extras/`](./extras) folders
which are licensed under a
[Creative Commons Attribution Share Alike 4.0 International license](./docs/LICENSE)
and a [BSD-3-Clause license](./extras/LICENSE) respectively.
