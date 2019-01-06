# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Use vim to view man pages.


[ "${EDITOR##*/}" = vim ] || return


man() {
  if [ "$#" = 1 ] && [ "${1#-}" = "$1" ]; then
    VIM_MAN1="$1" $EDITOR -c 'setf man | Man $VIM_MAN1'
  elif [ "$#" = 2 ] && [ "${1#-}${2#-}" = "${1}${2}" ]; then
    VIM_MAN1="$1" VIM_MAN2="$2" $EDITOR -c 'setf man | Man $VIM_MAN1 $VIM_MAN2'
  else
    command man "$@"
  fi
}
