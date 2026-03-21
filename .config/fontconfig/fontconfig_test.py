# Copyright 2025 David Mandelberg
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

from collections.abc import Collection, Iterable
import json
import pathlib
import subprocess
import unicodedata

import pytest


_DEFAULT_LANGUAGES = ("en", "en-us", "x-other")


def _params(
    character_name: str,
    *,
    languages: Collection[str] = _DEFAULT_LANGUAGES,
    emoji: str,
    monospace: str,
    sans_serif: str,
    serif: str,
    system_ui: str,
    explicit_fonts: Collection[str] = ("FreeSans", "FreeSerif"),
) -> Iterable[tuple[str, str, str, str]]:
    for language in languages:
        yield (character_name, language, "emoji", emoji)
        yield (character_name, language, "monospace", monospace)
        yield (character_name, language, "sans-serif", sans_serif)
        yield (character_name, language, "serif", serif)
        yield (character_name, language, "system-ui", system_ui)
        for explicit_font in explicit_fonts:
            yield (character_name, language, explicit_font, explicit_font)


pytestmark = [
    pytest.mark.parametrize(
        "character_name,language,font_description,expected_font",
        (
            *_params(
                "ARABIC LETTER ALEF",
                languages=(*_DEFAULT_LANGUAGES, "ar"),
                emoji="Noto Sans Arabic",
                monospace="DejaVu Sans Mono",
                sans_serif="Noto Sans Arabic",
                serif="Noto Sans Arabic",
                system_ui="Noto Sans Arabic UI",
                explicit_fonts=("DejaVu Sans", "FreeSerif"),
            ),
            *_params(
                "FACE PALM",
                emoji="Noto Color Emoji",
                monospace="Noto Color Emoji",
                sans_serif="Noto Color Emoji",
                serif="Noto Color Emoji",
                system_ui="Noto Color Emoji",
                explicit_fonts=(),
            ),
            *_params(
                "HEBREW LETTER ALEF",
                languages=(*_DEFAULT_LANGUAGES, "he"),
                emoji="Noto Sans Hebrew",
                monospace="Noto Sans Hebrew",
                sans_serif="Noto Sans Hebrew",
                serif="Noto Serif Hebrew",
                system_ui="Noto Sans Hebrew",
            ),
            *_params(
                "LATIN CAPITAL LETTER A",
                emoji="Noto Sans",
                monospace="DejaVu Sans Mono",
                sans_serif="Noto Sans",
                serif="Noto Serif",
                system_ui="Noto Sans",
            ),
            *_params(
                "MATHEMATICAL ITALIC SMALL A",
                emoji="Noto Sans Math",
                monospace="Noto Sans Math",
                sans_serif="Noto Sans Math",
                serif="Noto Sans Math",
                system_ui="Noto Sans Math",
            ),
            *_params(
                "MUSICAL SYMBOL WHOLE REST",
                emoji="Noto Music",
                monospace="Noto Music",
                sans_serif="Noto Music",
                serif="Noto Music",
                system_ui="Noto Music",
                explicit_fonts=("FreeSerif",),
            ),
            *_params(
                "PREVIOUS PAGE",
                emoji="Noto Sans Symbols",
                monospace="Noto Sans Symbols",
                sans_serif="Noto Sans Symbols",
                serif="Noto Sans Symbols",
                system_ui="Noto Sans Symbols",
                explicit_fonts=("FreeSerif",),
            ),
            *_params(
                "RATIO",
                emoji="Noto Sans Math",
                monospace="DejaVu Sans Mono",
                sans_serif="Noto Sans Math",
                serif="Noto Sans Math",
                system_ui="Noto Sans Math",
            ),
            *_params(
                # THe HK results are probably wrong, but I think the solution is
                # probably to change
                # /usr/share/fontconfig/conf.avail/70-fonts-noto-cjk.conf
                "RATIO",
                languages=("ja",),
                emoji="Noto Sans CJK HK",
                monospace="DejaVu Sans Mono",
                sans_serif="Noto Sans CJK JP",
                serif="Noto Serif CJK JP",
                system_ui="Noto Sans CJK HK",
            ),
        ),
    ),
]


def _fontconfig_escape(value: str) -> str:
    return value.replace("-", r"\-")


def test_fontconfig(
    character_name: str,
    language: str,
    font_description: str,
    expected_font: str,
) -> None:
    codepoint = ord(unicodedata.lookup(character_name))
    match_results = subprocess.run(
        (
            "fc-match",
            "--sort",
            ":".join(
                (
                    _fontconfig_escape(font_description),
                    f"lang={_fontconfig_escape(language)}",
                    f"charset={codepoint:04X}",
                )
            ),
            "family",
        ),
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    ).stdout.splitlines()
    families_with_charset = frozenset(
        subprocess.run(
            (
                "fc-list",
                f":charset={codepoint:04X}",
                "family",
            ),
            check=True,
            stdout=subprocess.PIPE,
            text=True,
        ).stdout.splitlines()
    )
    for match_result in match_results:
        if match_result in families_with_charset:
            actual_font = match_result
            break
    else:
        assert False, "No fonts found."

    assert actual_font == expected_font


def test_pango(
    character_name: str,
    language: str,
    font_description: str,
    expected_font: str,
    tmp_path: pathlib.Path,
) -> None:
    subprocess.run(
        (
            "pango-view",
            "--no-display",
            f"--font={font_description} 12",
            f"--language={language}",
            f"--text={unicodedata.lookup(character_name)}",
            f"--serialize-to={tmp_path}/pango.json",
        ),
        check=True,
    )

    serialized = json.loads((tmp_path / "pango.json").read_text())
    actual_font = serialized["output"]["lines"][0]["runs"][0]["font"][
        "description"
    ]
    assert actual_font == f"{expected_font} 12"
