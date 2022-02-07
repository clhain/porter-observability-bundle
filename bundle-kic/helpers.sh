#!/usr/bin/env bash
set -euo pipefail
handle-chart-values() {
    if [ "$1" = true ] ; then
        mv ./chart-values-plus.yaml ./chart-values.yaml
    fi
    if grep -q '[^[:space:]]' ./chart-values-custom.yaml; then
        mv ./chart-values-custom.yaml ./chart-values.yaml
    fi
}

# Call the requested function and pass the arguments as-is
"$@"