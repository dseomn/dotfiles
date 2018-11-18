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


function customstatus#StatusLine()
  let l:parts = []

  " Filename, left-truncated if needed.
  call add(l:parts, '%<%F')

  " File status.
  call add(l:parts, '%( [%R%M]%)')

  call add(l:parts, '%{customstatus#FileType()}')

  " Window status.
  call add(l:parts, '%( [%H%W]%)')

  call add(l:parts, '%{customstatus#QuickFixInfo()}')

  " Spacer.
  call add(l:parts, '%=')

  " "(n of m)" marker when editing multiple files.
  call add(l:parts, '%(%a    %)')

  " Ruler
  call add(l:parts, '%-14.(%l,%c%V%) %P')

  return join(l:parts, '')
endfunction


function customstatus#FileType()
  if empty(&filetype) | return '' | endif

  " Quickfix windows can be distinguished by their pseudo file names.
  if &filetype == "qf" | return '' | endif

  " The %h/%H flag already marks help files.
  if &filetype == 'help' | return '' | endif

  return ' [' . &filetype . ']'
endfunction


function customstatus#QuickFixInfo()
  if !exists('w:quickfix_title') | return '' | endif
  return ' ' . w:quickfix_title
endfunction
