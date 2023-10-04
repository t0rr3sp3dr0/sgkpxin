#!/bin/bash
set -ETeux -o 'pipefail'
shopt -s 'inherit_errexit' 2> /dev/null || trap '<<< ${__:=${?#0}} ; ${__:+exit ${__}}' DEBUG

CONF="${CONF:-$(dirname "${BASH_SOURCE[0]}")/conf.json}"

cat <<< "$(jq -S '.' "${CONF}")" > "${CONF}"
