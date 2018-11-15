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

" Don't try to be compatible with Vi.
set nocompatible

" Make text pretty.
syntax on
filetype plugin on

" Configure indentation.
set autoindent
set copyindent
set preserveindent
filetype indent on

" When joining lines, use single spaces instead of double spaces between
" sentences.
set nojoinspaces

" Enable bracketed paste: https://cirw.in/blog/bracketed-paste
let &t_ti = &t_ti . "\e[?2004h"
let &t_te = "\e[?2004l" . &t_te
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
set pastetoggle=<ESC>[201~

" Highlight search results, and map <C-L> to stop highlighting the most recent
" search.
set hlsearch
nnoremap <C-L> :nohlsearch<CR><C-L>

" Configure insert-mode completion.
set completeopt=menu,preview,longest
inoremap <expr> <CR> pumvisible() ? "<C-Y>" : "<CR>"
inoremap <expr> <ESC> pumvisible() ? "<C-E>" : "<ESC>"

" Timeout quickly when waiting to see whether another mapping or key character
" is coming. So far everything I'm mapping is either machine entered (e.g.,
" bracketed paste control codes) or a single keystroke.
set timeout
set timeoutlen=100
set ttimeoutlen=-1

" Configure things shown on the screen.
set laststatus=2
set showcmd

" Set filetype based on path.
au BufNewFile,BufRead ~/.config/tmux/conf.d/*.conf setf tmux

" Disable modelines, to minimize security risks of editing untrusted files.
set nomodeline

" Process local overrides.
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
