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
  readarray -t md_files < <(printf "%s\n" "${files[@]}" | \
    grep -e '\.md' -e '\(TODO\|NOTES\|README\)')
  if
    [ ${#md_files[@]} -gt 0 ] && \
    ! npx --yes markdownlint-cli "${md_files[@]}"
  then
    status_code=1
  fi

  # YAMLlint
  readarray -t yaml_files < \
    <(printf "%s\n" "${files[@]}" | grep '\.ya\?ml')
  if
    [ ${#yaml_files[@]} -gt 0 ] && \
    ! yamllint "${yaml_files[@]}"
  then
    status_code=1
  fi

  # ShellCheck
  readarray -t sh_files < \
    <(printf "%s\n" "${files[@]}" | grep '\.sh')
  if
    [ ${#sh_files[@]} -gt 0 ] && \
    ! shellcheck --wiki-link-count=0 "${sh_files[@]}"
  then
    status_code=1
  fi

  # Haskell Dockerfile Linter (hadolint)
  readarray -t dockerfiles < \
    <(printf "%s\n" "${files[@]}" | grep 'Dockerfile')
  if
    [ ${#dockerfiles[@]} -gt 0 ] && \
    ! hadolint "${dockerfiles[@]}"
  then
    status_code=1
  fi

  # Notebooks – remind to clear cell outputs
  for f in $(printf "%s\n" "${files[@]}" | grep '\.\(ipy\|n\)nb') ; do
    cell_outputs="$(< "$f" jq '[.cells[].outputs | length] | add' )"
    if (( 10#$cell_outputs > 0 )) ; then
      # Only for notebooks not explicitly allowed in ".nb-allow"
      if ! grep -qs -f .nb-allow <<< "$f" ; then
        echo "❌ Notebook \"${f##*/}\" contains $cell_outputs cell output(s) – \
          clear them before committing..." | tr -s " "
        status_code=1
      else
        echo "🆗 Notebook \"${f##*/}\" contains $cell_outputs cell output(s)"
      fi
    fi
  done

fi

exit $status_code
