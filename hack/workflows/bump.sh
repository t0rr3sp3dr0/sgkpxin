#!/bin/bash
set -ETeux -o 'pipefail'
shopt -s 'inherit_errexit' 2> /dev/null || trap '<<< ${__:=${?#0}} ; ${__:+exit ${__}}' DEBUG

make -BC ./ attr.json
make -BC ../pkgs/ all

REMOTE="$(git rev-parse --symbolic-full-name '@{u}' || git remote)"
REMOTE="$(cut -d '/' -f '3' <<< "${REMOTE}")"
REMOTE="$(head -n '1' <<< "${REMOTE}")"

git remote set-head "${REMOTE}" -a

STATUS="$(git status --porcelain='v1')"

PKGS="$(sed -En 's|^...pkgs/([^/]+)/.+$|\1|p' <<< "${STATUS}")"
PKGS="$(sort <<< "${PKGS}")"
PKGS="$(uniq <<< "${PKGS}")"

PKGS=( $(cat <<< "${PKGS}") )
for PKG in "${PKGS[@]}"
do
    if ! jq -e 'any(. == "'"${PKG}"'")' ./attr.json
    then
        continue
    fi

    BRANCH="bump/${PKG}"

    git checkout -d "refs/remotes/${REMOTE}/HEAD"

    TEMP="$(mktemp -d)/vers.json"
    VERS="../../pkgs/${PKG}/vers.json"

    nix eval --show-trace --write-to "${TEMP}" -f './vers.nix' <<< "${PKG}"
    jq -S '.' "${TEMP}" > "${VERS}"

    VER="$(jq -r 'to_entries | map({ key, value: .value | last(to_entries[] | select(.value == "HEAD").key) }) | group_by(.value) | map("\(.[0].value)@\(map(.key | sub("-darwin"; "")) | join(","))") | join(" ")' "${VERS}")"

    git add -v ":/pkgs/${PKG}"
    git commit -m "bump ${PKG} to ${VER}"

    HASH="$(git rev-parse 'HEAD')"

    sed -E 's/(": ")HEAD(")/\1'"${HASH}"'\2/g' "${VERS}" > "${TEMP}"
    jq -S '.' "${TEMP}" > "${VERS}"

    git add -v ":/pkgs/${PKG}"
    git commit -m "vers ${PKG} at ${HASH} as ${VER}"

    rm -fv "${TEMP}"

    git push -f "${REMOTE}" "HEAD:refs/heads/${BRANCH}"

    PR_S="$(gh pr view "${BRANCH}" --json 'state' --jq '.state' || true)"
    if [[ "${PR_S}" != 'OPEN' ]]
    then
        # https://github.com/cli/cli/issues/5896
        git checkout -B "${BRANCH}"

        gh pr create -F '/dev/null' -t "${BRANCH}"

        # https://github.com/cli/cli/issues/4801
        sleep 15
    fi
    PR_N="$(gh pr view "${BRANCH}" --json 'number' --jq '.number')"
done
