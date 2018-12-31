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


" Interpret "\ec" as <M-c> for all ascii letters 'c'.
for s:char_nr in
    \ range(char2nr('a'), char2nr('z')) + range(char2nr('A'), char2nr('Z'))
  let s:char = nr2char(s:char_nr)
  " See :help :set-termcap
  exe 'set <M-' . s:char . ">=\e" . s:char
endfor
