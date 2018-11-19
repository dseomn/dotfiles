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


" Returns a shortened version of the given filename. See
" ~/.local/lib/dir-alias/dir-alias.sh for more info.
function diralias#ShortenFilename(filename)
  if has_key(s:cache, a:filename)
    return s:cache[a:filename]
  endif

  " Pass the filename as standard input to minimize the risk of an untrusted
  " filename being misinterpreted by the shell.
  silent let l:shortened =
      \ system('f=$(cat); dir-alias-shorten "$f"', a:filename)
  if v:shell_error
    " Use the original if there's an error.
    let l:shortened = a:filename
  endif

  let s:cache[a:filename] = l:shortened
  return l:shortened
endfunction


" Map from filename to shortened filename.
let s:cache = {}
