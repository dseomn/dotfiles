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


set hlsearch


" Map <C-L> to stop highlighting the most recent search.
nnoremap <C-L> :nohlsearch<CR><C-L>
vnoremap <C-L> :<C-U>nohlsearch<CR><C-L>gv
inoremap <C-L> <C-\><C-O>:nohlsearch<CR><C-\><C-O>:redraw<CR>
