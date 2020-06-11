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
"""Inhibits sleep under certain circumstances.

Unfortunately, systemd's logind.conf doesn't seem to allow per-user
configuration, so this uses systemd-inhibit to work around that. Currently it
just implements HandleLidSwitchExternalPower=ignore.
"""

import logging
import subprocess

import pyudev


class _Inhibiter:

  def __init__(self) -> None:
    self._online_mains_power_supplies = set()
    self._inhibit_process = None

  def _start_inhibit(self):
    if self._inhibit_process is not None:
      logging.debug('Already inhibited, nothing to do.')
      return
    logging.info('Inhibiting handle-lid-switch due to mains power.')
    self._inhibit_process = subprocess.Popen((
        'systemd-inhibit',
        '--what=handle-lid-switch',
        '--why=Plugged in to mains power.',
        '--',
        # Wait forever, until killed.
        'tail',
        '-f',
        '/dev/null',
    ))

  def _stop_inhibit(self):
    if self._inhibit_process is None:
      logging.debug('Not inhibited, nothing to do.')
      return
    self._inhibit_process.terminate()
    self._inhibit_process.wait()
    self._inhibit_process = None
    logging.info('Done inhibiting handle-lid-switch due to mains power.')

  def _handle_device(self, device: pyudev.Device) -> None:
    if (device.subsystem == 'power_supply' and
        device.attributes.asstring('type').casefold() == 'mains'):
      if device.properties.asbool('POWER_SUPPLY_ONLINE'):
        self._online_mains_power_supplies.add(device.device_path)
        self._start_inhibit()
      else:
        self._online_mains_power_supplies.discard(device.device_path)
        if not self._online_mains_power_supplies:
          self._stop_inhibit()

  def poll(self) -> None:
    context = pyudev.Context()
    monitor = pyudev.Monitor.from_netlink(context)
    monitor.filter_by('power_supply')
    monitor.start()
    try:
      for device in context.list_devices(subsystem='power_supply'):
        self._handle_device(device)
      for device in iter(monitor.poll, None):
        self._handle_device(device)
    finally:
      self._stop_inhibit()


def main() -> None:
  logging.getLogger().setLevel(logging.INFO)
  _Inhibiter().poll()


if __name__ == '__main__':
  main()
