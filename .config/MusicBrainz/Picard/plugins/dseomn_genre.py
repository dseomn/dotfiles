# Copyright 2019 David Mandelberg and Google LLC
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

PLUGIN_NAME = 'David Mandelberg\'s Genre Plugin'
PLUGIN_AUTHOR = 'David Mandelberg'
PLUGIN_DESCRIPTION = """\
  Miscellaneous customizations to the genre tag.
  """
PLUGIN_VERSION = '1.0'
PLUGIN_API_VERSIONS = ['2.0']
PLUGIN_LICENSE = 'Apache-2.0'
PLUGIN_LICENSE_URL = 'https://www.apache.org/licenses/LICENSE-2.0'

import operator
import re
from typing import Generator, Optional, Tuple
import unicodedata

from picard import metadata
from picard import plugin

_MediumAndTrack = Tuple[int, Optional[int]]
_MediumAndTrackRange = Tuple[_MediumAndTrack, _MediumAndTrack]


def _parse_medium_dot_track(medium_dot_track: str) -> _MediumAndTrack:
  """Parses a single medium and optional track number.

  Args:
    medium_dot_track: A string like '1.5' (medium 1, track 5) or '2' (medium 2,
      all tracks).

  Returns:
    A tuple of the medium number (required) and track number (or None).
  """
  medium, _, track = medium_dot_track.partition('.')
  try:
    medium = int(medium)
    track = int(track) if track else None
  except ValueError:
    raise ValueError(
        'Invalid medium/track identifer: {!r}'.format(medium_dot_track))
  return medium, track


def _parse_extent(extent: str) -> Generator[_MediumAndTrackRange, None, None]:
  """Parses an extent of mediums/tracks.

  Args:
    extent: A string like '1-2+3.4' (mediums 1 through 2, and track 4 on medium
      3).

  Yields:
    Tuples of range start and range end (both inclusive). Each item in the tuple
    is a tuple of the form returned by _parse_medium_dot_track.
  """
  for track_range in extent.split('+'):
    first, _, last = track_range.partition('-')
    if not last:
      last = first
    yield _parse_medium_dot_track(first), _parse_medium_dot_track(last)


def _track_in_range(medium: int, track: int,
                    track_range: _MediumAndTrackRange) -> bool:
  """Returns whether a medium and track are within a range.

  Args:
    medium: Medium number.
    track: Track number.
    track_range: Range of tracks to test against.
  """
  for (boundary_medium, boundary_track), condition in zip(
      track_range, (operator.ge, operator.le)):
    if medium == boundary_medium:
      if boundary_track is not None and not condition(track, boundary_track):
        return False
    elif not condition(medium, boundary_medium):
      return False
  return True


def genre_filter(tagger, metadata_, *args):
  """Filters genres by extent.

  Geners without '@' are unaffected. Genres of the form 'foo/bar@1-2+3.4' are
  trimmed to 'foo/bar' on tracks matching _parse_extent('1-2+3.4'), and removed
  on all other tracks.

  Raises:
    ValueError: Invalid filter.
  """
  medium = int(metadata_['discnumber']) if 'discnumber' in metadata_ else None
  track = int(metadata_['tracknumber']) if 'tracknumber' in metadata_ else None

  filtered_genres = []
  for genre in metadata_.getall('genre'):
    genre, sep, extent = genre.partition('@')
    if sep and extent:
      if medium is None or track is None:
        raise ValueError('Cannot filter genre without medium and track info.')
      elif any((_track_in_range(medium, track, track_range)
                for track_range in _parse_extent(extent))):
        filtered_genres.append(genre)
    elif sep or extent:
      raise ValueError('Invalid genre: {!r}'.format(''.join((genre, sep,
                                                             extent))))
    else:
      # No filter, so the genre applies to everything.
      filtered_genres.append(genre)
  metadata_['genre'] = filtered_genres


metadata.register_track_metadata_processor(
    genre_filter, priority=plugin.PluginPriority.HIGH)


def genre_added(tagger, metadata_, *args):
  """Processes added/... genres.

  'added/unknown' is unaffected. 'added/YYYY', 'added/YYYY/MM', and
  'added/YYYY/MM/DD' are truncated to 'added/YYYY' and the untruncated date is
  put in a new 'dseomn_added' tag.
  """
  genres = metadata_.getall('genre')
  for i, genre in enumerate(genres):
    genre_parts = genre.split('/')
    if len(genre_parts) >= 2 and genre_parts[0].casefold() == 'added':
      genres[i] = '/'.join(genre_parts[:2])
      if genre.lower() != 'added/unknown':
        metadata_.add_unique('dseomn_added', '-'.join(genre_parts[1:]))


metadata.register_track_metadata_processor(genre_added)


def genre_from_instruments(tagger, metadata_, *args):
  """Adds genres from the ~instruments pseudo-tag."""
  genres = []
  for instrument in metadata_.getall('~instruments'):
    instrument = instrument.replace('/', '_')
    if 'vocals' in instrument:
      genres.append('performance/vocal')
      if instrument != 'vocals':
        genres.append('performance/vocal/' + instrument)
    else:
      genres.append('performance/instrument')
      genres.append('performance/instrument/' + instrument)
  for genre in genres:
    metadata_.add_unique('genre', genre)


