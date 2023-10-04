#!/bin/bash
set -ETeux -o 'pipefail'
shopt -s 'inherit_errexit' 2> /dev/null || trap '<<< ${__:=${?#0}} ; ${__:+exit ${__}}' DEBUG

REMOTE="$(git rev-parse --symbolic-full-name '@{u}' | cut -d '/' -f '3')"

git remote set-head "${REMOTE}" -a

DIFF="$(git diff --cached --name-status "refs/remotes/${REMOTE}/HEAD")"

NPKG="$(sed -E '\|^.+\t(hack/)?pkgs/[^/]+/.+$|d' <<< "${DIFF:-M\t.}")"
if [ ! -z "${NPKG}" ]
then
    nix eval --show-trace --write-to ./attr.json -f ./attr.nix
else
    sed -En 's|^.+\t(hack/)?pkgs/([^/]+)/.+$|\2|p' <<< "${DIFF}" | sort | uniq | jq -Rcn '[inputs]' > ./attr.json
fi
