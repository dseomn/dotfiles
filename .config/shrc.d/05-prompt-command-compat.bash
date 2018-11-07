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


# Compatibility function that has the same effect as appending to
# $PROMPT_COMMAND, except that $? will be set correctly for each code block
# passed to this function.
#
# This works whether or not bash-preexec
# (https://github.com/rcaloras/bash-preexec) is used elsewhere.
pcc_append() {
  __pcc_prompt_command="
      ${__pcc_prompt_command}
      __pcc_restore_command_ret
      $*
  "
}

__pcc_prompt_command=

__pcc_save_command_ret() {
  __pcc_command_ret=$?
  return $__pcc_command_ret
}

__pcc_restore_command_ret() {
  return $__pcc_command_ret
}

__pcc_run_prompt_command() {
  eval "$__pcc_prompt_command"
}

if [[ -n "${__bp_imported+set}" ]]; then
  precmd_functions+=(__pcc_save_command_ret)
  precmd_functions+=(__pcc_run_prompt_command)
else
  PROMPT_COMMAND="
      __pcc_save_command_ret
      ${PROMPT_COMMAND}
      __pcc_run_prompt_command
  "
fi
