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


" Returns true iff there are more files in the arg list to edit. If specified,
" the first argument is the window ID to check the arg list in, instead of the
" current window.
"
" TODO: The window ID is curently ignored. Change this when there's a way to
" get the argument list with ID arglistid(winid)
function! moretoedit#MoreToEdit(...) abort
  for l:file in argv()
    if !has_key(s:visited, fnamemodify(l:file, ':p'))
      return v:true
    endif
  endfor
  return v:false
endfunction


" The keys of this dict are the files that have been visited. (Values are
" unused.)
let s:visited = {}


" Private function. Used in moretoedit augroup.
function! moretoedit#MarkVisited() abort
  let l:file = util#CurrentFilename()
  if !empty(l:file)
    let s:visited[fnamemodify(l:file, ':p')] = v:true
  endif
endfunction
