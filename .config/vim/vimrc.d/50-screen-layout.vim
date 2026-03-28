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


" Let the terminal handle bidi rendering and shaping (e.g., for Arabic).
set termbidi
" TODO: https://github.com/vim/vim/issues/7148 - Remove this.
exe "set fillchars+=vert:\u2800"


" Always show the status line, and customize it.
set laststatus=2
call customstatus#Init()


" Don't override the terminal title.
set notitle


" Highlight the first column after textwidth in modifiable buffers. In
" nomodifiable buffers like man pages and vim help, it's not useful.
function! s:UpdateColorColumn() abort
  if &modifiable
    setlocal colorcolumn=+1
  else
    setlocal colorcolumn=
  endif
endfunction
au VimEnter * tabdo windo call s:UpdateColorColumn()
au WinNew,BufWinEnter,BufWinLeave * call s:UpdateColorColumn()
au OptionSet modifiable call s:UpdateColorColumn()


" Open new vertical splits to the right, and make it easier to use vertical
" splits.
set splitright
command -nargs=? -complete=help H vert help <args>
