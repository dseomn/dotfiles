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


. ~/third_party/tap4sh/tap4sh.sh || exit 1
t4s_setup "$@"

. "${0%/*}/find_marker.sh" || t4s_bailout 'Error sourcing find_marker.sh.'


t4s_testcase 'no marker' '
  marker="$(find_marker nonexistent-259a2a8d-f1a5-4237-babf-b92dd0295ada)"
  t4s_try [ $? -ne 0 ]
  t4s_try [ "$marker" = "" ]
'


t4s_testcase 'finds marker in current directory' '
  dir="$(t4s_try mktemp -d)" || exit $?
  t4s_try touch "${dir}/some-marker"
  t4s_try cd "$dir"
  marker="$(t4s_try find_marker some-marker)" || exit $?
  t4s_try [ "$marker" = "$dir" ]
'


t4s_testcase 'finds marker in parent directory' '
  dir="$(t4s_try mktemp -d)" || exit $?
  t4s_try touch "${dir}/some-marker"
  t4s_try mkdir -p "${dir}/foo/bar"
  t4s_try cd "${dir}/foo/bar"
  marker="$(t4s_try find_marker some-marker)" || exit $?
  t4s_try [ "$marker" = "$dir" ]
'


t4s_testcase 'finds deepest marker' '
  dir="$(t4s_try mktemp -d)" || exit $?
  t4s_try touch "${dir}/some-marker"
  t4s_try mkdir -p "${dir}/foo/bar"
  t4s_try touch "${dir}/foo/bar/some-marker"
  t4s_try cd "${dir}/foo/bar"
  marker="$(t4s_try find_marker some-marker)" || exit $?
  t4s_try [ "$marker" = "${dir}/foo/bar" ]
'


t4s_testcase 'gives up after hitting the depth limit' '
  dir="$(t4s_try mktemp -d)" || exit $?
  t4s_try cd "$dir"
  t4s_try touch "some-marker"
  depth=0
  while [ "$depth" -lt 200 ]; do
    t4s_try mkdir x
    t4s_try cd x
    depth="$((depth + 1))"
  done
  marker="$(find_marker some-marker)"
  t4s_try [ $? -ne 0 ]
  t4s_try [ "$marker" = "" ]
'


t4s_done
