" Copyright 2019 Google LLC
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


" Process input when vim is used as a pager.
function! pager#Pager() abort
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal modifiable

  let l:save_view = winsaveview()

  " Collapse backspaces.
  silent keepjumps keeppatterns %s/\v.\b//ge

  " Remove Select Graphic Rendition codes.
  silent keepjumps keeppatterns %s/\v\e\[\A*m//ge

  call winrestview(l:save_view)

  " Re-detect the filetype after removing escape sequences.
  filetype detect
  if $PAGER_TYPE is# 'man'
    setfiletype man
  endif

  setlocal nomodified
  setlocal nomodifiable
endfunction
