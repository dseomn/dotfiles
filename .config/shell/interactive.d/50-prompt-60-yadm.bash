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


shrcutil_source /usr/lib/git-core/git-sh-prompt || return


# Show YADM (https://thelocehiliosan.github.io/yadm/) status.
#
# YADM status is not per-directory, so there isn't a particularly good way to
# know when it's relevant. To compensate, hide the status when on the "correct"
# branch in a clean, up-to-date state. This assumes that branches correspond
# exactly to YADM's notion of a class, which is not standard, but I find it
# useful.
__prompt_part_yadm() {
  [[ -d ~/.yadm/repo.git ]] || return

  # Dotfiles affect the general environment, not just paths under $HOME, so the
  # `cd` commands below are to show the same status regardless of $PWD. Most of
  # this function's work is executed in subshells, so we can cd and change the
  # environment without affecting the main shell.

  local yadm_class="$(
    cd
    export GIT_DIR=~/.yadm/repo.git
    git config --get local.class
  )"

  local yadm_ps1="$(
    cd
    export GIT_DIR=~/.yadm/repo.git
    GIT_PS1_SHOWDIRTYSTATE=yes
    GIT_PS1_SHOWSTASHSTATE=yes
    GIT_PS1_SHOWUNTRACKEDFILES=yes
    GIT_PS1_SHOWUPSTREAM=auto
    __git_ps1 '%s'
  )"

  if [[ -z "$yadm_class" ]] || [[ "$yadm_ps1" != "${yadm_class}=" ]]; then
    prompt_append_raw ' ('
    prompt_append_raw 'yadm' "${FgMagenta}"
    prompt_append_raw ': '
    prompt_append "$yadm_ps1"
    prompt_append_raw ')'
  fi
}

prompt_register __prompt_part_yadm ps1
