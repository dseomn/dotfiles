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
"""Tests for dconf_load_yaml.main."""

import os
import subprocess
import tempfile
import textwrap
import unittest
from unittest import mock

import jsonschema

from dconf_load_yaml import main


class LoadConfigTest(unittest.TestCase):

  def setUp(self):
    super().setUp()
    self._run = mock.create_autospec(subprocess.run)

  def _load_config(self, *args, **kwargs):
    """Calls load_config with appropriate mocks.

    Args:
      *args: Args to load_config.
      **kwargs: Ditto.

    Returns:
      Whatever load_config returns.
    """
    return main.load_config(*args, **kwargs, subprocess_run=self._run)

  def _mock_dconf_list(self, paths):
    """Mocks `dconf list`.

    Args:
      paths: Map from path passed to `donf list` to list of paths printed by
        `dconf list`.
    """

    def side_effect(args, **kwargs):
      if args[:2] != ['dconf', 'list']:
        return
      items = paths[args[2]]
      completed_process = mock.create_autospec(subprocess.CompletedProcess)
      completed_process.stdout = ''.join((item + '\n' for item in items))
      return completed_process

    self._run.side_effect = side_effect

  def test_set(self):
    preserved = self._load_config([
        {
            'key': 'foo',
            'value': '\'bar\'',
        },
        {
            'dir':
                'some-dir',
            'children': [{
                'dir':
                    'other-dir',
                'children': [
                    {
                        'key': 'kumquat',
                        'value': '17',
                    },
                    {
                        'key': 'apple',
                        'value': '\'orange\'',
                    },
                ],
            }],
        },
    ])
    self.assertEqual(
        {'/foo', '/some-dir/other-dir/kumquat', '/some-dir/other-dir/apple'},
        set(preserved))
    expected_calls = []
    for path, keyfile in (
        (
            '/',
            textwrap.dedent("""\
                [/]
                foo='bar'
            """),
        ),
        (
            '/some-dir/other-dir/',
            textwrap.dedent("""\
                [/]
                apple='orange'
                kumquat=17
            """),
        ),
    ):
      expected_calls.append(
          mock.call(
              ['dconf', 'load', path],
              input=keyfile,
              text=True,
              check=True))
    self.assertSequenceEqual(
        sorted(expected_calls), sorted(self._run.mock_calls))

  def test_reset(self):
    self._mock_dconf_list({
        '/': ['foo', 'bar', 'some-dir/'],
        '/some-dir/': ['other-dir/', 'apple', 'kumquat'],
        '/some-dir/other-dir/': ['apple', 'kumquat'],
    })
    preserved = self._load_config([
        {
            'key': 'foo',
            'reset': True,
        },
        {
            'dir': 'quux',
            'reset': False,
        },
        {
            'dir':
                'some-dir',
            'reset':
                True,
            'children': [
                {
                    'dir': 'other-dir',
                    'reset': False,
                    'children': [{
                        'key': 'kumquat',
                        'reset': True,
                    }],
                },
                {
                    'key': 'apple',
                    'reset': False,
                },
            ],
        },
    ])
    self.assertEqual({'/quux/', '/some-dir/'}, preserved)
    expected_reset_paths = (
        '/foo',  # key has reset=True
        '/some-dir/other-dir/kumquat',  # key has reset=True
        '/some-dir/kumquat',  # /some-dir/ has reset=True
    )
    expected_reset_calls = [
        mock.call(['dconf', 'reset', '-f', path], check=True)
        for path in expected_reset_paths
    ]
    actual_reset_calls = [
        call for call in self._run.mock_calls if call[1][0][1] == 'reset'
    ]
    self.assertSequenceEqual(
        sorted(expected_reset_calls), sorted(actual_reset_calls))

  def test_dry_run_does_not_write_to_dconf(self):
    self._mock_dconf_list({
        '/': ['foo', 'bar', 'some-dir/'],
        '/some-dir/': ['foo'],
    })
    self._load_config(
        [
            {
                'key': 'foo',
                'reset': True,
            },
            {
                'key': 'bar',
                'value': '42',
            },
            {
                'dir': 'some-dir',
                'children': [{
                    'key': 'foo',
                    'reset': True,
                }]
            },
        ],
        dry_run=True)
    actual_write_calls = [
        call for call in self._run.mock_calls if call[1][0][1] != 'list'
    ]
    self.assertSequenceEqual((), actual_write_calls)


class MainTest(unittest.TestCase):

  def setUp(self):
    super().setUp()
    self._run = mock.create_autospec(subprocess.run)

  def _main(self, files):
    """Calls main.

    Args:
      file: Map from filename to string file contents, to put in the directory
        read by main.
    """
    with tempfile.TemporaryDirectory() as conf_dir:
      for name, contents in files.items():
        with open(os.path.join(conf_dir, name), 'w') as fh:
          fh.write(contents)
      main.main(conf_dir, subprocess_run=self._run)

  def test_ignore_unknown_file(self):
    self._main({'foo.not-yaml': 'bar'})
    self._run.assert_not_called()

  def test_load_order(self):
    files = {}
    expected_reset_paths = []
    for i in range(100):
      files['{:02d}.yaml'.format(i)] = textwrap.dedent("""\
          - key: key-{:02d}
            reset: true
      """.format(i))
      expected_reset_paths.append('/key-{:02d}'.format(i))
    self._main(files)
    actual_reset_paths = [call[1][0][3] for call in self._run.mock_calls]
    self.assertSequenceEqual(actual_reset_paths, expected_reset_paths)

  def test_yaml_false_is_false(self):
    """Tests that 'false' in YAML is interpreted as False, not 'false'."""
    self._main({'foo.yaml': '- key: foo\n  reset: false\n'})
    self._run.assert_not_called()

  def test_schema_validation_error(self):
    with self.assertRaises(jsonschema.ValidationError):
      self._main({'foo.yaml': '- key: foo\n  reset: "false"\n'})

  def test_templating(self):
    os.environ['FOO'] = 'kumquat'
    self._main({
        'foo.yaml':
            textwrap.dedent("""\
                - key: foo
                  value: "'{{ env['FOO'] }}'"
            """),
    })
    expected_keyfile = textwrap.dedent("""\
        [/]
        foo='kumquat'
    """)
    self.assertEqual(1, len(self._run.mock_calls))
    self.assertEqual(expected_keyfile, self._run.mock_calls[0][2]['input'])


if __name__ == '__main__':
  unittest.main()
