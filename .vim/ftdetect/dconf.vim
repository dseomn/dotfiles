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


" DConf keyfiles are similar to cfg/ini:
" https://help.gnome.org/admin/system-admin-guide/stable/dconf-keyfiles.html.en.
" However, since they don't seem to support line continuations, clear
" textwidth.
au BufNewFile,BufRead ~/.config/dconf-autoload/*.cfg
    \ setl textwidth=0 | setf cfg
