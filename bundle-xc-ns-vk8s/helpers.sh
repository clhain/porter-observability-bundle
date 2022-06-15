#!/usr/bin/env bash

set -euo pipefail

render_volt_creds() {
  cat /cnab/app/.volterra/creds.p12.b64 | base64 -d  > ${VOLT_API_P12_FILE}
}

echo "$@"
"$@"
