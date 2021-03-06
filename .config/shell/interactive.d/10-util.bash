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


# Prints the number of arguments its given.
shrcutil_count_args() {
  printf $#
}


# Returns 0 if we're under a multiplexer, 1 otherwise.
shrcutil_under_mux() {
  [[ -n "${TMUX+set}" ]] && return 0
  return 1
}


# Sources the given file if it hasn't been successfully sourced already.
# Returns 0 if the file was successfully sourced (either this time or
# previously); non-zero otherwise.
shrcutil_source() {
  local file="$1"
  [[ -n "${__shrcutil_source_files["${file}"]}" ]] && return 0
  [[ -f "$file" ]] || return 1
  . "$file" || return $?
  __shrcutil_source_files["${file}"]=yes
  return 0
}
declare -gA __shrcutil_source_files=()
