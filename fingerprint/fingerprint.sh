#!/usr/bin/env bash

set -eo pipefail

function usage() {
	echo "Usage:
	$0 -f FILE

	Fingerprints all references to static files in the specified file.

	Reference must match '<basename>?v=<alphanumeric>'.
	Uses md5sum for the fingerprint.

	-f FILE			file to edit
	-s STATIC_DIR	directory with static files
	-r 				revert to v=0
"
}

REVERT=0

while getopts "f:s:r" o; do
	case "${o}" in
	f)
		FILE="${OPTARG}"
		;;
	s)
		STATIC_DIR="${OPTARG}"
		;;
	r)
		REVERT=1
		;;
	*)
		usage
		exit 1
		;;
	esac
done

if [ -z "${FILE}" ]; then
	echo "File ${FILE} does not exist."
	exit 1
fi

if [ ! -d "${STATIC_DIR}" ]; then
	echo "Directory ${STATIC_DIR} does not exist."
	exit 1
fi


FP=0

STATICS=$(find "${STATIC_DIR}")
for F in ${STATICS}; do
	if [ -f "${F}" ]; then
		if [ "${REVERT}" -ne "1" ]; then
			FP=$(md5sum "${F}" | awk '{ print $1 }')
		fi
		BN=$(basename "${F}")
		sed -i -E "s/(${BN}\?v=)([0-9a-zA-Z]+)/\1${FP:0:8}/g" "${FILE}"
		echo "${F}	${FP:0:8}"
	fi
done
