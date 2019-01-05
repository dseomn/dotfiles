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


let s:save_cpo = &cpo
set cpo&vim


if !exists('g:snipphthalate_config_dirs')
  " Use the default, as determined by the snipphthalate python code.
  let g:snipphthalate_config_dirs = v:none
endif


py3 <<EOF
import snipphthalate.context
import snipphthalate.registry

if vim.vars['snipphthalate_config_dirs'] is None:
  _snipphthalate_config_dirs = None
else:
  _snipphthalate_config_dirs = [
      dir.decode() for dir in vim.vars['snipphthalate_config_dirs']]

_snipphthalate_registry = snipphthalate.registry.default_registry(
    _snipphthalate_config_dirs)

def _snipphthalate_tags():
    return list(sorted(_snipphthalate_registry.tags(
        snipphthalate.context.VimContext(vim))))

def _snipphthalate_render(tag):
    return _snipphthalate_registry.render(
        tag, snipphthalate.context.VimContext(vim))
EOF


" Inserts the snippet for the given tag.
function snipphthalate#InsertSnippet(tag)
  let l:text = py3eval('_snipphthalate_render("' . a:tag . '")')
  if stridx(l:text, "\n") >= 0
    call append(line('.') - 1, split(l:text, '\n'))
  else
    let l:line = getline('.')
    let l:insert_at = col('.') - 1
    call setline(
        \ '.', l:line[: l:insert_at - 1] . l:text . l:line[l:insert_at :])
  endif
endfunction


" Returns a list suitable for customlist command completion.
function snipphthalate#CompleteTags(arg_lead, cmd_line, cursor_pos)
  let l:tags = py3eval('_snipphthalate_tags()')
  call filter(l:tags, {idx, val -> stridx(val, a:arg_lead) == 0})
  return l:tags
endfunction


let &cpo = s:save_cpo
