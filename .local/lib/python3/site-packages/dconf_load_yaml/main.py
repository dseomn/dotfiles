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
"""Module to load DConf settings from jinja-templated yaml files.

The ini-like format supported by dconf doesn't appear to have any way to use
environment variables in values, or to selectively reset keys. This does.

Example config file:

  - dir: path
    children:
    - dir: to
      children:
      - dir: dir
        reset: true  # Resets everything not explicitly listed in children.
        children:
        - dir: sub-directory
          reset: false  # Shadow's the parent directory's reset value.
        - key: some-key
          value: "['a', 'b']"  # YAML-quoted GVariant value.
        - key: other-key
          reset: false  # This key is neither set or reset.
        - key: path-to-a-file
          value: "'{{ env['HOME'] }}/some/path'"
"""

import argparse
import os
import subprocess
import textwrap

import jinja2
import jsonschema
import yaml

_SCHEMA = {
    '$schema': 'http://json-schema.org/draft-04/schema#',
    'type': 'array',
    'items': {
        'oneOf': [
            {
                'type': 'object',
                'required': ['dir'],
                'properties': {
                    'dir': {
                        'type': 'string',
                    },
                    'reset': {
                        'type': 'boolean',
                    },
                    'children': {
                        '$ref': '#',
                    },
                },
            },
            {
                'type': 'object',
                'required': ['key'],
                'properties': {
                    'key': {
                        'type': 'string',
                    },
                    'reset': {
                        'type': 'boolean',
                    },
                    'value': {
                        'type': 'string',
                    },
                },
            },
        ],
    },
}


def _is_key(config_item, parent):
  """Returns true if the item is a key, false if it's a directory.

  Args:
    config_item: A single item from the YAML config, as a Python dict.
    parent: DConf path to the item's parent directory.

  Raises:
    ValueError: The item is neither or both.
  """
  if 'dir' in config_item and 'key' in config_item:
    raise ValueError(
        'Item in {!r} has both \'dir\' and \'key\' attrs.'.format(parent))
  elif 'dir' not in config_item and 'key' not in config_item:
    raise ValueError(
        'Item in {!r} has neither a \'dir\' nor a \'key\' attr.'.format(parent))
  return 'key' in config_item


def _set_keys_in_dir(path, values, subprocess_run, dry_run=False):
  """Sets DConf keys in a directory.

  Args:
    path: Directory.
    values: Map from relative key to value to set in the directory.
    subprocess_run: Normally subprocess.run, but can be overriden in tests.
    dry_run: If true, just print actions.
  """
  keyfile = ['[/]\n']
  # Sort keys to make unit testing easier. (It doesn't matter to dconf load.)
  for key, value in sorted(values.items(), key=lambda kv: kv[0]):
    keyfile.append('{}={}\n'.format(key, value))
  keyfile = ''.join(keyfile)
  if dry_run:
    print('Load: {}\n{}'.format(path, textwrap.indent(keyfile, '  ')))
  else:
    subprocess_run(
        ['dconf', 'load', path],
        input=keyfile,
        text=True,
        check=True)


def _reset_path(path, subprocess_run, preserve=(), dry_run=False):
  """Selectively resets a key or directory.

  Args:
    path: Absolute path to selectively reset, e.g., '/', '/foo/', or '/foo/bar'.
    preserve: Collection of absolute child paths to not reset. Dirs end in '/',
      keys don't. This is ignored if path is a key.
    subprocess_run: Normally subprocess.run, but can be overriden in tests.
    dry_run: If true, just print actions.
  """
  if not preserve or not path.endswith('/'):
    if dry_run:
      print('Reset: {}'.format(path))
    else:
      subprocess_run(['dconf', 'reset', '-f', path], check=True)
    return
  dconf_list = subprocess_run(
      ['dconf', 'list', path],
      stdout=subprocess.PIPE,
      text=True,
      check=True)
  for child in dconf_list.stdout.splitlines():
    child_path = path + child
    if child_path in preserve:
      continue
    _reset_path(
        child_path,
        subprocess_run, {x for x in preserve if x.startswith(child_path)},
        dry_run=dry_run)


def load_config(config, path='/', dry_run=False, subprocess_run=subprocess.run):
  """Loads DConf values from yaml.

  Args:
    config: Python list parsed from a YAML config. See module docstring for
      format.
    path: Root DConf path of the config, e.g., '/' or '/foo/'.
    dry_run: If true, just print actions.
    subprocess_run: Normally subprocess.run, but can be overriden in tests.

  Returns:
    Collection of paths to not reset, suitable for passing as the preserve
    argument to _reset_path.
  """
  preserve = set()
  values = {}  # Map from key to value to set in the current directory.
  for config_item in config:
    if _is_key(config_item, path):
      config_item_path = path + config_item['key']
      if 'value' in config_item:
        values[config_item['key']] = config_item['value']
        preserve.add(config_item_path)
      if 'reset' in config_item:
        if config_item['reset']:
          _reset_path(config_item_path, subprocess_run, dry_run=dry_run)
        else:
          preserve.add(config_item_path)
    else:
      config_item_path = path + config_item['dir'] + '/'
      if 'children' in config_item:
        config_item_preserve = load_config(
            config_item['children'],
            config_item_path,
            dry_run=dry_run,
            subprocess_run=subprocess_run)
      else:
        config_item_preserve = set()
      if 'reset' in config_item:
        if config_item['reset']:
          _reset_path(
              config_item_path,
              subprocess_run,
              config_item_preserve,
              dry_run=dry_run)
        # Preserve the directory either way. Either it was already reset, so
        # preserving it is an optimization, or the entire directory needs to be
        # preserved.
        preserve.add(config_item_path)
      else:
        # No explicit reset parameter, so preserve the preserved paths from the
        # children.
        preserve.update(config_item_preserve)
  if values:
    _set_keys_in_dir(path, values, subprocess_run, dry_run=dry_run)
  return preserve


def main(config_directory, dry_run=False, subprocess_run=subprocess.run):
  """Main.

  Args:
    dry_run: If true, nothing is changed in dconf, and actions are printed
      instead.
    subprocess_run: Normally subprocess.run, but can be overriden in tests.
  """
  jinja_env = jinja2.Environment(
      loader=jinja2.FileSystemLoader(config_directory), autoescape=False)
  with os.scandir(config_directory) as dir_iter:
    for entry in sorted(dir_iter, key=lambda entry: entry.name):
      if not entry.name.endswith('.yaml'):
        continue
      config = yaml.safe_load(
          jinja_env.get_template(entry.name).render(env=os.environ))
      jsonschema.validate(config, _SCHEMA)
      load_config(config, dry_run=dry_run, subprocess_run=subprocess_run)


if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument(
      '--dry-run', dest='dry_run', action='store_const', const=True)
  parser.add_argument(
      '--force', dest='dry_run', action='store_const', const=False)
  args = parser.parse_args()
  if args.dry_run is None:
    raise RuntimeError('Specify either --dry-run or --force.')
  main(
      os.path.join(os.getenv('HOME'), '.config', 'dconf-load-yaml', 'conf.d'),
      dry_run=args.dry_run)
