#!/usr/bin/env python3

# Copyright 2020 Google LLC
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
"""Listens to udev events in order to configure input devices."""

import os
import pyudev
import subprocess

_SUBSYSTEM = 'input'


def setup_xinput() -> None:
  subprocess.run(
      (f'{os.environ["HOME"]}/.local/lib/input-device-handler/xinput.sh',),
      check=True,
  )


def main() -> None:
  context = pyudev.Context()
  monitor = pyudev.Monitor.from_netlink(context)
  monitor.filter_by(_SUBSYSTEM)
  monitor.start()
  for device in context.list_devices(subsystem=_SUBSYSTEM):
    setup_xinput()
  for device in iter(monitor.poll, None):
    if device.action == 'add':
      setup_xinput()


if __name__ == '__main__':
  main()
