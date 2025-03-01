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


" Re-enables the given highlight groups. (Groups are assumed to be enabled by
" default, and only disabled by functions in this file.)
function! highlighttoggles#Enable(groups) abort
  for l:group in a:groups
    if !has_key(s:hl_restore, l:group) | continue | endif
    exe 'hi ' . s:hl_restore[l:group]
    unlet s:hl_restore[l:group]
  endfor
endfunction


" Disables the given highlight groups. This function saves the previous
" highlight values so that they can be restored in highlighttoggles#Enable().
function! highlighttoggles#Disable(groups) abort
  for l:group in a:groups
    if has_key(s:hl_restore, l:group) | continue | endif
    let s:hl_restore[l:group] = substitute(
        \ execute('hi ' . l:group),
        \ '\C^\n\?\([a-zA-Z][^\n]*\)\s\+xxx\s\+\([^\n]\+\)\(\n.*\)\?$',
        \ '\1 \2',
        \ '')
    exe 'hi ' . l:group . ' NONE'
  endfor
endfunction


" Toggles the given highlight groups.
function! highlighttoggles#Toggle(groups) abort
  for l:group in a:groups
    if has_key(s:hl_restore, l:group)
      call highlighttoggles#Enable([l:group])
    else
      call highlighttoggles#Disable([l:group])
    endif
  endfor
endfunction


" Map from disabled highlight group name to :highlight arguments that will
" re-enable that group.
let s:hl_restore = {}
