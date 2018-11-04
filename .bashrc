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


# Return immediately if this isn't an interactive shell.
case $- in
  *i*)
    ;;
  *)
    return
    ;;
esac


# Save $? before anything else in PROMPT_COMMAND can change it.
PROMPT_COMMAND='__command_ret=$?
    '"${PROMPT_COMMAND}"


HISTCONTROL=ignoredups
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend


shopt -s checkwinsize


if command -v lesspipe > /dev/null; then
  eval "$(SHELL=/bin/sh lesspipe)"
fi


# If running under tmux, regularly update environment variables. (This makes
# things like $DISPLAY and $SSH_AUTH_SOCK point to the right places.)
if [ -n "${TMUX+set}" ]; then
  PROMPT_COMMAND="${PROMPT_COMMAND}"'
      eval "$(tmux show-environment -s)"'
fi


# Set PS1.
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
  if [ -z "${TMUX+set}" ]; then
    prompt_pre_mux='\[\e[01;31m\]*\[\e[00m\] '
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
  local status_ret_part=
  [ $__command_ret != 0 ] && status_ret_part='\[\e[01;31m\]'${__command_ret}'\[\e[00m\]'
  local status_running_jobs=$(__status_ps1_count_args $(jobs -rp))
  local status_stopped_jobs=$(__status_ps1_count_args $(jobs -sp))
  local status_jobs_part=
  [ $status_running_jobs != 0 -o $status_stopped_jobs != 0 ] &&
      status_jobs_part='\[\e[01;32m\]'${status_running_jobs}'\[\e[00m\]+\[\e[01;33m\]'${status_stopped_jobs}'\[\e[00m\]'
  local status_divider=
  [ -n "$status_ret_part" -a -n "$status_jobs_part" ] && status_divider='|'
  [ -n "$status_ret_part" -o -n "$status_jobs_part" ] &&
      prompt_post_status=" [${status_jobs_part}${status_divider}${status_ret_part}]"

  PS1="${prompt_pre_mux}${prompt_user_at}${prompt_host}:${prompt_dir}${prompt_post_yadm}${prompt_post_git}${prompt_post_status}${prompt_end}"
}

PROMPT_COMMAND="${PROMPT_COMMAND}"'
    __set_ps1'


# Enable colors by default.
if command -v dircolors > /dev/null; then
  eval "$(dircolors -b)"
fi
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'


# Enable bash completion.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# Set EDITOR.
for editor_candidate in vim vi nano; do
  if command -v "$editor_candidate" > /dev/null; then
    export EDITOR="$editor_candidate"
    break
  fi
done
unset editor_candidate


# Disable Ctrl-S/Ctrl-Q flow control. See also ~/.tmux.conf, which re-purposes
# Ctrl-S.
stty -ixon


# Local overrides.
if [ -f ~/.bashrc.local ]; then
  . ~/.bashrc.local
fi
