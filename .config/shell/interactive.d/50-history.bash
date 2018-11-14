# Copyright 2018 Google LLC
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


__set_at_least() {
  # Ensure that the environment variable named in $1 is greater than or equal
  # to $2.
  eval "[[ $2 -gt \${$1:-0} ]] && $1=$2"
}

HISTCONTROL=ignoredups
__set_at_least HISTSIZE $((10 * 1000))
__set_at_least HISTFILESIZE $((100 * 1000))
shopt -s histappend

unset -f __set_at_least
