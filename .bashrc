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
prompt_extra_git=
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
  . /usr/lib/git-core/git-sh-prompt
  prompt_extra_git='$(__git_ps1 " (git: %s)")'
  GIT_PS1_SHOWDIRTYSTATE=yes
  GIT_PS1_SHOWSTASHSTATE=yes
  GIT_PS1_SHOWUNTRACKEDFILES=yes
  GIT_PS1_SHOWUPSTREAM=auto
fi
if command -v tput > /dev/null && tput setaf 1 >&/dev/null; then
  prompt_core='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]'
else
  prompt_core='\u@\h:\w'
fi
prompt_end='\$ '
PS1="${prompt_core}${prompt_extra_git}${prompt_end}"
unset prompt_extra_git
unset prompt_core
unset prompt_end


# Enable colors by default.
if command -v dircolors > /dev/null; then
  eval "$(dircolors -b)"
fi
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'


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


# Local overrides.
if [ -f ~/.bashrc.local ]; then
  . ~/.bashrc.local
fi
