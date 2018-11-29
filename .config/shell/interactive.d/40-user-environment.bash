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


# Set EDITOR.
for editor_candidate in vim vi nano; do
  if command -v "$editor_candidate" > /dev/null; then
    export EDITOR="$editor_candidate"
    break
  fi
done
unset editor_candidate


# TODO: Add --not-a-term once my versions of vim support it.
# http://vimhelp.appspot.com/starting.txt.html#--not-a-term
[[ "$EDITOR" = "vim" ]] && export MANPAGER="vim +MANPAGER -"
