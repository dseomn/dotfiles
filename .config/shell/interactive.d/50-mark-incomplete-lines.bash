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


# If the last line before the prompt doesn't end in a newline, add a marker
# where it did end and then print a newline before the prompt.
__mark_incomplete_lines() {
  # See https://www.xfree86.org/4.8.0/ctlseqs.html, "CSI P s n". The "\e[6n"
  # causes the terminal write "\e[N;MR" where N is the current row and M is the
  # current column.
  local esc row col
  stty -echo
  printf '\e[6n'
  IFS='[;' read -r -d R esc row col
  stty echo

  [[ "$col" = 1 ]] && return

  printf '\e[7m%s\e[0m\n' '%noeol'
}

pcc_append __mark_incomplete_lines
