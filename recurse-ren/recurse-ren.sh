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
REPL=$2
DIR=$3


show_help() {
	echo "
Usage: $0 TARGET REPL DIR

Recursively renames all complete matches of the TARGET string in DIR into 
REPL.

Unless file names completely match the TARGET, they are ignored.
Partial matches, i.e. '/foobar/' when the target is 'foo' will be ignored.

Example:
Given the following directory structure:
.
├── 1
│   └── 2
│       └── 3
│           └── 1
└── 1a
    └── 2 2
        └── 3
            └── 1

Running 
	$0 1 XXX tmp/
will make it:
.
├── XXX
│   └── 2
│       └── 3
│           └── XXX
└── 1a
    └── 2 2
        └── 3
            └── XXX
"
        exit 0
}

check() {
	if [ ! -d "${DIR}" ]; then
		echo Need a directory to process.
		return 1
	fi
	if [ -z "${TARGET}" ]; then
		echo Need character string to search for.
		return 2
	fi
	if [ -z "${REPL}" ]; then
		echo Need a replacement string.
		return 3
	fi

	return 0
}

recurse_ren() {
	local REGEX FILES S1 S2 S3 ITER
	
	REGEX="(^${TARGET}(/|$))|(/${TARGET}/)|(/${TARGET}$)"
	FILES=$(find "${DIR}" | grep -E "${REGEX}" | sed "s/ /~~/g")
	
	S1="s/^${TARGET}/${REPL}/g"
	S2="s/\/${TARGET}\//\/${REPL}\//g"
	S3="s/\/${TARGET}$/\/${REPL}/g"
	
	ITER=0
	while [ -n "${FILES}" ]; do
		ITER=$((ITER + 1))
		local FILE OUTP
		FILE=$(echo $FILES | sort -r | cut -d " " -f1 | sed "s/~~/ /g")
		OUTP="$( (sed ${S1} | sed ${S2} | sed ${S3}) <<< "${FILE}")"
		echo "Renaming '${FILE}' to '${OUTP}'"
		mv "${FILE}" "${OUTP}"

		if [ "${FILE}" == "${DIR}" ]; then
			DIR=${OUTP}
		fi
		FILES=$(find "${DIR}" | grep -E "${REGEX}" | sed "s/ /~~/g")
	done
	echo "Done in ${ITER} iteration(s)."
}

if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	show_help
fi

ERR=$(check)
if [ -n "$ERR" ]; then
	echo "Error: $ERR"
	show_help
	exit 1
else
	recurse_ren	
fi
