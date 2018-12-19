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


# Start the dbus session bus. Even though a system script will probably try to
# start it at some point anyway, starting it here means that other scripts in
# this directory can rely on the bus. At least on Debian and Ubuntu, the system
# scripts seem to either start dbus (and set DBUS_SESSION_BUS_ADDRESS) before
# this script is run, or they do it after, but only if DBUS_SESSION_BUS_ADDRESS
# is not already set. So hopefully it's relatively safe to (also) start it here
# if DBUS_SESSION_BUS_ADDRESS is unset.


[ -z "$DBUS_SESSION_BUS_ADDRESS" ] || return
command -v dbus-launch > /dev/null || return


eval "$(dbus-launch --exit-with-x11 --sh-syntax)"
