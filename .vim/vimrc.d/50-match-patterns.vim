" Copyright 2018 Google LLC
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
"
"     https://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.


" Generic TODO highlights.
call custommatches#AddPatterns(
    \ 'Todo',
    \ '\<BUGS\?\>',
    \ '\<DO NOT\( [A-Z]\+\)\+\>',
    \ '\<FIX\(ME\)\?\>',
    \ '\<NOTES\?\>',
    \ '\<TBD\>',
    \ '\<TODO[sS]\?\>',
    \ '\<WARNINGS\?\>',
    \ '\<XXX\>',
    \)


" https://tools.ietf.org/html/rfc2119
hi link rfc2119Keyword Todo
call custommatches#AddPatterns(
    \ 'rfc2119Keyword',
    \ '\<\(MUST\|SHALL\|SHOULD\)\( NOT\)\?\>',
    \ '\<\(REQUIRED\|RECOMMENDED\|MAY\)\>',
    \)


" Merge markers.
hi link mergeMarker Error
function s:MergeMarkerPattern(char_pattern)
  return '^\(' . a:char_pattern . '\)\1\{3,7}\(\s.*\)\?$'
endfunction
call custommatches#AddPatterns(
    \ 'mergeMarker',
    \ s:MergeMarkerPattern('[<|=]'),
    \)
" An email message with nested replies could easily have lines that look like
" '>>>>>>>' merge markers, so don't highlight that pattern for emails.
call custommatches#AddPatternsIf(
    \ {-> &filetype != 'mail'},
    \ 'mergeMarker',
    \ s:MergeMarkerPattern('>'),
    \)


" Various whitespace errors.
hi link invalidWhitespace Todo

" 1. Trailing whitespace, except when the cursor is on the end of the line.
" 2. Space(s) before a tab.
" 3. Blank lines at the beginning of the file, except when the cursor is at
"    the beginning of the file.
" 4. Blank lines at the end of the file, except when the cursor is at the end
"    of the file.
call custommatches#AddPatterns(
    \ 'invalidWhitespace',
    \ '\s\+\%#\@1<!$',
    \ ' \+\ze\t',
    \ '\v%^%#@1<!\n*$\n?',
    \ '\v^\n*%#@1<!%$\n?',
    \)

" Any tabs, but only when expandtab is set.
call custommatches#AddPatternsIf(
    \ {-> &expandtab},
    \ 'invalidWhitespace',
    \ '\t',
    \)


" Highlight the three-blank-line separator between vroom tests. Use a match
" instead of a syntax because syntax doesn't seem to be able to highlight
" blank lines.
hi link vroomTestSeparator MatchParen
call custommatches#AddPatternsIf(
    \ {-> &filetype ==# 'vroom'}, 'vroomTestSeparator', '\v.\n\zs\n\n\n')
