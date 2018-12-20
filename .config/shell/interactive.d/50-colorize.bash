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


# Turn color on for `ls` on some BSD variants.
export CLICOLOR=true


# Source the output of dircolors, if it's available.
for __colorize_dircolors in dircolors gdircolors gnudircolors; do
  if command -v "${__colorize_dircolors}" > /dev/null; then
    eval "$("${__colorize_dircolors}" -b)"
    break
  fi
done
unset __colorize_dircolors


# Set aliases to colorized versions of commands.
for __colorize_ls in ls gls gnuls; do
  if command -v "${__colorize_ls}" > /dev/null &&
      "${__colorize_ls}" --version 2> /dev/null | grep -qi 'gnu coreutils'; then
    alias ls="${__colorize_ls} --color=auto"
    break
  fi
done
unset __colorize_ls

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if diff --color=auto /dev/null /dev/null 2> /dev/null; then
  alias diff='diff --color=auto'
fi
