# Copyright 2021 Google LLC
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

import random
import secrets

from snipphthalate import plugin


def _random_mac():
  # https://en.wikipedia.org/wiki/MAC_address
  octets = list(secrets.token_bytes(nbytes=6))
  octets[0] |= 0x02  # Locally-administered.
  octets[0] &= ~0x01  # Unicast.
  return ':'.join(f'{octet:02x}' for octet in octets)


_VARIANTS = {
    'hex4': lambda: secrets.token_hex(nbytes=4),
    'mac': _random_mac,
    'port': lambda: str(random.randint(1024, 49151)),
}


class RandomPlugin(plugin.Jinja2SnippetPlugin):

  def __init__(self):
    super().__init__()
    self.variants[:] = _VARIANTS

  def is_applicable(self, snipphthalate_context, tag, variant):
    return variant is not None

  def update_context(self, jinja2_context, snipphthalate_context, variant):
    jinja2_context['value'] = _VARIANTS[variant]()
