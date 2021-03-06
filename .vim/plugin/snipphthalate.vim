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


if !has('python3') | finish | endif


command! -nargs=1 -complete=customlist,snipphthalate#CompleteTags
    \ Snipphthalate call snipphthalate#InsertSnippet(<f-args>)


nmap <M-s> :Snipphthalate<SPACE>
imap <M-s> <C-\><C-O>:Snipphthalate<SPACE>


" Highlight snippet variable placeholders.
highlight default link snipphthalatePlaceholder Error
call custommatches#AddPatterns('snipphthalatePlaceholder', '\m@!.\{-}!@')
