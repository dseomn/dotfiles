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


# Which background to use by default.
DEFAULT = dseomn-sphere-and-tori.watermark-userhost.png


all: default.png
.PHONY: all


# Dependency to always rebuild a non-phony target.
.PHONY: always-rebuild


# Everywhere outside of this Makefile should just reference this filename.
default.png: $(DEFAULT) .default-stamp
	# Use convert here so that no matter what file type/extension $(DEFAULT)
	# is, other things can refer to a single default.png instead of needing
	# to know the file type/extension.
	convert "$(DEFAULT)" "$@"


# Stamp that changes when the value of $(DEFAULT) changes.
.default-stamp: always-rebuild
	old="$$(cat "$@" 2> /dev/null || true)"; \
	    [ "$${old}" = "$(DEFAULT)" ] || printf '%s\n' "$(DEFAULT)" > "$@"


# Watermark files with the username and hostname.
.png.watermark-userhost.png:
	watermark-userhost "$<" "$@"
.SUFFIXES: .png .watermark-userhost.png


dseomn-sphere-and-tori.png:
	curl -L -o "$@" 'https://david.mandelberg.org/wp-content/uploads/2018/12/sphere-and-tori-7680x4320x24.png'
