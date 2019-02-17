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


# Defaults.
DEFAULT_BACKGROUND = dseomn-sphere-and-tori.watermark-userhost.png
DEFAULT_FACE = dseomn-holding-dog.png


all: default-background.png
all: default-face.png
.PHONY: all


# Dependency to always rebuild a non-phony target.
.PHONY: always-rebuild


# Everywhere outside of this Makefile should reference one of these default-*
# filenames.
#
# These rules use convert so that no matter what file type/extension the default
# is, other things can refer to a single default-foo.png instead of needing to
# know the file type/extension.
default-background.png: $(DEFAULT_BACKGROUND) .default-background-stamp
	convert "$(DEFAULT_BACKGROUND)" "$@"
default-face.png: $(DEFAULT_FACE) .default-face-stamp
	convert "$(DEFAULT_FACE)" "$@"
	rm -f ~/.face
	convert "$@" -resize '96x96>' ~/.face


# Stamps that change when the value of $(DEFAULT_FOO) changes.
BUILD_STAMP = \
    old="$$(cat "$$stamp" 2> /dev/null || true)"; \
	[ "$$old" = "$$default" ] || printf '%s\n' "$$default" > "$$stamp"
.default-background-stamp: always-rebuild
	stamp="$@"; default="$(DEFAULT_BACKGROUND)"; $(BUILD_STAMP)
.default-face-stamp: always-rebuild
	stamp="$@"; default="$(DEFAULT_FACE)"; $(BUILD_STAMP)


# Watermark files with the username and hostname.
.png.watermark-userhost.png:
	watermark-userhost "$<" "$@"
.SUFFIXES: .png .watermark-userhost.png


dseomn-holding-dog.png:
	curl -L -o "$@" 'https://david.mandelberg.org/wp-content/uploads/2017/09/cropped-P1230630-raw-crop-square-full.jpg'

dseomn-sphere-and-tori.png:
	curl -L -o "$@" 'https://david.mandelberg.org/wp-content/uploads/2018/12/sphere-and-tori-7680x4320x24.png'
