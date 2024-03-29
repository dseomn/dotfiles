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


shrcutil_source ~/third_party/git-contrib/completion/git-prompt.sh || return


# Show git status when in a git repo.
__prompt_part_git() {
  local GIT_PS1_SHOWCONFLICTSTATE=yes
  local GIT_PS1_SHOWDIRTYSTATE=yes
  local GIT_PS1_SHOWSTASHSTATE=yes
  local GIT_PS1_SHOWUNTRACKEDFILES=yes
  local GIT_PS1_SHOWUPSTREAM=auto
  local git_ps1="$(__git_ps1 '%s')"
  if [[ -n "$git_ps1" ]]; then
    prompt_append_raw ' ('
    prompt_append_raw 'git' "${FgGreen}"
    prompt_append_raw ': '
    prompt_append "$git_ps1"
    prompt_append_raw ')'
  fi
}

prompt_register __prompt_part_git ps1
