-- Copyright 2018 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     https://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.


local gears = require("gears")
local lfs = require("lfs")


-- TODO: Delete this.
dofile("/etc/xdg/awesome/rc.lua")


local config_dirs = {
  gears.filesystem.get_configuration_dir() .. "/rc",
}
for _, dir in ipairs(config_dirs) do
  for file in lfs.dir(dir) do
    if string.match(file, "%.lua$") then
      dofile(dir .. "/" .. file)
    end
  end
end
