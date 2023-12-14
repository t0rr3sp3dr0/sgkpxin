#!/bin/bash
set -ETeux -o 'pipefail'
shopt -s 'inherit_errexit' 2> /dev/null || trap '<<< ${__:=${?#0}} ; ${__:+exit ${__}}' DEBUG

make -BC ./ attr.json
make -BC ../pkgs/ all

REMOTE="$(git rev-parse --symbolic-full-name '@{u}' || git remote)"
REMOTE="$(<<< "${REMOTE}" | cut -d '/' -f '3' | head -n '1')"

git remote set-head "${REMOTE}" -a

STATUS="$(git status --porcelain='v1')"

PKGS=( $(<<< "${STATUS}" | sed -En 's|^...pkgs/([^/]+)/.+$|\1|p' | sort | uniq) )
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

    git add -v ":/pkgs/${PKG}"
    git commit -m "bump ${PKG}"

    HASH="$(git rev-parse 'HEAD')"

    sed -E 's/(": ")HEAD(")/\1'"${HASH}"'\2/g' "${VERS}" > "${TEMP}"
    jq -S '.' "${TEMP}" > "${VERS}"

    git add -v ":/pkgs/${PKG}"
    git commit -m "vers ${PKG}"

    rm -fv "${TEMP}"

    git push -f "${REMOTE}" "HEAD:refs/heads/${BRANCH}"

    PR_S="$(gh pr view "${BRANCH}" --json 'state' --jq '.state' || true)"
    if [[ "${PR_S}" != 'OPEN' ]]
    then
        # https://github.com/cli/cli/issues/5896
        git checkout -B "${BRANCH}"

        gh pr create -f

        # https://github.com/cli/cli/issues/4801
        sleep 15
    fi
    PR_N="$(gh pr view "${BRANCH}" --json 'number' --jq '.number')"

    gh pr merge "${PR_N}" -m --auto

    # gh workflow run 'test.yaml' -r "refs/heads/${BRANCH}"
    # gh workflow run 'test.yaml' -r "refs/pull/${PR_N}/merge"
done
