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


# Public API for adding things to PS1 or the window title.


# Registers a function for use in generating a prompt or title string. The
# first parameter is the function name. After that, the remaining parameters
# are what it's being registered for, one or more of:
#
#   * ps1: Main prompt.
#   * title: Window title.
#
# The registered function should call prompt_append and/or prompt_append_raw as
# needed to append text to what is being generated (ps1 and/or title).
prompt_register() {
  local fn="$1"; shift
  local what="$*"
  __prompt_fns+=("$fn")
  __prompt_fn_to_what["$fn"]="$what"
}


# Appends text to ps1/title/etc., without further interpretation.
#
# The first parameter is the text. If present, the second is the color (or
# other text style) escape sequences to apply to the text. See __prompt_set for
# a list of style variables that are available.
#
# Do not call this outside of a function registered with prompt_register; do
# not call this in a subshell.
prompt_append() {
  local text="$1"
  local style="$2"

  [[ -n "$__prompt_running" ]] || return 1

  [[ -n "$text" ]] || return

  local index="${__prompt_var_counters["$__prompt_function"]}"
  let __prompt_var_counters["$__prompt_function"]++
  local var="${__prompt_function}_${index}"
  __prompt_var["$var"]="$text"
  prompt_append_raw "\${__prompt_var[\"${var}\"]}" "$style"
}


# Appends text to ps1/title/etc., with interpretation of everything allowed in
# PS1. Do not pass untrusted input to this function.
#
# Parameters are the same as for prompt_append, except that the text
# parameter's escape sequences, parameter substitution, command substitution,
# etc. are applied.
#
# Do not call this outside of a function registered with prompt_register; do
# not call this in a subshell.
prompt_append_raw() {
  local text="$1"
  local style="$2"

  [[ -n "$__prompt_running" ]] || return 1

  [[ -n "$text" ]] || return

  local what
  for what in ${__prompt_what}; do
    local style_start=
    local style_end=
    case "$what" in
      ps1)
        if [[ -n "$style" ]]; then
          style_start="\\[${style}\\]"
          style_end='\[\e[0m\]'
        fi
        ;;
    esac

    local to_append="${style_start}${text}${style_end}"
    __prompt_value["$what"]="${__prompt_value["$what"]}${to_append}"
  done
}


# Internal implementation.


# Start with no registered functions.
declare -a __prompt_fns=()
declare -A __prompt_fn_to_what=()


# Set global flag to prevent prompt_append[_raw] from working outside of a
# registered function.
__prompt_running=


# Saves and restores $? so that registered functions get the correct value.
__prompt_save_command_ret() {
  __prompt_command_ret=$?
}

__prompt_restore_command_ret() {
  return $__prompt_command_ret
}


# Sets the prompt and title, by calling the registered functions.
__prompt_set() {
  __prompt_save_command_ret

  # BEGIN: Variables for use in registered functions.
  local FgBlack='\e[30m'
  local FgRed='\e[31m'
  local FgGreen='\e[32m'
  local FgYellow='\e[33m'
  local FgBlue='\e[34m'
  local FgMagenta='\e[35m'
  local FgCyan='\e[36m'
  local FgWhite='\e[37m'

  local FgBrBlack='\e[1;30m'
  local FgBrRed='\e[1;31m'
  local FgBrGreen='\e[1;32m'
  local FgBrYellow='\e[1;33m'
  local FgBrBlue='\e[1;34m'
  local FgBrMagenta='\e[1;35m'
  local FgBrCyan='\e[1;36m'
  local FgBrWhite='\e[1;37m'

  local BgBlack='\e[40m'
  local BgRed='\e[41m'
  local BgGreen='\e[42m'
  local BgYellow='\e[43m'
  local BgBlue='\e[44m'
  local BgMagenta='\e[45m'
  local BgCyan='\e[46m'
  local BgWhite='\e[47m'
  # END: Variables for use in registered functions.

  # Variables for safe inclusion of untrusted text.
  declare -gA __prompt_var=()

  # Map from function name to number of prompt variables it's used so far.
  declare -gA __prompt_var_counters=()
  local fn
  for fn in "${__prompt_fns[@]}"; do
    __prompt_var_counters["$fn"]=0
  done

  # This will be filled in by running the registered functions.
  declare -gA __prompt_value=([ps1]="" [title]="")

  # Make prompt_append[_raw] work.
  local __prompt_running=yes

  # Run the registered functions.
  local fn
  for fn in "${__prompt_fns[@]}"; do
    local __prompt_function="$fn"
    local __prompt_what="${__prompt_fn_to_what["$fn"]}"
    __prompt_restore_command_ret
    "$fn"
  done

  PS1="${__prompt_value[ps1]}"'\[\e]0;'"${__prompt_value[title]}"'\007\]'
}

pcc_append __prompt_set
