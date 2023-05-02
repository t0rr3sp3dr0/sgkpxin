#!/usr/bin/env bash
set -ETeux -o pipefail
shopt -s inherit_errexit 2> /dev/null || trap '<<< ${__:=${?#0}} ; ${__:+exit ${__}}' DEBUG

function pq {
	python3 -c "import plistlib,sys;print(plistlib.loads(sys.stdin.buffer.read())${*})"
}

CONF="${CONF:-$(dirname "${BASH_SOURCE[0]}")/conf.json}"
VARS="${VARS:-$(dirname "${BASH_SOURCE[0]}")/vars.json}"

TMP0="$(mktemp)"
TMP1="$(mktemp)"

echo '{}' > "${TMP1}"

ARCHS=( $(jq -r 'keys[]' "${CONF}") )
for ARCH in "${ARCHS[@]}"
do
	if [[ "${ARCH}" == '~' ]]
	then
		continue
	fi

	VARIANT="$(jq -r '."'"${ARCH}"'".variant' "${CONF}")"

	META="https://g.live.com/0USSDMC_W5T/StandaloneProductManifest"

	curl -Lfso "${TMP0}" "${META}"
	VERSION="$(pq '["ManifestArray"][0]["'"${VARIANT}"'PkgBinaryURL"]' < "${TMP0}" | sed -En 's|.*/([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)/.*|\1|p')"
	HASH="sha256-$(pq '["ManifestArray"][0]["'"${VARIANT}"'PkgSha256Hash"]' < "${TMP0}")"

	TIL="$(jq -c '."'"${ARCH}"'"."~" // {}' "${CONF}")"
	OUT="$(jq -S '. * { "'"${ARCH}"'": ( '"${TIL}"' * { hash: "'"${HASH}"'", meta: "'"${META}"'", variant: "'"${VARIANT}"'", version: "'"${VERSION}"'" } ) }' "${TMP1}")"

	cat <<< "${OUT}" > "${TMP1}"
done

rm -fv "${TMP0}"
mv -fv "${TMP1}" "${VARS}"
