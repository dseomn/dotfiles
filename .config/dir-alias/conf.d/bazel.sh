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


. ~/.local/lib/shutil/find_marker.sh


# Creates ephemeral aliases for bazel directories. See
# https://docs.bazel.build/versions/master/output_directories.html for layout.
__bazel_ephemeral_factory() {
  if ! __bea_ws_dir="$(find_marker WORKSPACE)"; then
    unset __bea_ws_dir
    return 0
  fi

  # The path relative to the workspace root, or relative to a bazel-* directory.
  __bea_relpath="$(pwd -L)/"
  __bea_relpath="${__bea_relpath#"${__bea_ws_dir}/"}"
  __bea_relpath="${__bea_relpath#bazel-*/}"

  dir_alias bazel_workspace_root "${__bea_ws_dir}"
  dir_alias bazel_workspace "${__bea_ws_dir}/${__bea_relpath}"
  dir_alias bazel_bin "${__bea_ws_dir}/bazel-bin/${__bea_relpath}"
  dir_alias bazel_genfiles "${__bea_ws_dir}/bazel-genfiles/${__bea_relpath}"
  dir_alias bazel_testlogs "${__bea_ws_dir}/bazel-testlogs/${__bea_relpath}"
  dir_alias bazel_include "${__bea_ws_dir}/bazel-include/${__bea_relpath}"

  unset __bea_ws_dir
  unset __bea_relpath
}

dir_alias_register_ephemeral_factory __bazel_ephemeral_factory
