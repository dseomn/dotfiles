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


" This plugin adds commands to enable/disable a mode where 'n' goes to the
" next file and 'N' goes to the previous file. This is most useful when
" skimming a large number of files.


if exists("g:loaded_quickfilenav") | finish | endif
let g:loaded_quickfilenav = v:true


function s:Enable()
  nmap n :next<CR>
  nmap N :Next<CR>
endfunction
command QuickNavEnable call s:Enable()

function s:Disable()
  nunmap n
  nunmap N
endfunction
command QuickNavDisable call s:Disable()
