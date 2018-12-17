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


" m17n-db (see https://www.nongnu.org/m17n/manual-en/m17nDBFormat.html) and
" its per-user configuration directories can have a lot of files that look
" like Lisp.
au BufNewFile,BufRead */{m17n,.m17n.d}/*.{ali,cs,dir,flt,fst,lnm,mic,mim,tbl}
    \ setf lisp
