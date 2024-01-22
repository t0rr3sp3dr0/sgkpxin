#!/bin/bash
set -ETeux -o 'pipefail'
shopt -s 'inherit_errexit' 2> /dev/null || trap '<<< ${__:=${?#0}} ; ${__:+exit ${__}}' DEBUG

REMOTE="$(git rev-parse --symbolic-full-name '@{u}' || git remote)"
REMOTE="$(cut -d '/' -f '3' <<< "${REMOTE}")"
REMOTE="$(head -n '1' <<< "${REMOTE}")"

git remote set-head "${REMOTE}" -a

DIFF="$(git diff --cached --name-status "refs/remotes/${REMOTE}/HEAD")"

NPKG="$(sed -E '\|^.+\tpkgs/.+/[^/]+$|d' <<< "${DIFF:-M\t.}")"
if [ ! -z "${NPKG}" ]
then
    nix eval --show-trace --write-to ./attr.json -f ./attr.nix
else
    PKGS="$(sed -En 's|^.+\tpkgs/(.+)/[^/]+$|\1|p' <<< "${DIFF}")"
    PKGS="$(tr '/' '#' <<< "${PKGS}")"
    PKGS="$(sort -r <<< "${PKGS}")"
    PKGS="$(awk '!s0[$0]++ && split($0, a0, "#") && (!s1[a0[1]]++ || a0[2])' <<< "${PKGS}")"

    jq -Rcn '[ inputs ]' <<< "${PKGS}" > ./attr.json
fi
