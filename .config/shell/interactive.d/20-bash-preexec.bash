# Copyright 2019 Google LLC
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


shrcutil_source ~/third_party/bash-preexec/bash-preexec.sh || return


# The rest of this file provides additional variables to preexec and precmd
# functions. These public variables all start with BPE_, short for Bash Preexec
# Extra.


# BPE_FIRST_PROMPT_AFTER_COMMAND (precmd): This will be non-empty in the first
# precmd run after a command, and empty in all other precmd runs. E.g., if
# interactive.d contains this code:
#
#   f() { [[ -n "$BPE_FIRST_PROMPT_AFTER_COMMAND" ]] && echo set; }
#   precmd_functions+=(f)
#
# Then an interactive session could look like:
#
#   $
#   $ ^C
#   $ :
#   set
#   $
__bpe_set_first_prompt_after_command() {
  BPE_FIRST_PROMPT_AFTER_COMMAND=true
}

__bpe_late_preexec_functions+=(__bpe_set_first_prompt_after_command)

__bpe_clear_first_prompt_after_command() {
  BPE_FIRST_PROMPT_AFTER_COMMAND=
}

__bpe_late_precmd_functions+=(__bpe_clear_first_prompt_after_command)

__bpe_clear_first_prompt_after_command


# BPE_LAST_COMMAND_DID_BG (precmd): This will be non-empty iff the most recent
# command run put something into the background.
BPE_LAST_COMMAND_DID_BG=

__bpe_last_bg_pid="$!"

__bpe_set_last_command_did_bg() {
  [[ -n "$BPE_FIRST_PROMPT_AFTER_COMMAND" ]] || return 0
  if [[ "$!" = "$__bpe_last_bg_pid" ]]; then
    BPE_LAST_COMMAND_DID_BG=
  else
    BPE_LAST_COMMAND_DID_BG=true
  fi
  __bpe_last_bg_pid="$!"
}

precmd_functions+=(__bpe_set_last_command_did_bg)
