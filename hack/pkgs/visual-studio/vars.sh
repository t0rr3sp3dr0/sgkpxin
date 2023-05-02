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

	GENERIC="$(jq -r '."'"${ARCH}"'".generic' "${CONF}")"

	META="https://aka.ms/vsmac/manifest/17-stable"

	curl -Lfso "${TMP0}" "${META}"
	VERSION="$(jq -r '.items[] | select(.genericName == "'"${GENERIC}"'").version' "${TMP0}")"
	HASH="sha256-$(jq -r '.items[] | select(.genericName == "'"${GENERIC}"'").sha256' "${TMP0}" | xxd -r -p | base64)"
	GUID="$(jq -r '.items[] | select(.genericName == "'"${GENERIC}"'").url | capture("(?<_>[0-9a-f]{32})")._' "${TMP0}")"
	UUID="$(jq -r '.items[] | select(.genericName == "'"${GENERIC}"'").url | capture("(?<_>[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})")._' "${TMP0}")"

	TIL="$(jq -c '."'"${ARCH}"'"."~" // {}' "${CONF}")"
	OUT="$(jq -S '. * { "'"${ARCH}"'": ( '"${TIL}"' * { guid: "'"${GUID}"'", hash: "'"${HASH}"'", meta: "'"${META}"'", uuid: "'"${UUID}"'", version: "'"${VERSION}"'" } ) }' "${TMP1}")"

	cat <<< "${OUT}" > "${TMP1}"
done

rm -fv "${TMP0}"
mv -fv "${TMP1}" "${VARS}"
