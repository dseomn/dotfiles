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


shrcutil_source ~/.local/lib/dir-alias/dir-alias.sh


# Relatively standard "user@host:directory", but fancier.
__prompt_part_core() {
  local user_color="$FgBrGreen"
  if [[ "$UID" = 0 ]]; then
    user_color="$FgBrRed"
  fi
  prompt_append_raw '\u@' "$user_color"

  local host_color="$FgBrGreen"
  if [[ -n "$SSH_CONNECTION" ]]; then
    host_color="$FgBrYellow"
  fi
  prompt_append_raw '\h' "$host_color"

  prompt_append_raw ':'

  local dir_color="$FgBrBlue"
  local ls_error=
  local ls_dot="$(ls -ld . 2> /dev/null)" || ls_error=yes
  if
      ! [[ -d "$PWD" ]] ||
      ! [[ -x "$PWD" ]] ||
      ! [[ . -ef "$PWD" ]] ||
      [[ -n "$ls_error" ]]
      then
    # We're in a directory that we couldn't cd into now. Maybe the directory
    # was deleted or moved, maybe its permissions changed, maybe something else
    # weird happened. Either way, make it hard to ignore.
    dir_color="${FgBrWhite}${BgRed}"
  elif [[ "$ls_dot" = d???????w[tT]* ]]; then
    dir_color="${FgBlack}${BgGreen}"
  elif [[ "$ls_dot" = d???????w?* ]]; then
    dir_color="${FgBrBlue}${BgGreen}"
  elif [[ "$ls_dot" = d????????[tT]* ]]; then
    dir_color="${FgBrWhite}${BgBlue}"
  elif ! [[ -r . ]]; then
    dir_color="$FgBrMagenta"
  elif ! [[ -w . ]]; then
    dir_color="$FgBrCyan"
  fi
  prompt_append "$(dir_alias_shorten "$PWD")" "$dir_color"
}

prompt_register __prompt_part_core ps1 title
