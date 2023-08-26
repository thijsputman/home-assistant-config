#!/usr/bin/env bash

rc=0

for f in "$@"; do

  cell_outputs="$(jq < "$f" '[.cells[].outputs | length] | add')"

  if ((10#$cell_outputs > 0)); then

    # Only for notebooks not explicitly allowed in ".nb-allow"
    if ! grep -qs -f .nb-allow <<< "$f"; then
      echo "📓 $f contains $cell_outputs cell output(s) – \
        clear them before continuing..." | tr -s " "
      rc=1

    fi

  fi

done

exit $rc
