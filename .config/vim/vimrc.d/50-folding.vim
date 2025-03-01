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


" Enable syntax folding by default.
set foldenable
set foldmethod=syntax

" Start with nothing folded.
set foldlevelstart=99

" By default '#' is treated specially with indent folding. Since I'm using
" syntax folding for C-like languages, the special handling of '#' isn't
" useful there. Disable it so that foldmethod=indent works better for
" languages were '#' starts a comment.
set foldignore=
