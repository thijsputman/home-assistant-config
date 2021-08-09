# Home Assistant Configuration

[![Lint codebase](https://github.com/thijsputman/home-assistant-config/actions/workflows/linter.yml/badge.svg?branch=main)](https://github.com/thijsputman/home-assistant-config/actions/workflows/linter.yml)

The _live_ configuration of my personal Home Assistant instance.

## Development

### Linter / Pre-commit hook

A combination of [Prettier](https://prettier.io/) and
[`yamllint`](https://github.com/adrienverge/yamllint) is used via a pre-commit
hook to ensure consistent YAML-formatting.

To set up this pre-commit hook, follow the below instructions. This assumes NPM
and Python3/`pip` are installed on your system:

```shell
pip3 install --user yamllint

{
  echo '#!/bin/sh'
  echo "exec .github/hooks/linter.sh"
} > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Further Reading

- [`📄 TODO`](./TODO)
- [`📁 custom_components/`](./custom_components/README.md)
- [`📁 docs/`](./docs/README.md)
- [`📁 extras/`](./extras/README.md)
- [`📁 lovelace/`](./lovelace/README.md)

## License

This repository is licensed under a
[Creative Commons Zero v1.0 Universal license](./LICENSE), except for the
contents of the [`📁 docs/`](./docs) and the [`📁 extras/`](./extras) folders
which are licensed under a
[Creative Commons Attribution Share Alike 4.0 International license](./docs/LICENSE)
and a [BSD-3-Clause license](./extras/LICENSE) respectively.
