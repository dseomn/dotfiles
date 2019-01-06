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


import datetime

from snipphthalate import plugin


_COPYRIGHT_HOLDERS = {
    'dseomn': 'David Mandelberg',
    'google': 'Google LLC',
}


class LicensePlugin(plugin.Jinja2SnippetPlugin):

  def __init__(self):
    super().__init__()
    self.variants.extend(_COPYRIGHT_HOLDERS.keys())

  def update_context(self, jinja2_context, snipphthalate_context, variant):
    jinja2_context['year'] = datetime.date.today().year
    if variant in _COPYRIGHT_HOLDERS:
      jinja2_context['copyright_holder'] = _COPYRIGHT_HOLDERS[variant]
