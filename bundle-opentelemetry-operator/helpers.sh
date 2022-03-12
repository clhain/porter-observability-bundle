#!/usr/bin/env bash
set -euo pipefail
handle-chart-values() {
    if [ "$1" = true ] ; then
        mv ./chart-values/rendered/chart-values-plus.yaml ./chart-values.yaml
    else
        mv ./chart-values/rendered/chart-values.yaml ./chart-values.yaml
    fi
    if grep -q '[^[:space:]]' ./chart-values-custom.yaml; then
        mv ./chart-values-custom.yaml ./chart-values.yaml
    fi
}

render() {
  for xvar in "$@"
  do
      var=`echo -n ${xvar} | sed 's/"//g'`
      echo "$var"
      export $var
  done
  mkdir -p chart-values/rendered
  for f in chart-values/*.yaml
  do
    echo "Rendering variables in $f"
    base="$(basename $f)"
    envsubst '\$LOADBALANCER_IP \$LOADBALANCER_TYPE' < $f > chart-values/rendered/$base
  done
}

# Call the requested function and pass the arguments as-is
"$@"