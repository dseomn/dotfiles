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
# WARNING: This does not support directory names that contain whitespace.
dir_alias() {
  # Use internal variable names even with `local` to avoid conflicts with the
  # alias name.
  local __da_alias="$1"
  local __da_dir="$2"

  __da_dir="${__da_dir%/}"

  eval "${__da_alias}=\"\${__da_dir}\""

  # Add the new alias, and sort the table to keep more-specific directories
  # before their less-specific parents. This makes dir_alias_shorten find the
  # most specific prefix first.
  __dir_alias_table="$(
      printf '$%s %s\n%s' "${__da_alias}" "${__da_dir}" "${__dir_alias_table}" |
          sort -rk 2
  )"
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
  local dir="$1"

  local alias candidate
  while read -r alias candidate; do
    [[ -n "$alias" ]] || continue  # Ignore blank lines.
    case "$dir" in
      "${candidate}"|"${candidate}"/*)
        printf '%s' "${alias}${dir#${candidate}}"
        return
        ;;
    esac
  done <<EOF
${__dir_alias_table}
~ ${HOME}
EOF

  # No match was found, print the original.
  printf '%s' "$dir"
}


__dir_alias_table=
