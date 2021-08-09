#!/usr/bin/env bash

files=$(git diff --name-only --cached | \
  xargs -I{} sh -c 'test -f "{}" && echo "{}"')

if [ -n "$files" ] ; then

  echo "Preparing to lint your changes -$(git diff --shortstat --cached)..."

  # Read all staged changes into the $MAPFILE array
  # Caveat: This lints the on-disk files (i.e. unstaged changes in these files
  # are also linted) – the sheer simplicity of the below solution outweighs this
  # minor drawback...
  readarray -t <<< "$files"
  npx prettier --check --ignore-unknown "${MAPFILE[@]}"

  # Again, but now only for YAML-files (as yamllint assumes all files passed in
  # to be YAML)
  files=$(echo "$files" | grep yaml)

  if [ -n "$files" ] ; then
    readarray -t <<< "$files"
    yamllint "${MAPFILE[@]}"
  fi

fi
