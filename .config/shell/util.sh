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


# Sources all files in the given directory that have file extensions matching
# the current shell.
shell_config_source_parts() {
  __shell_config_source_parts_impl "$1" $(__shell_config_get_extensions)
}


# Implementation of shell_config_source_parts.
__shell_config_source_parts_impl() {
  __shell_config_source_parts_dir="$1"; shift
  for __shell_config_source_parts_file in "$__shell_config_source_parts_dir"/*; do
    for __shell_config_source_parts_ext in "$@"; do
      case "$__shell_config_source_parts_file" in
        *"$__shell_config_source_parts_ext")
          . "$__shell_config_source_parts_file"
          break
          ;;
      esac
    done
  done
  unset __shell_config_source_parts_dir
  unset __shell_config_source_parts_file
  unset __shell_config_source_parts_ext
}


# Prints a whitespace-separated list of file extensions that are appropriate
# for sourcing in the current shell.
__shell_config_get_extensions() {
  echo .sh
  [ -n "${BASH_VERSION+set}" ] && echo .bash
}
