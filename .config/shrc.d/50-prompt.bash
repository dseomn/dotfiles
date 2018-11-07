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


__prompt_core() {
  local user_color="$BGreen"
  if [[ "$UID" = 0 ]]; then
    user_color="$BRed"
  fi

  local host_color="$BGreen"
  if [[ -n "$SSH_CONNECTION" ]]; then
    host_color="$BYellow"
  fi

  printf '%s' "${user_color}\\u@${Clear}${host_color}\\h${Clear}:${BBlue}\\w${Clear}"
}


__prompt_end() {
  printf '%s' '\$ '
}


# Indicate if we're not running under a multiplexer.
__prompt_pre_mux() {
  if [[ -z "${TMUX+set}" ]]; then
    printf '%s' "${BRed}*${Clear} "
  fi
}


# __prompt_post_git for git repo status and __prompt_post_yadm for yadm
# (https://thelocehiliosan.github.io/yadm/) repo status.
if [[ -f /usr/lib/git-core/git-sh-prompt ]]; then
  . /usr/lib/git-core/git-sh-prompt
  GIT_PS1_SHOWDIRTYSTATE=yes
  GIT_PS1_SHOWSTASHSTATE=yes
  GIT_PS1_SHOWUNTRACKEDFILES=yes
  GIT_PS1_SHOWUPSTREAM=auto

  __prompt_post_git() {
    __git_ps1 " (git: %s)"
  }

  if [[ -d ~/.yadm/repo.git ]]; then
    __prompt_post_yadm() {
      local GIT_PS1_SHOWUNTRACKEDFILES=
      GIT_DIR=~/.yadm/repo.git __git_ps1 " (yadm: %s)"
    }
  else
    __prompt_post_yadm() { :; }
  fi
else
  __prompt_post_git() { :; }
  __prompt_post_yadm() { :; }
fi


# Show counts of running and stopped jobs, and the return value of the previous
# command.
__prompt_post_status() {
  local command_ret=$?

  local ret_part=
  if [[ "$command_ret" != 0 ]]; then
    ret_part="${BRed}${command_ret}${Clear}"
  fi

  local jobs_part=
  local running_jobs=$(shrcutil_count_args $(jobs -rp))
  local stopped_jobs=$(shrcutil_count_args $(jobs -sp))
  if [[ "$running_jobs" != 0 ]] || [[ "$stopped_jobs" != 0 ]]; then
    jobs_part="${BGreen}${running_jobs}${Clear}+${BYellow}${stopped_jobs}${Clear}"
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
      __prompt_pre_mux \
      __prompt_core \
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
  local BRed='\[\e[1;31m\]'
  local BGreen='\[\e[1;32m\]'
  local BYellow='\[\e[1;33m\]'
  local BBlue='\[\e[1;34m\]'
  local Clear='\[\e[0m\]'
  __prompt_restore_command_ret
  "$@"
}

__prompt_component_textonly() {
  local BRed=
  local BGreen=
  local BYellow=
  local BBlue=
  local Clear=
  __prompt_restore_command_ret
  "$@"
}

__prompt_set_ps1() {
  __prompt_save_command_ret
  PS1="$(
      for component in \
          __prompt_pre_mux \
          __prompt_core \
          __prompt_post_yadm \
          __prompt_post_git \
          __prompt_post_status \
          __prompt_end \
          __prompt_ctrl_title \
          ; do
        __prompt_component_color "$component"
      done
  )"
}

pcc_append __prompt_set_ps1
