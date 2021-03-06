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


# If running under tmux, regularly update environment variables. (This makes
# things like $DISPLAY and $SSH_AUTH_SOCK point to the right places.)
if [ -n "${TMUX+set}" ]; then
  __tmux_environment_update() {
    eval "$(tmux show-environment -s)"
  }

  precmd_functions+=(__tmux_environment_update)
fi
