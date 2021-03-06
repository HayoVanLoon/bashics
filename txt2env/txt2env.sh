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

show_help() {
	echo "
Usage: source txt2env

Exports the contents of txt-files in the current directory to environment 
variables.

Navigate to the target directory. Then source the file, aka: 
'source ${0}', '. ${0}' or 'eval ${0}'

The file names are converted with the following rules:
* the .txt extension is truncated
* letter characters are uppercased
* dashes are converted to underscores

Example:
    'foo-bar1.txt' will expand to 'export FOO_BAR1=<contents of foo-bar1.txt>'"
	exit 0
}

if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	show_help
fi

if [ -n "$1" ]; then
	SRC="$1"
else
	SRC="."
fi

FILES=$(ls -1 "${SRC}"/*.txt)

for FILE in $FILES; do
	VAR=$(
		basename "$FILE" |
			sed 's/.txt$//g' |
			tr "[:lower:]" "[:upper:]" |
			tr - _
	)
	CMD="export $VAR=$(cat "$FILE")"
	echo "$CMD"
	eval "$CMD"
done

