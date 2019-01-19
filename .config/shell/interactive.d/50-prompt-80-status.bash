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


# Show counts of running and stopped jobs, and info about the previous command.
__prompt_part_status() {
  local running_jobs=$(shrcutil_count_args $(jobs -rp))
  local stopped_jobs=$(shrcutil_count_args $(jobs -sp))

  local show_jobs=
  [[ "$running_jobs" != 0 ]] && show_jobs=yes
  [[ "$stopped_jobs" != 0 ]] && show_jobs=yes

  local show_ret_or_bg=
  if [[ -z "$BPE_FIRST_PROMPT_AFTER_COMMAND" ]]; then
    :
  elif [[ -n "$BPE_LAST_COMMAND_DID_BG" ]]; then
    show_ret_or_bg=yes
  else
    local component_ret
    for component_ret in "${BP_PIPESTATUS[@]}"; do
      if [[ "$component_ret" != 0 ]]; then
        show_ret_or_bg=yes
        break
      fi
    done
  fi

  if [[ -z "$show_ret_or_bg" ]] && [[ -z "$show_jobs" ]]; then
    return
  fi

  local show_divider=
  [[ -n "$show_ret_or_bg" ]] && [[ -n "$show_jobs" ]] && show_divider=yes

  prompt_append_raw ' ['
  if [[ -n "$show_jobs" ]]; then
    prompt_append "$running_jobs" "$FgBrGreen"
    prompt_append_raw '+'
    prompt_append "$stopped_jobs" "$FgBrYellow"
  fi
  [[ -n "$show_divider" ]] && prompt_append_raw '|'
  if [[ -n "$show_ret_or_bg" ]]; then
    if [[ -n "$BPE_LAST_COMMAND_DID_BG" ]]; then
      prompt_append "$!" "$FgMagenta"
      prompt_append_raw '&'
    else
      local is_first_component=yes
      local component_ret
      for component_ret in "${BP_PIPESTATUS[@]}"; do
        if [[ -n "$is_first_component" ]]; then
          is_first_component=
        else
          prompt_append_raw '-'
        fi
        if [[ "$component_ret" = 0 ]]; then
          prompt_append "$component_ret" "$FgGreen"
        else
          prompt_append "$component_ret" "$FgBrRed"
        fi
      done
    fi
  fi
  prompt_append_raw ']'
}

prompt_register __prompt_part_status ps1 title
