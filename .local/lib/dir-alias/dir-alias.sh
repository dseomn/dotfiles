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


# Add a directory alias. E.g.,
#
#     dir_alias foo /path/to/foo
#
# will make it possible to type
#
#     cd $foo
#
# instead of
#
#     cd /path/to/foo
#
# In general, this function should be used only by files in
# ~/.config/dir-alias/conf.d/ (see dir_alias_init below).
#
# WARNING: This does not support directory names that contain whitespace.
dir_alias() {
  __da_alias="$1"
  __da_dir="$2"

  __da_dir="${__da_dir%/}"

  eval "export ${__da_alias}=\"\${__da_dir}\""

  # Add the new alias, and sort the table to keep more-specific directories
  # before their less-specific parents. This makes dir_alias_shorten find the
  # most specific prefix first.
  __dir_alias_table="$(
      printf '$%s %s\n%s' "${__da_alias}" "${__da_dir}" "${__dir_alias_table}" |
          sort -rk 2
  )"

  unset __da_alias
  unset __da_dir
}


# Given a full directory path, print a shortened version using the longest
# directory alias available. E.g., if foo is a dir alias for /path/to/foo,
#
#     dir_alias_shorten /path/to/foo/bar
#
# will print
#
#     $foo/bar
dir_alias_shorten() {
  __da_dir="$1"

  while read -r __da_alias __da_candidate; do
    [ -n "$__da_alias" ] || continue  # Ignore blank lines.
    case "$__da_dir" in
      "${__da_candidate}"|"${__da_candidate}"/*)
        printf '%s' "${__da_alias}${__da_dir#${__da_candidate}}"
        unset __da_dir __da_alias __da_candidate
        return
        ;;
    esac
  done <<EOF
${__dir_alias_table}
~ ${HOME}
EOF

  # No match was found, print the original.
  printf '%s' "$__da_dir"
  unset __da_dir __da_alias __da_candidate
}


# Get the user's configured aliases. By default, this is a no-op if called more
# than once, but passing --force will re-read the configs. It's also called
# below, so it generally doesn't need to be called manually.
dir_alias_init() {
  if [ -n "$__dir_alias_init" ] && [ "$1" != "--force" ]; then
    return
  fi
  __dir_alias_init=yes
  __dir_alias_table=
  for __da_conf_file in ~/.config/dir-alias/conf.d/*.sh; do
    [ -f "$__da_conf_file" ] || continue
    . "$__da_conf_file"
  done
  unset __da_conf_file
}

dir_alias_init