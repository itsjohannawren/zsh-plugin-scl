#!/bin/bash

__JWALTER_SCL_USE=()
__JWALTER_SCL_BASE="/opt"

scl() {
	local SCL_PATH LINE

	case "${1}" in
		use)
			if [ -z "${2}" ]; then
				echo "Error: Collection name required" 1>&2
				return 1
			fi

			if grep -q / <<<"${2}"; then
				SCL_PATH="${2}"
			else
				SCL_PATH="$(find "${__JWALTER_SCL_BASE}" -mindepth 2 -maxdepth 2 -type d -name "${2}" | sed -e "s|${__JWALTER_SCL_BASE}/||")"
			fi
			if [ "$(wc -l <<<"${SCL_PATH}" | awk '{print $1}')" -gt 1 ]; then
				echo "Error: Multiple matching collecions, please be more specific" 1>&2
				#shellcheck disable=2162
				while read LINE; do
					echo " * ${LINE}" 1>&2
				done <<<"${SCL_PATH}"
				return 1
			elif [ -z "${SCL_PATH}" ]; then
				echo "Error: Unknown SCL: ${2}" 1>&2
				return 1
			fi
			if [ ! -d "${__JWALTER_SCL_BASE}/${SCL_PATH}" ]; then
				echo "Error: Unknown SCL: ${2}" 1>&2
				return 1
			fi
			if [ ! -f "${__JWALTER_SCL_BASE}/${SCL_PATH}/enable" ]; then
				echo "Error: Missing required file: ${__JWALTER_SCL_BASE}/${SCL_PATH}/enable" 1>&2
				return 1
			fi

			#shellcheck disable=1090
			source "${__JWALTER_SCL_BASE}/${SCL_PATH}/enable"
			__JWALTER_SCL_USE+=("${SCL_PATH}")
			;;
		*)
			echo "Error: Unknown command for scl: ${1}" 1>&2
			return 1
			;;
	esac
}
