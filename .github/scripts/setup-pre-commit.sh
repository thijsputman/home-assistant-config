#!/usr/bin/env bash

set -euo pipefail

: "${USE_PIPX:=true}"

if ! [[ $PATH =~ (^|:)"${HOME}/.local/bin"(:|$) ]]; then
  # shellcheck disable=SC2088
  echo '~/.local/bin is not on PATH; aborting...'
  exit 1
fi

pip_cmd=pip3
if [ "$USE_PIPX" == true ]; then
  pip3 install --user pipx
  pip_cmd=pipx
fi

$pip_cmd install 'pre-commit==3.3.3'
$pip_cmd install 'yamllint==1.32.0'

# ShellCheck
if [ ! -x ~/.local/bin/shellcheck ]; then

  arch=$(uname -m)
  shellcheck_base=https://github.com/koalaman/shellcheck/releases/download
  shellcheck_version=v0.9.0

  wget -nv -O- \
    "${shellcheck_base}/${shellcheck_version}/shellcheck-${shellcheck_version}.linux.${arch}.tar.xz" |
    tar -xJv
  mv "shellcheck-${shellcheck_version}/shellcheck" ~/.local/bin
  rm -rf "shellcheck-${shellcheck_version}"

  command -v shellcheck

fi

# hadolint
if [ ! -x ~/.local/bin/hadolint ]; then

  arch=$(uname -m)
  hadolint_base=https://github.com/hadolint/hadolint/releases/download
  hadolint_version=v2.12.0

  wget -nv -O ~/.local/bin/hadolint \
    "${hadolint_base}/${hadolint_version}/hadolint-Linux-${arch}"
  chmod +x ~/.local/bin/hadolint

  command -v hadolint

fi

# shfmt
if [ ! -x ~/.local/bin/shfmt ]; then

  arch=$(dpkg --print-architecture)
  shfmt_base=https://github.com/mvdan/sh/releases/download
  shfmt_version=v3.7.0

  wget -nv -O ~/.local/bin/shfmt \
    "${shfmt_base}/${shfmt_version}/shfmt_${shfmt_version}_linux_${arch}"
  chmod +x ~/.local/bin/shfmt

  command -v shfmt

fi
