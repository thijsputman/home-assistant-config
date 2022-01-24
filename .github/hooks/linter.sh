#!/usr/bin/env bash

# Get all staged files. This will lint the on-disk files (i.e. unstaged changes
# in the files are also linted) – the sheer simplicity of the solution outweighs
# this minor drawback...
files=$(git diff --name-only --cached --diff-filter=ACMR | sed 's| |\\ |g')

status_code=0

if [ -n "$files" ] ; then

  echo "Preparing to lint your changes -$(git diff --shortstat --cached)..."

  # Prettier
  readarray -t <<< "$files"
  if ! npx --yes prettier --check --ignore-unknown "${MAPFILE[@]}"
    then status_code=1 ; fi

  # MarkdownLint
  md_files=$(echo "$files" | grep -e .md -e TODO)
  if [ -n "$md_files" ] ; then
    readarray -t <<< "$md_files"
    if ! npx --yes markdownlint-cli "${MAPFILE[@]}"
      then status_code=1 ; fi
  fi

  # YAMLlint
  yaml_files=$(echo "$files" | grep .yaml)
  if [ -n "$yaml_files" ] ; then
    readarray -t <<< "$yaml_files"
    if ! yamllint "${MAPFILE[@]}"
      then status_code=1 ; fi
  fi

fi

exit $status_code
