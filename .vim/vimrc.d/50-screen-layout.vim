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


" Always show the status line, and customize it.
set laststatus=2
call customstatus#Init()


" Don't override the terminal title.
set notitle


set showcmd


" Highlight the first column after textwidth.
set colorcolumn=+1


" Open new vertical splits to the right, and make it easier to use vertical
" splits.
set splitright
command -nargs=? -complete=help H vert help <args>
