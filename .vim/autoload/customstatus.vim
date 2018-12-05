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

  hi statusUnmodified cterm=reverse
  hi statusUnmodifiedRo cterm=reverse
  hi statusModified cterm=reverse ctermfg=DarkYellow
  hi statusModifiedRo cterm=reverse ctermfg=DarkRed
  hi statusMoreToEdit cterm=reverse ctermfg=DarkYellow
  hi statusNotCurrent cterm=reverse
  hi statusCurrentNormal cterm=reverse ctermfg=DarkBlue
  hi statusCurrentVisual cterm=reverse ctermfg=DarkMagenta
  hi statusCurrentSelect cterm=reverse ctermfg=DarkRed
  hi statusCurrentInsert cterm=reverse ctermfg=DarkGreen
  hi statusCurrentReplace cterm=reverse ctermfg=DarkYellow
  hi statusCurrent cterm=reverse
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
  call customstatus#SetFillChars()
  let [l:hl_left, l:hl_mid, l:hl_right] = customstatus#GetHighlights(a:winid)

  let l:parts = [l:hl_left]

  " Filename, left-truncated if needed.
  call add(l:parts, '%<%{customstatus#FileName()}')

  " File status.
  call add(l:parts, '%( [%R%M]%)')

  call add(l:parts, '%{customstatus#FileType()}')

  " Window status.
  call add(l:parts, '%( [%H%W]%)')

  call add(l:parts, '%{customstatus#QuickFixInfo()}')

  " Spacer.
  call add(l:parts, l:hl_mid . '    %=    ' . l:hl_right)

  " "(n of m)" marker when editing multiple files.
  call add(l:parts, '%(%a    %)')

  " Ruler
  call add(l:parts, '%-14.(%l,%c%V%) %P')

  " InitWindow is occasionally called in a weird state where win_getid()
  " doesn't return the correct window ID. Calling it with each status line
  " update ensures that the window ID in &l:statusline is kept up to date.
  call add(l:parts, '%{customstatus#InitWindow()}')

  return join(l:parts, '')
endfunction


function customstatus#SetFillChars()
  if !empty(s:current_stl_fill)
    exe 'set fillchars-=stl:' . s:current_stl_fill
  endif

  if &paste
    let s:current_stl_fill = '~'
  else
    let s:current_stl_fill = ''
  endif

  if !empty(s:current_stl_fill)
    exe 'set fillchars+=stl:' . s:current_stl_fill
  endif
endfunction


" Last character used by this script to fill the statusline of the current
" window.
let s:current_stl_fill = ''


function customstatus#GetHighlights(winid)
  let l:bufnr = winbufnr(a:winid)
  let l:buf_is_current = (l:bufnr == winbufnr(win_getid()))
  let l:win_is_current = (a:winid == win_getid())
  let l:GetB = function('getbufvar', [l:bufnr])

  let l:modified = l:GetB('&modified', v:false)
  let l:readonly = l:GetB('&readonly', v:false)
  let l:hl_modified = l:readonly ? '%#statusModifiedRo#' : '%#statusModified#'
  let l:hl_unmodified =
      \ l:readonly ? '%#statusUnmodifiedRo#' : '%#statusUnmodified#'
  if l:win_is_current && l:modified
    let l:hl_left = l:hl_modified
  elseif !l:win_is_current && l:modified && !l:buf_is_current
    let l:hl_left = l:hl_modified
  else
    let l:hl_left = l:hl_unmodified
  endif

  let l:mode = mode()
  if !l:win_is_current
    let l:hl_mid = '%#statusNotCurrent#'
  elseif l:mode == 'n'
    let l:hl_mid = '%#statusCurrentNormal#'
  elseif stridx("vV\<C-V>", l:mode) >= 0
    let l:hl_mid = '%#statusCurrentVisual#'
  elseif stridx("sS\<C-S>", l:mode) >= 0
    let l:hl_mid = '%#statusCurrentSelect#'
  elseif l:mode == 'i'
    let l:hl_mid = '%#statusCurrentInsert#'
  elseif l:mode == 'R'
    let l:hl_mid = '%#statusCurrentReplace#'
  else
    let l:hl_mid = '%#statusCurrent#'
  endif

  let l:more_to_edit = MoreToEdit(a:winid)
  if l:more_to_edit
    let l:hl_right = '%#statusMoreToEdit#'
  elseif l:win_is_current
    let l:hl_right = '%#statusCurrent#'
  else
    let l:hl_right = '%#statusNotCurrent#'
  endif

  return [l:hl_left, l:hl_mid, l:hl_right]
endfunction


function customstatus#FileName()
  let l:winid = win_getid()
  let l:filename = util#CurrentFilename()
  if getqflist({'winid': 0}).winid == l:winid
    return '[Quickfix List]'
  elseif getloclist(l:winid, {'winid': 0}).winid == l:winid
    return '[Location List]'
  elseif !empty(getcmdwintype()) && l:filename == '[Command Line]'
    return '[Command Line ' . getcmdwintype() . ']'
  elseif manpagetitle#TryParse()
    return '[' . manpagetitle#Format() . ']'
  elseif empty(l:filename)
    return '[No Name]'
  else
    return diralias#ShortenFilename(fnamemodify(l:filename, ':p'))
  endif
endfunction


function customstatus#FileType()
  " Quickfix windows can be distinguished by their pseudo file names.
  if &filetype == "qf" | return '' | endif

  " The %h/%H flag already marks help files.
  if &filetype == 'help' | return '' | endif

  let l:parts = []

  if &filetype == 'tar' && exists('b:zipfile')
    " Show 'zip' for .zip files instead of 'tar'.
    call add(l:parts, 'zip')
  elseif empty(&filetype)
    call add(l:parts, 'unkown')
  else
    call add(l:parts, &filetype)
  endif

  if !empty(&fileencoding) && &fileencoding != 'utf-8'
    call add(l:parts, &fileencoding)
  endif

  if &fileformat != 'unix'
    call add(l:parts, &fileformat)
  endif

  if !&endofline
    call add(l:parts, 'noeol')
  endif

  if exists('b:uncompressOk') && b:uncompressOk
    call add(l:parts, 'compressed')
  elseif exists('b:tarfile') && &filetype != 'tar'
    call add(l:parts, 'tar')
  elseif expand('%:p') =~ '^zipfile:'
    call add(l:parts, 'zip')
  endif

  if empty(l:parts)
    return ''
  else
    return ' [' . join(l:parts, ',') . ']'
  endif
endfunction


function customstatus#QuickFixInfo()
  if !exists('w:quickfix_title') | return '' | endif
  return ' ' . w:quickfix_title
endfunction
