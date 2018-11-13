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


return  # TODO: delete this file


# Dependencies


__prompt_have_git_ps1=
if [[ -f /usr/lib/git-core/git-sh-prompt ]]; then
  __prompt_have_git_ps1=yes
  . /usr/lib/git-core/git-sh-prompt
fi


# Prompt Components
#
# Prompt component functions print text that will be included in the PS1
# variable, so they can output any of the PS1 codes that bash supports,
# including '\[' and '\]'. Functions with names like __prompt_post_* are meant
# to go after the core part of the prompt, and typically print a space
# character before anything else. __prompt_pre_* functions similarly print a
# space at the end of their output.
#
# For each component, $? is initially set to the return value of the last
# user-run command.
#
# To support either color or text-only output, see __prompt_component_color and
# __prompt_component_textonly below, which provide variables that prompt
# component functions can use.


__prompt_end() {
  printf '%s' '\$ '
}


# Show counts of running and stopped jobs, and the return value of the previous
# command.
__prompt_post_status() {
  local command_ret=$?

  local ret_part=
  if [[ "$command_ret" != 0 ]]; then
    ret_part="${FgBrRed}${command_ret}${Clear}"
  fi

  local jobs_part=
  local running_jobs=$(shrcutil_count_args $(jobs -rp))
  local stopped_jobs=$(shrcutil_count_args $(jobs -sp))
  if [[ "$running_jobs" != 0 ]] || [[ "$stopped_jobs" != 0 ]]; then
    jobs_part="${FgBrGreen}${running_jobs}${Clear}+${FgBrYellow}${stopped_jobs}${Clear}"
  fi

  local divider=
  if [[ -n "$ret_part" ]] && [[ -n "$jobs_part" ]]; then
    divider='|'
  fi

  if [[ -n "$ret_part" ]] || [[ -n "$jobs_part" ]]; then
    printf '%s' " [${jobs_part}${divider}${ret_part}]"
  fi
}


# Set window titles. Note that this component uses other components to define
# the contents of the title.
__prompt_ctrl_title() {
  printf '%s' '\[\e]0;'
  local component
  for component in \
      __prompt_post_status \
      ; do
    __prompt_component_textonly "$component"
  done
  printf '%s' '\007\]'
}


# Prompt Setting
#
# The below code is used to set the prompt, using the components defined above.

__prompt_save_command_ret() {
  __prompt_command_ret=$?
}

__prompt_restore_command_ret() {
  return $__prompt_command_ret
}

__prompt_component_color() {
  local FgBlack='\[\e[30m\]'
  local FgRed='\[\e[31m\]'
  local FgGreen='\[\e[32m\]'
  local FgYellow='\[\e[33m\]'
  local FgBlue='\[\e[34m\]'
  local FgMagenta='\[\e[35m\]'
  local FgCyan='\[\e[36m\]'
  local FgWhite='\[\e[37m\]'

  local FgBrBlack='\[\e[1;30m\]'
  local FgBrRed='\[\e[1;31m\]'
  local FgBrGreen='\[\e[1;32m\]'
  local FgBrYellow='\[\e[1;33m\]'
  local FgBrBlue='\[\e[1;34m\]'
  local FgBrMagenta='\[\e[1;35m\]'
  local FgBrCyan='\[\e[1;36m\]'
  local FgBrWhite='\[\e[1;37m\]'

  local BgBlack='\[\e[40m\]'
  local BgRed='\[\e[41m\]'
  local BgGreen='\[\e[42m\]'
  local BgYellow='\[\e[43m\]'
  local BgBlue='\[\e[44m\]'
  local BgMagenta='\[\e[45m\]'
  local BgCyan='\[\e[46m\]'
  local BgWhite='\[\e[47m\]'

  local Clear='\[\e[0m\]'

  __prompt_restore_command_ret
  "$@"
}

__prompt_component_textonly() {
  local FgBlack=
  local FgRed=
  local FgGreen=
  local FgYellow=
  local FgBlue=
  local FgMagenta=
  local FgCyan=
  local FgWhite=

  local FgBrBlack=
  local FgBrRed=
  local FgBrGreen=
  local FgBrYellow=
  local FgBrBlue=
  local FgBrMagenta=
  local FgBrCyan=
  local FgBrWhite=

  local BgBlack=
  local BgRed=
  local BgGreen=
  local BgYellow=
  local BgBlue=
  local BgMagenta=
  local BgCyan=
  local BgWhite=

  local Clear=

  __prompt_restore_command_ret
  "$@"
}

__prompt_set_ps1() {
  __prompt_save_command_ret
  PS1="$(
      for component in \
          __prompt_post_status \
          __prompt_end \
          __prompt_ctrl_title \
          ; do
        __prompt_component_color "$component"
      done
  )"
}

pcc_append __prompt_set_ps1
