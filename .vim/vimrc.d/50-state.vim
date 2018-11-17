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


" Where to store state. This should be somewhere that is backed up (not
" ~/.cache) so that unsaved work in swap files is not lost.
let s:state_dir = expand("~/.vim/state")


" Joins the state directory with all arguments, creates the resulting
" directory if needed, and then returns the directory name.
function! s:GetStateDir(...) abort
  let dir = join([s:state_dir] + a:000, "/")
  if !isdirectory(dir)
    call mkdir(dir, "p", 0700)
  endif
  return dir
endfunction


" Returns a state filename, creating the parent directory if needed.
function! s:GetStateFile(dir, file) abort
  return call("s:GetStateDir", a:dir) . "/" . a:file
endfunction


" Call with no args first to create s:state_dir with permissions 0700 if it
" doesn't already exist.
call s:GetStateDir()


" Swap files.
let &directory = s:GetStateDir("swap") . "//"
set swapfile


" Backups; enable for only ephemeral backups while overwriting a file.
let &backupdir = s:GetStateDir("backup")
set nobackup
set writebackup
set backupskip=


" Undo files; set location but disable the feature.
let &undodir = s:GetStateDir("undo")
set noundofile


" Viminfo.
let &viminfofile = s:GetStateFile([], "viminfo")


" Netrw history and bookmarks.
let g:netrw_home = s:GetStateDir("netrw")
