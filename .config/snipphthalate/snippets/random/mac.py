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

import secrets

from snipphthalate import plugin


class RandomMacPlugin(plugin.Jinja2SnippetPlugin):

  def update_context(self, jinja2_context, snipphthalate_context, variant):
    # https://en.wikipedia.org/wiki/MAC_address
    octets = list(secrets.token_bytes(nbytes=6))
    octets[0] |= 0x02  # Locally-administered.
    octets[0] &= ~0x01  # Unicast.
    jinja2_context['random_mac'] = ':'.join(f'{octet:02x}' for octet in octets)
