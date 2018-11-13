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


# When nesting interactive shells, show a counter of how deep we are. When not
# under a terminal multiplexer, show a warning asterisk.
#
# Note that this doesn't use $SHLVL because non-interactive shells (e.g., in X
# session init scripts) are uninteresting. Also, this resets the shell nesting
# counter under a multiplexer.
#
# TODO: Properly handle nested muxes. Currently, the counter is only reset for
# the top-level shell under the top-level mux.
if [[ -z "$__nesting_initialized_local" ]]; then
  # Do not export this. It guards against incrementing __nesting_level when
  # sourcing bashrc multiple times in the same shell.
  __nesting_initialized_local=yes

  if [[ -z "$__nesting_initialized" ]]; then
    # Top-level shell, initialize everything.
    export __nesting_initialized=yes
    export __nesting_level=1
    export __nesting_in_mux=
    shrcutil_under_mux && __nesting_in_mux=yes
  elif [[ -z "$__nesting_in_mux" ]] && shrcutil_under_mux; then
    # Top-level shell under a mux. (See caveat above about nested muxes.)
    export __nesting_level=1
    export __nesting_in_mux=yes
  else
    # None of the above, so assume we're nested one level deeper.
    let __nesting_level++
  fi
fi

__prompt_part_nesting() {
  local indicator=

  if [[ "$__nesting_level" -gt 1 ]]; then
    indicator="${indicator}${__nesting_level}"
  fi

  if [[ -z "$__nesting_in_mux" ]]; then
    indicator="${indicator}*"
  fi

  if [[ -n "$indicator" ]]; then
    prompt_append "$indicator" "$FgBrRed"
    prompt_append_raw ' '
  fi
}

prompt_register __prompt_part_nesting ps1 title
