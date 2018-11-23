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


" Returns a pattern that matches any of the given patterns. This works with
" magic, nomagic, and very nomagic patterns.
function util#JoinPatterns(...)
  return '\(' . join(a:000, '\|') . '\)'
endfunction


" Returns the filename for the current buffer, or the empty string.
function util#CurrentFilename()
  if &filetype == 'netrw' && !empty(b:netrw_curdir)
    return b:netrw_curdir
  else
    return expand('%')
  endif
endfunction
