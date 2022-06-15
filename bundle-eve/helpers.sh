#!/usr/bin/env bash

set -euo pipefail

render() {
  for xvar in "$@"
  do
      var=`echo -n ${xvar} | sed 's/"//g'`
      export $var
      # Export additional vars as base64 representation of value for use as secrets.
      # Format of additional var name is ENVVAR_NAME => ENVVAR_NAME_BASE64
      arrIN=(${var//=/ })
      echo "${arrIN[0]}"
      # varB64=`echo -n ${arrIN[1]} | base64 -w0`
      # export "${arrIN[0]}_BASE64=${varB64}"
  done
  mkdir -p manifest/rendered
  for f in manifest/*.yaml
  do
    echo "Rendering variables in $f"
    base="$(basename $f)"
    envsubst < $f > manifest/rendered/$base
  done
}

configure() {
  curl -X POST ${1} -d '{"branch":"'${GITHUB_BRANCH}'", "dest":"/unitapps/app", "repo":"'${GITHUB_REPO}'"}' -H 'content-type: application/json' --connect-timeout 2 -s -D - -o /dev/null 2>/dev/null | head -n1 | grep 200
}

activate() {
  while ! configure "$1"; do
    echo wait for app... 
    sleep 3
  done
}

render_volt_creds() {
  cat /root/.volterra/creds.p12.b64 | base64 -d  > ${VOLT_API_P12_FILE}
}

echo "$@"
"$@"
