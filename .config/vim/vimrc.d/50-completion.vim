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


set completeopt=menu,preview,longest


" Add easier-to-remember mappings for using the pop-up menu. Note that the
" mappings are different between modes, because completion works differently
" in the different modes. If the highlighted candidate is not already filled
" in (insert mode), <CR> selects it. If the highlighted candidate is already
" filled in (command mode), <CR> works as usual. In all cases, <ESC> closes
" the popup without changing the text that's already filled in before the
" cursor.
"
" See https://github.com/vim/vim/discussions/16774 for why C-C is used in
" command-line mode.
inoremap <expr> <CR> pumvisible() ? "<C-Y>" : "<CR>"
inoremap <expr> <ESC> pumvisible() ? "<C-E>" : "<ESC>"
cnoremap <expr> <ESC> pumvisible() ? "<C-Y>" : "<C-C>"


set wildmenu
set wildmode=longest:full
set wildoptions=pum
