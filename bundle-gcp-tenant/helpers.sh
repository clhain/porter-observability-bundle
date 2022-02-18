#!/usr/bin/env bash

set -euo pipefail

next_slash_24() {
    local IFS
    IFS=.
    set -- $*
    next=$(($3+1))
    if(($next>254)); then
      echo "IP Range Out of Bounds"
      exit 1
    fi
    echo "{\"next_vpc_subnet\": \"$1.$2.$next.$4\"}"
}

next_vpc_subnet() {
  last=$(gcloud compute networks subnets list --project=${1} --filter="region:(${2}) AND ${3}" --format=value"(ipCidrRange)" --sort-by ~ipCidrRange --limit 1)
  if [ -z "$last" ]; then
      echo "There appear to be no Applab Site networks here..."
      exit 1
  fi
  next_slash_24 ${last}
}

"$@"
