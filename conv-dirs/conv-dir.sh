#!/usr/bin/env bash

# Copyright 2019 Hayo van Loon
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TARGET=$1
SRC=$2
REPL=$3

check() {
	if [ ! -d "${TARGET}" ]; then
		echo Need a directory to process.
		return 1
	fi
	if [ -z "${SRC}" ]; then
		echo Need character string to search for.
		return 2
	fi
	if [ -z "${REPL}" ]; then
		echo Need a replacement string.
		return 3
	fi

	return 0
}

conv_dirs() {
	local REGEX FILES S1 S2 S3 ITER
	
	REGEX="(^${SRC}(\/|$))|(\/${SRC}\/)|(\/${SRC}$)"
	FILES=$(find ${TARGET} | grep -E "${REGEX}" | sed "s/ /~~/g")
	
	S1="s/^${SRC}/${REPL}/g"
	S2="s/\/${SRC}\//\/${REPL}\//g"
	S3="s/\/${SRC}$/\/${REPL}/g"
	
	ITER=0
	while [ -n "${FILES}" ]; do
		ITER=$[${ITER} + 1]
		local FILE OUTP
		FILE=$(echo $FILES | sort -r | cut -d " " -f1 | sed "s/~~/ /g")
		OUTP="$((sed ${S1} | sed ${S2} | sed ${S3})<<< "${FILE}")"
		echo "Renaming '${FILE}' to '${OUTP}'"
		mv "${FILE}" "${OUTP}"

		if [ "${FILE}" == "${TARGET}" ]; then
			TARGET=${OUTP}
		fi
		FILES=$(find ${TARGET} | grep -E "${REGEX}" | sed "s/ /~~/g")
	done
	echo "Done in ${ITER} iteration(s)."
}

ERR=$(check)
if [ -n "${ERR}" ]; then
	echo $ERR
	echo "Usage: ${0} TARGET SRC REPL
Replace all occurences of SRC in the path of TARGET with REPL."
	exit 1
else
	conv_dirs
fi

