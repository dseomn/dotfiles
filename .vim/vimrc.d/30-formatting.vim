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


" Set sensible defaults for indentation.
set autoindent
set copyindent
set preserveindent
set tabstop=8
set shiftwidth=2
set softtabstop=-1
set expandtab


" Enable per-filetype indentation.
filetype indent on


" Wrap at 80 columns by default.
set textwidth=80


" Continue comment blocks when adding a newline in one.
set formatoptions+=ro

" Try to correctly rewrap lists.
set formatoptions+=n
let s:list_item_number = util#JoinPatterns(
    \ '(\?\d\+)',
    \ '\[\?\d\+\]',
    \ '{\?\d\+}',
    \ '\d\+[:.\t ]',
    \)
let s:list_item_bullet = '[*.\-+]'
let s:list_item = util#JoinPatterns(s:list_item_number, s:list_item_bullet)
let &formatlistpat = '\m^\s*' . s:list_item . '\s\+'

" Remove extra comment leaders when joining lines.
set formatoptions+=j
