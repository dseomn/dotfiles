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

import jinja2
from snipphthalate import registry
from snipphthalate import snippet


_COPYRIGHT_HOLDERS = {
    'dseomn': 'David Mandelberg',
    'google': 'Google LLC',
}

_LICENSES = [
    'apache2',
]


def register_jinja2(registry_: registry.Registry,
                    environment: jinja2.Environment) -> None:
  for license in _LICENSES:
    for copyright_holder_tag, copyright_holder in _COPYRIGHT_HOLDERS.items():
      template = environment.get_template('license/{}.jinja2'.format(license))
      context = {
          'copyright_holder': copyright_holder,
          'year': datetime.date.today().year,
      }
      registry_.register(
          'license/{}-{}'.format(license, copyright_holder_tag),
          snippet.Jinja2Snippet(template, context))
