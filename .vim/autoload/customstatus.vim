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


" Start using the status lines in this file.
function customstatus#Init()
  " Set the global statusline so that any window without a local statusline
  " will call InitWindow(). InitWindow() then changes the local statusline.
  set statusline=%{customstatus#InitWindow()}

  hi statusInactiveModified cterm=reverse ctermfg=DarkYellow
  hi statusInactive cterm=reverse
  hi statusActiveNormal cterm=bold,reverse ctermfg=DarkBlue
  hi statusActiveVisual cterm=bold,reverse ctermfg=DarkMagenta
  hi statusActiveInsert cterm=bold,reverse ctermfg=DarkGreen
  hi statusActive cterm=bold,reverse
endfunction


" Stop using the status lines in this file.
function customstatus#Clear()
  set statusline=
  tabdo windo setlocal statusline<
endfunction


" Initialize the current window.
function customstatus#InitWindow()
  let &l:statusline = '%!customstatus#StatusLine(' . string(win_getid()) . ')'
endfunction


function customstatus#StatusLine(winid)
  let l:parts = []

  call add(l:parts, customstatus#GetHighlight(a:winid))

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


function customstatus#GetHighlight(winid)
  let l:bufnr = winbufnr(a:winid)
  let l:buf_is_current = (l:bufnr == winbufnr(win_getid()))
  let l:win_is_current = (a:winid == win_getid())
  let l:GetB = function('getbufvar', [l:bufnr])

  if !l:win_is_current
    if l:GetB('&modified', v:false) && !l:buf_is_current
      return '%#statusInactiveModified#'
    else
      return '%#statusInactive#'
    endif
  endif

  let l:mode = mode()
  if l:mode == 'n'
    return '%#statusActiveNormal#'
  elseif stridx("vV\<C-V>sS\<C-S>", l:mode) >= 0
    return '%#statusActiveVisual#'
  elseif stridx("iR", l:mode) >= 0
    return '%#statusActiveInsert#'
  else
    return '%#statusActive#'
  endif
endfunction


function customstatus#FileType()
  " Quickfix windows can be distinguished by their pseudo file names.
  if &filetype == "qf" | return '' | endif

  " The %h/%H flag already marks help files.
  if &filetype == 'help' | return '' | endif

  if &filetype == 'tar' && exists('b:zipfile')
    " Show 'zip' for .zip files instead of 'tar'.
    let l:ft = 'zip'
  else
    let l:ft = &filetype
  endif

  if exists('b:uncompressOk') && b:uncompressOk
    let l:ft .= '*'
  elseif exists('b:tarfile') && &filetype != 'tar'
    let l:ft .= '*'
  elseif expand('%:p') =~ '^zipfile:'
    let l:ft .= '*'
  endif

  return empty(l:ft) ? '' : ' [' . l:ft . ']'
endfunction


function customstatus#QuickFixInfo()
  if !exists('w:quickfix_title') | return '' | endif
  return ' ' . w:quickfix_title
endfunction
