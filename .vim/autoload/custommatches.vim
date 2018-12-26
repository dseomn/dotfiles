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


let s:save_cpo = &cpo
set cpo&vim


" Adds multiple patterns to the given group.
function custommatches#AddPatterns(group, ...)
  call call('custommatches#AddPatternsIf', [v:true, a:group] + a:000)
endfunction


" Like custommatches#AddPatterns, but the matches are only enabled in buffers
" where the condition funcref returns true.
function custommatches#AddPatternsIf(condition, group, ...)
  let l:pattern_configs = []
  for l:pattern in a:000
    call add(l:pattern_configs,
            \{'pattern': l:pattern, 'condition': a:condition})
  endfor

  if has_key(s:matches_configured, a:group)
    let s:matches_configured[a:group] += l:pattern_configs
  else
    let s:matches_configured[a:group] = l:pattern_configs
  endif
  call uniq(sort(s:matches_configured[a:group]))
endfunction


" Deletes all matches in all windows added by this script, then re-adds all
" currently configured patterns.
function custommatches#ResetMatches()
  tabdo windo call s:ResetMatchesLocal()
endfunction


" Excludes the current buffer from all custom matches.
function custommatches#ExcludeBuffer()
  let b:custommatches_excluded = v:true
  call s:DeleteMatchesLocal()
endfunction


" End public interface.


" Adds all configured patterns to the current window.
function s:AddMatchesLocal()
  if exists('b:custommatches_excluded') | return | endif
  let winid = string(win_getid())
  if !has_key(s:matches_added, winid)
    let s:matches_added[winid] = []
  endif
  for [l:group, l:pattern_configs] in items(s:matches_configured)
    for l:pattern_config in l:pattern_configs
      if l:pattern_config.condition is v:true || l:pattern_config.condition()
        call add(s:matches_added[winid],
                \matchadd(l:group, l:pattern_config.pattern))
      endif
    endfor
  endfor
endfunction


" Deletes all matches added by this script from the current window.
function s:DeleteMatchesLocal()
  let winid = string(win_getid())
  if !has_key(s:matches_added, winid)
    return
  endif
  for match_id in s:matches_added[winid]
    call matchdelete(match_id)
  endfor
  unlet s:matches_added[winid]
endfunction


function s:ResetMatchesLocal()
  call s:DeleteMatchesLocal()
  call s:AddMatchesLocal()
endfunction


" Enable all configured custom matches.
augroup custommatches
  au!

  " Add matches to all windows in all tabs when vim starts.
  au VimEnter * call custommatches#ResetMatches()

  " Add matches to any window created after vim starts.
  au WinNew * call s:ResetMatchesLocal()

  " Reset matches when changing what buffer is in a window.
  au BufWinEnter,BufWinLeave * call s:ResetMatchesLocal()

  " Reset matches when an option changes. This is useful for re-evaluating
  " match conditions that depend on options, e.g., &filetype or &expandtab.
  au OptionSet * call s:ResetMatchesLocal()
augroup END


" Map from match group to list of pattern configs. A pattern config is a dict
" with the pattern in .pattern, and a condition (or v:true) in .condition.
let s:matches_configured = {}


" Map from window ID to list of matches we've added there.
let s:matches_added = {}


let &cpo = s:save_cpo
