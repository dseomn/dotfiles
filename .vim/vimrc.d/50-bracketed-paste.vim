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


" General background on bracketed paste: https://cirw.in/blog/bracketed-paste


" Enable and disable bracketed paste when starting and stopping vim.
let &t_ti = &t_ti . "\e[?2004h"
let &t_te = "\e[?2004l" . &t_te


" Set mappings for entering and exiting a bracketed paste.
nmap <ESC>[200~ :set paste<CR>i
nmap <ESC>[201~ :set nopaste<CR>
smap <expr> <ESC>[200~ ""
smap <expr> <ESC>[201~ ""
xmap <expr> <ESC>[200~ ""
xmap <expr> <ESC>[201~ ""
omap <expr> <ESC>[200~ ""
omap <expr> <ESC>[201~ ""
imap <ESC>[200~ <C-\><C-O>:set paste<CR>
imap <ESC>[201~ <C-\><C-O>:set nopaste<CR>
cmap <expr> <ESC>[200~ ""
cmap <expr> <ESC>[201~ ""


" Mappings are ignored in paste mode, so this makes the end-of-bracketed-paste
" sequence exit paste mode. Outside of paste mode, mappings take precedence
" over pastetoggle, so this sequence won't be used to enter paste mode.
set pastetoggle=<ESC>[201~
