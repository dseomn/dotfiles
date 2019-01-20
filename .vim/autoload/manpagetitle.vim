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


" Tries to parse a manpage title for the current buffer. On success, sets
" b:manpage_title to the title and, if available, sets b:manpage_section to
" the section, then returns true. On failure, returns false.
function! manpagetitle#TryParse() abort
  if &filetype != 'man' | return v:false | endif
  let l:matches = matchlist(expand('%:t'), '\m^\([^./]\+\)\.\([^./]*\)\~$')
  if empty(l:matches) | return v:false | endif
  let b:manpage_title = l:matches[1]
  let b:manpage_section = l:matches[2]
  return v:true
endfunction


" Returns a string containing b:manpage_title and, if available,
" b:manpage_section.
function! manpagetitle#Format() abort
  let l:ret = b:manpage_title
  if !empty(b:manpage_section)
    let l:ret .= '(' . b:manpage_section . ')'
  endif
  return l:ret
endfunction
