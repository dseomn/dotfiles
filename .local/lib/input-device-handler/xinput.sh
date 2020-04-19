#!/bin/sh

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

# TODO(https://gitlab.gnome.org/GNOME/gnome-settings-daemon/-/issues/518) Delete
# this file.


for __xinput_id in $(xinput --list --id-only); do
  __xinput_props="$(xinput --list-props "$__xinput_id")"
  while IFS= read -r __xinput_line; do
    case "$__xinput_line" in
      # Pick a scroll method (libinput). Unfortunately, only one method can be
      # enabled at a time. The flags, in order, are: two-finger, edge, button.
      # Documentation: libinput(4) and
      # https://wayland.freedesktop.org/libinput/doc/latest/scrolling.html.
      ?'libinput Scroll Methods Available ('*'):'?'1,'*)
        xinput --set-prop "$__xinput_id" 'libinput Scroll Method Enabled' 1 0 0
        ;;
      ?'libinput Scroll Methods Available ('*'):'?'0, 1,'*)
        xinput --set-prop "$__xinput_id" 'libinput Scroll Method Enabled' 0 1 0
        ;;
      ?'libinput Scroll Methods Available ('*'):'?'0, 0, 1')
        xinput --set-prop "$__xinput_id" 'libinput Scroll Method Enabled' 0 0 1
        ;;
    esac
  done <<EOF
$__xinput_props
EOF
done