metadata.register_track_metadata_processor(genre_from_instruments)


def genre_from_releasetype(tagger, metadata_, *args):
  """Adds genres based on the release type."""
  if 'soundtrack' in metadata_.getall('~secondaryreleasetype'):
    metadata_.add_unique('genre', 'context/soundtrack')


metadata.register_track_metadata_processor(genre_from_releasetype)


def genre_from_media(tagger, metadata_, *args):
  """Adds genres based on media types.

  Raises:
    ValueError: Unknown media type.
  """
  media_to_genres = {
      '7" Shellac': (
          'media/phonograph',
          'media/phonograph/by-material/shellac',
          'media/phonograph/by-shape/disc',
          'media/phonograph/by-size/7in',
      ),
      '10" Shellac': (
          'media/phonograph',
          'media/phonograph/by-material/shellac',
          'media/phonograph/by-shape/disc',
          'media/phonograph/by-size/10in',
      ),
      '12" Shellac': (
          'media/phonograph',
          'media/phonograph/by-material/shellac',
          'media/phonograph/by-shape/disc',
          'media/phonograph/by-size/12in',
      ),
      '7" Vinyl': (
          'media/phonograph',
          'media/phonograph/by-material/vinyl',
          'media/phonograph/by-shape/disc',
          'media/phonograph/by-size/7in',
      ),
      '10" Vinyl': (
          'media/phonograph',
          'media/phonograph/by-material/vinyl',
          'media/phonograph/by-shape/disc',
          'media/phonograph/by-size/10in',
      ),
      '12" Vinyl': (
          'media/phonograph',
          'media/phonograph/by-material/vinyl',
          'media/phonograph/by-shape/disc',
          'media/phonograph/by-size/12in',
      ),
      'Cassette': (
          'media/tape',
          'media/tape/cassette',
      ),
      'CD': (
          'media/optical',
          'media/optical/cd',
      ),
      'CD-R': (
          'media/optical',
          'media/optical/cd',
          'media/optical/cd/cd-r',
      ),
      'Enhanced CD': (
          'media/optical',
          'media/optical/cd',
          'media/optical/cd/enhanced-cd',
      ),
      'HDCD': (
          'media/optical',
          'media/optical/cd',
          'media/optical/cd/hdcd',
      ),
      'DVD': (
          'media/optical',
          'media/optical/dvd',
      ),
      'DVD-Video': (
          'media/optical',
          'media/optical/dvd',
          'media/optical/dvd/dvd-video',
      ),
      'DVD-Audio': (
          'media/optical',
          'media/optical/dvd',
          'media/optical/dvd/dvd-audio',
      ),
      'Digital Media': ('media/digital',),
  }
  for media in metadata_.getall('media'):
    if media not in media_to_genres:
      raise ValueError('No genres for media: {!r}'.format(media))
    for genre in media_to_genres[media]:
      metadata_.add_unique('genre', genre)


metadata.register_track_metadata_processor(genre_from_media)

# Regular expression that matches all sections of a string that should be
# removed when slugifying.
_SLUG_REMOVE_RE = re.compile(r'[^\s\w/-]+')

# Regular expression that matches all sections of a string that should be
# replaced with '-' when slugifying.
_SLUG_DASH_RE = re.compile(r'[\s-]+')


def genre_normalize(tagger, metadata_, *args):
  """Normalizes all genre tags.

  1. Converts all genres to slugs.
  2. Removes duplicates, and sorts the list.
  """
  genres = set()
  for genre in metadata_.getall('genre'):
    normalized = unicodedata.normalize('NFKC', genre).casefold()
    trimmed = _SLUG_REMOVE_RE.sub('', normalized).strip()
    slug = _SLUG_DASH_RE.sub('-', trimmed)
    genres.add(slug)
  metadata_['genre'] = list(sorted(genres))


metadata.register_track_metadata_processor(
    genre_normalize, priority=plugin.PluginPriority.LOW)


def genre_validate(tagger, metadata_, *args):
  """Validates genre tags.

  Raises:
    ValueError: Something was wrong with the genre tags.
  """
  genres = metadata_.getall('genre')

  if not any((genre.startswith('added/') for genre in genres)):
    raise ValueError('Missing an added/ genre tag.')

  if not any((genre.startswith('media/') for genre in genres)):
    raise ValueError('Missing a media/ genre tag.')

  if any((genre == 'media/phonograph' for genre in genres)):
    if not any(
        (genre.startswith('media/phonograph/by-size/') for genre in genres)):
      raise ValueError('Phonograph is missing size genre tag.')
    if not any(
        (genre.startswith('media/phonograph/by-speed/') for genre in genres)):
      raise ValueError('Phonograph is missing speed genre tag.')


metadata.register_track_metadata_processor(
    genre_validate, priority=plugin.PluginPriority.LOW - 1)
