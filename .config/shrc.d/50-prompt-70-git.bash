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


# Show git status when in a git repo.
__prompt_part_git() {
  local GIT_PS1_SHOWDIRTYSTATE=yes
  local GIT_PS1_SHOWSTASHSTATE=yes
  local GIT_PS1_SHOWUNTRACKEDFILES=yes
  local GIT_PS1_SHOWUPSTREAM=auto
  prompt_append "$(__git_ps1 " (git: %s)")"
}

prompt_register __prompt_part_git ps1
