#!/usr/bin/env bash

set -euo pipefail

render_volt_creds() {
  mkdir -p /cnab/app/.volterra/
  cat /cnab/app/.creds/creds.p12.b64 | base64 -d  > ${VOLT_API_P12_FILE}
}

echo "$@"
"$@"
