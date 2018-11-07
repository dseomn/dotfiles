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


__do_git_ps1=
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
  . /usr/lib/git-core/git-sh-prompt
  __do_git_ps1=yes
  GIT_PS1_SHOWDIRTYSTATE=yes
  GIT_PS1_SHOWSTASHSTATE=yes
  GIT_PS1_SHOWUNTRACKEDFILES=yes
  GIT_PS1_SHOWUPSTREAM=auto
fi

__do_yadm_ps1=
if [ -n "$__do_git_ps1" -a -d ~/.yadm/repo.git ]; then
  __do_yadm_ps1=yes
fi

__status_ps1_count_args() {
  printf $#
}

__set_ps1() {
  local command_ret=$?

  local prompt_user_at='\[\e[01;32m\]\u@\[\e[00m\]'
  if [ "$UID" = 0 ]; then
    prompt_user_at='\[\e[01;31m\]\u@\[\e[00m\]'
  fi

  local prompt_host='\[\e[01;32m\]\h\[\e[00m\]'
  if [ -n "$SSH_CONNECTION" ]; then
    prompt_host='\[\e[01;33m\]\h\[\e[00m\]'
  fi

  local prompt_dir='\[\e[01;34m\]\w\[\e[00m\]'

  local prompt_end='\$ '

  local prompt_pre_mux=
  local prompt_pre_mux_simple=
  if [ -z "${TMUX+set}" ]; then
    prompt_pre_mux='\[\e[01;31m\]*\[\e[00m\] '
    prompt_pre_mux_simple='* '
  fi

  local prompt_post_git=
  if [ -n "$__do_git_ps1" ]; then
    prompt_post_git='$(__git_ps1 " (git: %s)")'
  fi

  local prompt_post_yadm=
  if [ -n "$__do_yadm_ps1" ]; then
    prompt_post_yadm='$(GIT_DIR=~/.yadm/repo.git GIT_PS1_SHOWUNTRACKEDFILES= __git_ps1 " (yadm: %s)")'
  fi

  # Show counts of running and stopped jobs, and the return value of the
  # previous command.
  local prompt_post_status=
  local prompt_post_status_simple=
  local status_ret_part=
  local status_ret_part_simple=
  if [[ $command_ret != 0 ]]; then
    status_ret_part='\[\e[01;31m\]'${command_ret}'\[\e[00m\]'
    status_ret_part_simple=${command_ret}
  fi
  local status_running_jobs=$(__status_ps1_count_args $(jobs -rp))
  local status_stopped_jobs=$(__status_ps1_count_args $(jobs -sp))
  local status_jobs_part=
  local status_jobs_part_simple=
  if [[ $status_running_jobs != 0 ]] || [[ $status_stopped_jobs != 0 ]]; then
    status_jobs_part='\[\e[01;32m\]'${status_running_jobs}'\[\e[00m\]+\[\e[01;33m\]'${status_stopped_jobs}'\[\e[00m\]'
    status_jobs_part_simple="${status_running_jobs}+${status_stopped_jobs}"
  fi
  local status_divider=
  [ -n "$status_ret_part" -a -n "$status_jobs_part" ] && status_divider='|'
  if [[ -n "$status_ret_part" ]] || [[ -n "$status_jobs_part" ]]; then
    prompt_post_status=" [${status_jobs_part}${status_divider}${status_ret_part}]"
    prompt_post_status_simple=" [${status_jobs_part_simple}${status_divider}${status_ret_part_simple}]"
  fi

  local prompt_ctrl_title='\[\e]0;'"${prompt_pre_mux_simple}"'\u@\h:\w'"${prompt_post_status_simple}"'\007\]'

  PS1="${prompt_pre_mux}${prompt_user_at}${prompt_host}:${prompt_dir}${prompt_post_yadm}${prompt_post_git}${prompt_post_status}${prompt_end}${prompt_ctrl_title}"
}

pcc_append __set_ps1
