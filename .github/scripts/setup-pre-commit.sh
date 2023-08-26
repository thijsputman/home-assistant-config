#!/usr/bin/env bash

set -euo pipefail

pip3 install pre-commit
pip3 install yamllint

npm install prettier
npm install markdownlint-cli

# hadolint

if [ ! -x "${HOME}/.local/bin/hadolint" ]; then

  hadolint_base=https://github.com/hadolint/hadolint/releases/download
  wget -nv -O "${HOME}/.local/bin/hadolint" \
    "${hadolint_base}/${HADOLINT_VERSION}/hadolint-Linux-x86_64"
  chmod +x "${HOME}/.local/bin/hadolint"

fi

# shfmt

if [ ! -x "${HOME}/.local/bin/shfmt" ]; then

  shfmt_base=https://github.com/mvdan/sh/releases/download
  wget -nv -O "${HOME}/.local/bin/shfmt" \
    "${shfmt_base}/${SHFMT_VERSION}/shfmt_${SHFMT_VERSION}_linux_amd64"
  chmod +x "${HOME}/.local/bin/shfmt"

fi
