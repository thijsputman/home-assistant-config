#!/usr/bin/env bash

status_code=0

# Get all staged files. This will lint the on-disk files (i.e. unstaged changes
# in the files are also linted) – the sheer simplicity of the solution outweighs
# this minor drawback...
readarray -t files < \
  <(git diff --name-only --cached --diff-filter=ACMR | sed 's| |\\ |g')

if [ ${#files[@]} -gt 0 ] ; then

  echo "Preparing to lint your changes -$(git diff --shortstat --cached)..."

  # Prettier
  if ! npx --yes prettier --check --ignore-unknown "${files[@]}"
    then status_code=1 ; fi

  # MarkdownLint
  read -ra md_files < \
    <(echo "${files[@]}" | grep -e '\.md' -e '\(TODO\|NOTES\|README\)')
  if
    [ ${#md_files[@]} -gt 0 ] && \
    ! npx --yes markdownlint-cli "${md_files[@]}"
  then
    status_code=1
  fi

  # YAMLlint
  read -ra yaml_files < \
    <(echo "${files[@]}" | grep '\.ya\?ml')
  if
    [ ${#yaml_files[@]} -gt 0 ] && \
    ! yamllint "${yaml_files[@]}"
  then
    status_code=1
  fi

  # ShellCheck
  read -ra sh_files < \
    <(echo "${files[@]}" | grep '\.sh')
  if
    [ ${#sh_files[@]} -gt 0 ] && \
    ! shellcheck --wiki-link-count=0 "${sh_files[@]}"
  then
    status_code=1
  fi

  # Haskell Dockerfile Linter (hadolint)
  read -ra dockerfiles < \
    <(echo "${files[@]}" | grep 'Dockerfile')
  if
    [ ${#dockerfiles[@]} -gt 0 ] && \
    ! hadolint "${dockerfiles[@]}"
  then
    status_code=1
  fi

  # Notebooks – remind to clear cell outputs
  for f in $(echo "${files[@]}" | grep '\.\(ipy\|n\)nb') ; do
    if (( "$(< "$f" jq '[.cells[].outputs | length] | add' )" > 0 )) ; then
      echo "❌ Notebook \"${f##*/}\" contains cell output(s) – \
        clear them before committing..." | tr -s " "
      status_code=1
    fi
  done

fi

exit $status_code
