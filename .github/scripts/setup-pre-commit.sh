#!/usr/bin/env bash

set -euo pipefail

pip3 install 'pre-commit==3.3.3'
pip3 install 'yamllint==1.32.0'

# ShellCheck
if [ ! -x ~/.local/bin/shellcheck ]; then

  shellcheck_base=https://github.com/koalaman/shellcheck/releases/download
  shellcheck_version=v0.9.0

  wget -nv -O- \
    "${shellcheck_base}/${shellcheck_version}/shellcheck-${shellcheck_version}.linux.x86_64.tar.xz" |
    tar -xJv
  mv "shellcheck-${shellcheck_version}/shellcheck" ~/.local/bin
  rm -rf "shellcheck-${shellcheck_version}"

fi

# hadolint
if [ ! -x ~/.local/bin/hadolint ]; then

  hadolint_base=https://github.com/hadolint/hadolint/releases/download
  hadolint_version=v2.12.0

  wget -nv -O ~/.local/bin/hadolint \
    "${hadolint_base}/${hadolint_version}/hadolint-Linux-x86_64"
  chmod +x ~/.local/bin/hadolint

fi

# shfmt
if [ ! -x ~/.local/bin/shfmt ]; then

  shfmt_base=https://github.com/mvdan/sh/releases/download
  shfmt_version=v3.7.0

  wget -nv -O ~/.local/bin/shfmt \
    "${shfmt_base}/${shfmt_version}/shfmt_${shfmt_version}_linux_amd64"
  chmod +x ~/.local/bin/shfmt

fi
