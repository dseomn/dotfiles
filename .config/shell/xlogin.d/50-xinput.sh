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


for __xinput_id in $(xinput --list --id-only); do
  # Enable all available scroll methods (libinput). This is mainly to enable
  # scrolling by holding a mouse's middle button down while moving the pointer.
  __xinput_scroll_available="$(
      xinput --list-props "$__xinput_id" |
          grep '^[[:space:]]*libinput Scroll Methods Available ([0-9]*):' |
          cut -f 2 -d :
  )"
  if [ -n "$__xinput_scroll_available" ]; then
    # Do not quote $__xinput_scroll_available, because it needs to be passed as
    # multiple arguments, split on whitespace.
    xinput --set-prop "$__xinput_id" 'libinput Scroll Method Enabled' \
        $__xinput_scroll_available
  fi
done
