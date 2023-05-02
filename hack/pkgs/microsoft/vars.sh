#!/usr/bin/env bash
set -ETeux -o pipefail
shopt -s inherit_errexit 2> /dev/null || trap '<<< ${__:=${?#0}} ; ${__:+exit ${__}}' DEBUG

function cat2sha {
	local CAT2SHA="$(which cat2sha || true)"
	local CAT2SHA="${CAT2SHA:-$(dirname ${TMP0})/cat2sha}"

	if [[ ! -x "${CAT2SHA}" ]]
	then
		local OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

		local ARCH="$(uname -m)"
		case "${ARCH}" in
			'aarch64')
				ARCH='arm64'
				;;

			'x86_64')
				ARCH='amd64'
				;;
		esac

		curl -Lfso "${CAT2SHA}" 'https://api.github.com/repos/t0rr3sp3dr0/cat2sha/releases/latest'
		local LINK=$(jq -r '.assets[] | select(.name | endswith("_'"${OS}"'_'"${ARCH}"'")).browser_download_url' "${CAT2SHA}")

		curl -Lfso "${CAT2SHA}" "${LINK}"
		chmod +x "${CAT2SHA}"
	fi

	"${CAT2SHA}"
}

function guid {
	case "${*}" in
    	'Beta')
			echo -n '4B2D7701-0A4F-49C8-B4CB-0C2D4043F51F'
			;;

    	'CurrentThrottle')
			echo -n 'A1E15C18-4D18-40B0-8577-616A9470BB10'
			;;

    	'Current')
			echo -n 'C1297A47-86C4-4C1F-97FA-950631F94777'
			;;

    	'Preview')
			echo -n '1ac37578-5a24-40fb-892e-b89d85b6dfaa'
			;;

    	'Dogfood')
			echo -n 'e2e9e618-e7cc-4681-a831-2f1eb16e7354'
			;;

    	'Internal')
			echo -n '03adf619-38c6-4249-95ff-4a01c0ffc962'
			;;

		*)
			false
			;;
	esac
}

function meta {
	local BASE="https://officecdnmac.microsoft.com/pr/${GUID}/MacAutoupdate/0409${PROD}"

	case "${*}" in
		'cat')
			echo -n "${BASE}.cat"
			;;

		'plist')
			echo -n "${BASE}.xml"
			;;

		'plist-chk')
			echo -n "${BASE}-chk.xml"
			;;

		'plist-history')
			echo -n "${BASE}-history.xml"
			;;

		*)
			false
			;;
	esac
}

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

	CHAN="$(jq -r '."'"${ARCH}"'".chan' "${CONF}")"
	LIVE="$(jq -r '."'"${ARCH}"'".live' "${CONF}")"
	PROD="$(jq -r '."'"${ARCH}"'".prod' "${CONF}")"

	GUID="$(guid "${CHAN}")"
	META="$(meta plist)"

	case "${PROD}" in
		'EDGE01' | 'EDBT01' | 'EDDV01' | 'EDCN01' | 'IMCP01' | 'MSRD10' | 'TEAMS10')
			LINK="${META}"
			curl -Lfso "${TMP0}" "${LINK}"

			VERSION="$(pq '[0]["Title"]' < "${TMP0}" | awk '{ print $NF; }')"
			;;

		*)
			LINK="$(meta plist-chk)"
			curl -Lfso "${TMP0}" "${LINK}"

			VERSION="$(pq '["Update Version"]' < "${TMP0}")"
			;;
	esac

	case "${PROD}" in
		'EDGE01' | 'EDBT01' | 'EDDV01' | 'EDCN01')
			LINK="${META}"
			curl -Lfso "${TMP0}" "${LINK}"

			LOCATION="$(pq '[0]["Location"]' < "${TMP0}")"

			OLD='Update-'
			NEW='-'
			LOCATION="${LOCATION/${OLD}/${NEW}}"

			if [[ "${ARCH}" == 'x86_64-darwin' ]]
			then
				OLD="/$(guid Internal)/"
				NEW="/$(guid Current)/"
				LOCATION="${LOCATION/${OLD}/${NEW}}"
			fi

			LINK="${LOCATION}"
			curl -Lfso "${TMP0}" "${LINK}"

			HASH="sha256-$(shasum -a 256 -b "${TMP0}" | awk '{ print $1; }' | xxd -r -p | base64)"
			;;

		'WDAV00')
			LINK="${META}"
			curl -Lfso "${TMP0}" "${LINK}"

			LOCATION="$(pq '[0]["Location"]' < "${TMP0}")"

			OLD='-upgrade.'
			NEW="-${VERSION}."
			LOCATION="${LOCATION/${OLD}/${NEW}}"

			LINK="${LOCATION}"
			curl -Lfso "${TMP0}" "${LINK}"

			HASH="sha256-$(shasum -a 256 -b "${TMP0}" | awk '{ print $1; }' | xxd -r -p | base64)"
			;;

		*)
			LINK="$(meta cat)"
			curl -Lfso "${TMP0}" "${LINK}"

			HASH="sha256-$(cat2sha < "${TMP0}" | grep -E '\.pkg$' | grep -v 'Delta' | sed -En 's|([0-9a-f]+) [ *](.+)|\2\x1F\1|p' | sort -V | tail -n 1 | awk -F $'\x1F' '{ print $NF; }' | xxd -r -p | base64)"
	esac

	TIL="$(jq -c '."'"${ARCH}"'"."~" // {}' "${CONF}")"
	OUT="$(jq -S '. * { "'"${ARCH}"'": ( '"${TIL}"' * { guid: "'"${GUID}"'", hash: "'"${HASH}"'", live: "'"${LIVE}"'", meta: "'"${META}"'", version: "'"${VERSION}"'" } ) }' "${TMP1}")"

	cat <<< "${OUT}" > "${TMP1}"
done

rm -fv "${TMP0}"
mv -fv "${TMP1}" "${VARS}"
