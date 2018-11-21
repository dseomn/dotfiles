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


" Adds multiple patterns to the given group.
function custommatches#AddPatterns(group, ...)
  if has_key(s:matches_configured, a:group)
    let s:matches_configured[a:group] += a:000
  else
    let s:matches_configured[a:group] = copy(a:000)
  endif
  call uniq(sort(s:matches_configured[a:group]))
endfunction


" Removes multiple patterns from the given group.
function custommatches#DelPatterns(group, ...)
  if !has_key(s:matches_configured, a:group)
    return
  endif
  for pattern in a:000
    call filter(s:matches_configured[a:group], 'v:val != ' . string(pattern))
  endfor
endfunction


" Deletes all matches in all windows added by this script, then re-adds all
" currently configured patterns.
function custommatches#ResetMatches()
  tabdo windo call s:DeleteMatches()
  tabdo windo call s:AddMatches()
endfunction


" Excludes the current buffer from all custom matches.
function custommatches#ExcludeBuffer()
  let b:custommatches_excluded = v:true
  call s:DeleteMatches()
endfunction


" End public interface.


" Adds all configured patterns to the current window.
function s:AddMatches()
  if exists('b:custommatches_excluded') | return | endif
  let winid = string(win_getid())
  if !has_key(s:matches_added, winid)
    let s:matches_added[winid] = []
  endif
  for [group, patterns] in items(s:matches_configured)
    for pattern in patterns
      let s:matches_added[winid] += [matchadd(group, pattern)]
    endfor
  endfor
endfunction


" Deletes all matches added by this script from the current window.
function s:DeleteMatches()
  let winid = string(win_getid())
  if !has_key(s:matches_added, winid)
    return
  endif
  for match_id in s:matches_added[winid]
    call matchdelete(match_id)
  endfor
  unlet s:matches_added[winid]
endfunction


" Enable all configured custom matches.
augroup custommatches
  au!

  " Add matches to all windows in all tabs when vim starts.
  au VimEnter * tabdo windo call s:AddMatches()

  " Add matches to any window created after vim starts.
  au WinNew * call s:AddMatches()

  " Reset matches when changing what buffer is in a window.
  au BufWinEnter,BufWinLeave * call s:DeleteMatches() | call s:AddMatches()
augroup END


" Map from match group to list of patterns.
let s:matches_configured = {}


" Map from window ID to list of matches we've added there.
let s:matches_added = {}
