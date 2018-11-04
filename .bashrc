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


HISTCONTROL=ignoredups
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend


shopt -s checkwinsize


if command -v lesspipe > /dev/null; then
  eval "$(SHELL=/bin/sh lesspipe)"
fi


# Set PS1.
prompt_user_at='\[\e[01;32m\]\u@\[\e[00m\]'
if [ "$UID" = 0 ]; then
  prompt_user_at='\[\e[01;31m\]\u@\[\e[00m\]'
fi
__prompt_host_color() {
  # Re-test $SSH_CONNECTION at each prompt because it can change when running
  # under tmux. See below where PROMPT_COMMAND is used to update the
  # environment from tmux.
  if [ -n "$SSH_CONNECTION" ]; then
    printf '\e[01;33m'
  else
    printf '\e[01;32m'
  fi
}
prompt_host='$(__prompt_host_color)\h\[\e[00m\]'
prompt_dir='\[\e[01;34m\]\w\[\e[00m\]'
prompt_end='\$ '
prompt_pre_mux=
if [ -z "${TMUX+set}" ]; then
  prompt_pre_mux='\[\e[01;31m\]*\[\e[00m\] '
fi
prompt_post_git=
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
  . /usr/lib/git-core/git-sh-prompt
  prompt_post_git='$(__git_ps1 " (git: %s)")'
  GIT_PS1_SHOWDIRTYSTATE=yes
  GIT_PS1_SHOWSTASHSTATE=yes
  GIT_PS1_SHOWUNTRACKEDFILES=yes
  GIT_PS1_SHOWUPSTREAM=auto
fi
prompt_post_yadm=
if [ -n "$prompt_post_git" -a -d ~/.yadm/repo.git ]; then
  prompt_post_yadm='$(GIT_DIR=~/.yadm/repo.git GIT_PS1_SHOWUNTRACKEDFILES= __git_ps1 " (yadm: %s)")'
fi
__status_ps1_count_args() {
  printf $#
}
__status_ps1() {
  # Show counts of running and stopped jobs, and the return value of the
  # previous command.
  local ret=$?
  local ret_part=
  [ $ret != 0 ] && ret_part='\e[01;31m'${ret}'\e[00m'
  local running_jobs=$(__status_ps1_count_args $(jobs -rp))
  local stopped_jobs=$(__status_ps1_count_args $(jobs -sp))
  local jobs_part=
  [ $running_jobs != 0 -o $stopped_jobs != 0 ] &&
      jobs_part='\e[01;32m'${running_jobs}'\e[00m+\e[01;33m'${stopped_jobs}'\e[00m'
  local divider=
  [ -n "$ret_part" -a -n "$jobs_part" ] && divider='|'
  [ -n "$ret_part" -o -n "$jobs_part" ] &&
      printf " [${jobs_part}${divider}${ret_part}]"
}
prompt_post_status='$(__status_ps1)'
PS1="${prompt_pre_mux}${prompt_user_at}${prompt_host}:${prompt_dir}${prompt_post_yadm}${prompt_post_git}${prompt_post_status}${prompt_end}"
unset prompt_user_at
unset prompt_host
unset prompt_dir
unset prompt_end
unset prompt_pre_mux
unset prompt_post_git
unset prompt_post_yadm
unset prompt_post_status


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


# If running under tmux, regularly update environment variables. (This makes
# things like $DISPLAY and $SSH_AUTH_SOCK point to the right places.)
if [ -n "${TMUX+set}" ]; then
  PROMPT_COMMAND="${PROMPT_COMMAND}"'
      eval "$(tmux show-environment -s)"'
fi


# Disable Ctrl-S/Ctrl-Q flow control. See also ~/.tmux.conf, which re-purposes
# Ctrl-S.
stty -ixon


# Local overrides.
if [ -f ~/.bashrc.local ]; then
  . ~/.bashrc.local
fi
