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


# Tries to set TERM to something that's available in the terminfo database.
__terminal_fallback() {
  while [ "$#" -gt 0 ]; do
    if tput -T "$1" clear > /dev/null 2>&1; then
      # We found a term that exists, set it and we're done.
      export TERM="$1"
      return
    else
      # The current best option isn't available, add more fallback options based
      # on the current option. (Be careful to avoid infinite loops here.)
      case "$1" in
        xterm-256color)
          set -- "$@" xterm
          ;;
        tmux-256color)
          set -- "$@" screen-256color tmux
          ;;
        screen-256color)
          set -- "$@" screen
          ;;
      esac
    fi

    # Try the next option in the list of fallbacks.
    shift
  done

  # At this point, none of $TERM or its fallbacks are available, so leave $TERM
  # untouched and hope for the best.
}

__terminal_fallback "$TERM"

unset -f __terminal_fallback
