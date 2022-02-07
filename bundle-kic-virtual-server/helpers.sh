#!/usr/bin/env bash

set -euo pipefail

render() {
  for xvar in "$@"
  do
      var=`echo -n ${xvar} | sed 's/"//g'`
      echo "$var"
      export $var
  done
  mkdir -p manifests/rendered
  for f in manifests/*.yaml
  do
    echo "Rendering variables in $f"
    base="$(basename $f)"
    envsubst < $f > manifests/rendered/$base
  done
}

echo "$@"
"$@"
