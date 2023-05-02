#!/usr/bin/env bash
set -ETeux -o pipefail
shopt -s inherit_errexit 2> /dev/null || trap '<<< ${__:=${?#0}} ; ${__:+exit ${__}}' DEBUG

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

	CODE="$(jq -r '."'"${ARCH}"'".code' "${CONF}")"
	PLAT="$(jq -r '."'"${ARCH}"'".plat' "${CONF}")"
	TYPE="$(jq -r '."'"${ARCH}"'".type' "${CONF}")"
	
	LIVE="https://download.jetbrains.com/product?code=${CODE}&platform=${PLAT}&release.type=${TYPE}"
	META="https://data.services.jetbrains.com/products/releases?code=${CODE}&latest=true&type=${TYPE}"

	curl -Lfso "${TMP0}" "${META}"
	BUILD="$(jq -r '.[] | first.build' "${TMP0}")"
	VERSION="$(jq -r '.[] | first.version' "${TMP0}")"
	CHECKSUM_LINK="$(jq -r '.[] | first.downloads."'"${PLAT}"'".checksumLink' "${TMP0}")"

	curl -Lfso "${TMP0}" "${CHECKSUM_LINK}"
	HASH="sha256-$(awk '{ print $1; }' "${TMP0}" | xxd -r -p | base64)"

	TIL="$(jq -c '."'"${ARCH}"'"."~" // {}' "${CONF}")"
	OUT="$(jq -S '. * { "'"${ARCH}"'": ( '"${TIL}"' * { buildno: "'"${BUILD}"'", hash: "'"${HASH}"'", live: "'"${LIVE}"'", meta: "'"${META}"'", version: "'"${VERSION}"'" } ) }' "${TMP1}")"

	cat <<< "${OUT}" > "${TMP1}"
done

rm -fv "${TMP0}"
mv -fv "${TMP1}" "${VARS}"
