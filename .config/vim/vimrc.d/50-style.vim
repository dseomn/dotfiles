" Copyright 2025 David Mandelberg
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

" TODO: https://github.com/vim/vim/issues/17125 - Upstream parts of this file.


" https://man.openbsd.org/style
function! s:OpenBSDKNF() abort
  setlocal cinoptions=+0.5s,(0.5s,u0.5s,U1
  setlocal nocopyindent
  setlocal noexpandtab
  setlocal nopreserveindent
  setlocal shiftwidth=0
  setlocal tabstop=8
  setlocal textwidth=80
endfunction


augroup style_detect
  au!
  au BufNewFile,BufRead */tmux/*.{c,h} call s:OpenBSDKNF()
augroup END
