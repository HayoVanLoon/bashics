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


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "Stores the contents of the files under ./private in environment variables.

The file names are converted with the following rules:
* the .txt extension is truncated
* a-z characters are uppercased
* dashes are converted to underscores"
	exit 0
fi


FILES=$(find private/ | grep .txt)

for FILE in $FILES; do
  VAR=$(
    echo "$FILE" |
      sed 's/private\/\(.\+\)\.txt/\1/g' |
      tr "[:lower:]" "[:upper:]" |
      tr - _
  )
  export "$VAR"="$(cat "$FILE")"
  echo set "$VAR to $(cat "$FILE")"
done

