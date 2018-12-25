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

  if [ -n "$__dir_alias_is_ephemeral" ]; then
    # Add the new alias to the list of aliases to be reset next time
    # dir_alias_reset_ephemerals is run.
    __dir_alias_ephemerals="${__dir_alias_ephemerals} ${__da_alias}"
  else
    __dir_alias_table_add "\$${__da_alias}" "${__da_dir}"
  fi

  unset __da_alias
  unset __da_dir
}


# Adds a raw entry (e.g., "$foo" instead of "foo") to the table.
__dir_alias_table_add() {
  # Add the new raw alias for shortening, and sort the table to keep
  # more-specific directories before their less-specific parents. This makes
  # dir_alias_shorten find the most specific prefix first.
  __dir_alias_table="$(
      printf '%s %s\n%s' "${1}" "${2%/}" "${__dir_alias_table}" | sort -rk 2
  )"
}


# Registers a function that configures ephemeral aliases. Ephemeral aliases are
# like normal aliases, except that they can appear/disappear/change frequently,
# and they are not used by dir_alias_shorten (because a shortened path should be
# relatively stable).
#
# The function passed as the first argument should call dir_alias as normal for
# each alias it wants to add.
dir_alias_register_ephemeral_factory() {
  __dir_alias_ephemeral_factories="${__dir_alias_ephemeral_factories} ${1}"
}


# Resets ephemeral aliases, by deleting all of them and (re-)running the
# functions registered by dir_alias_register_ephemeral_factory. This should
# probably be called from $PROMPT_COMMAND in a shell.
dir_alias_reset_ephemerals() {
  unset ${__dir_alias_ephemerals}
  __dir_alias_ephemerals=
  for __da_ephemeral_factory in ${__dir_alias_ephemeral_factories}; do
    __dir_alias_is_ephemeral=yes "${__da_ephemeral_factory}"
  done
  unset __da_ephemeral_factory
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
  __dir_alias_ephemeral_factories=
  __dir_alias_ephemerals=
  __dir_alias_is_ephemeral=
  __dir_alias_table_add '~' ~
  for __da_conf_file in ~/.config/dir-alias/conf.d/*.sh; do
    [ -f "$__da_conf_file" ] || continue
    . "$__da_conf_file"
  done
  unset __da_conf_file
}

dir_alias_init
