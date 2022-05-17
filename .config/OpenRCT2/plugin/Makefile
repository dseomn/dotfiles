# Copyright 2022 Google LLC
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


all:
.PHONY: all


ParkRatingInspector-v0.2.zip:
	curl -L -o '$@' 'https://github.com/Basssiiie/OpenRCT2-ParkRatingInspector/releases/download/v0.2/ParkRatingInspector-v0.2.zip'
ParkRatingInspector.js: ParkRatingInspector-v0.2.zip
	unzip 'ParkRatingInspector-v0.2.zip' '$@'
	touch '$@'
all: ParkRatingInspector.js


benchwarmer.js:
	curl -L -o '$@' 'https://github.com/tubbo/openrct2-benchwarmer/releases/download/v1.0.0/benchwarmer.js'
all: benchwarmer.js


live-ride-measurements.js:
	curl -L -o '$@' 'https://github.com/Phelicks/openrct2-live-ride-measurements/releases/download/v0.3.5/live-ride-measurements.js'
all: live-ride-measurements.js


openrct2-price-manager-1.1.1.js:
	curl -L -o '$@' 'https://github.com/Sadret/openrct2-price-manager/releases/download/v1.1.1/openrct2-price-manager-1.1.1.js'
all: openrct2-price-manager-1.1.1.js
