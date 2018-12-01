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


# Appends the given return value, with color depending on the value.
__prompt_part_status_append_ret() {
  if [[ "$1" = 0 ]]; then
    prompt_append "$1" "$FgGreen"
  else
    prompt_append "$1" "$FgBrRed"
  fi
}

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
  local component_ret
  for component_ret in "$command_ret" "${PCC_PIPESTATUS[@]}"; do
    if [[ "$component_ret" != 0 ]]; then
      show_ret=yes
      break
    fi
  done

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
  if [[ -n "$show_ret" ]]; then
    # TODO: Figure out how to show $PIPESTATUS/$? only if they came from the
    # command immediately before this prompt. E.g., $PIPESTATUS is not affected
    # by running `foo &`, and neither variable is affected by hitting Enter
    # without any command.
    local is_first_component=yes
    local last_component_ret=
    local component_ret
    for component_ret in "${PCC_PIPESTATUS[@]}"; do
      if [[ -n "$is_first_component" ]]; then
        is_first_component=
      else
        prompt_append_raw '-'
      fi
      __prompt_part_status_append_ret "$component_ret"
      last_component_ret="$component_ret"
    done
    if [[ "$last_component_ret" != "$command_ret" ]]; then
      prompt_append_raw ':'
      __prompt_part_status_append_ret "$command_ret"
    fi
  fi
  prompt_append_raw ']'
}

prompt_register __prompt_part_status ps1 title
