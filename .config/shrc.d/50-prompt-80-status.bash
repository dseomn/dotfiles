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


# Show counts of running and stopped jobs, and the return value of the previous
# command.
__prompt_part_status() {
  local command_ret=$?
  local running_jobs=$(shrcutil_count_args $(jobs -rp))
  local stopped_jobs=$(shrcutil_count_args $(jobs -sp))

  local show_jobs=
  [[ "$running_jobs" != 0 ]] && show_jobs=yes
  [[ "$stopped_jobs" != 0 ]] && show_jobs=yes

  local show_ret=
  [[ "$command_ret" != 0 ]] && show_ret=yes

  if [[ -z "$show_ret" ]] && [[ -z "$show_jobs" ]]; then
    return
  fi

  local show_divider=
  [[ -n "$show_ret" ]] && [[ -n "$show_jobs" ]] && show_divider=yes

  prompt_append_raw ' ['
  if [[ -n "$show_jobs" ]]; then
    prompt_append "$running_jobs" "$FgBrGreen"
    prompt_append_raw '+'
    prompt_append "$stopped_jobs" "$FgBrYellow"
  fi
  [[ -n "$show_divider" ]] && prompt_append_raw '|'
  [[ -n "$show_ret" ]] && prompt_append "$command_ret" "$FgBrRed"
  prompt_append_raw ']'
}

prompt_register __prompt_part_status ps1 title
