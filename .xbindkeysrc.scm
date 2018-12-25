;; Copyright 2018 Google LLC
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     https://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.


;; Binds a key to a key sequence, using xdotool.
(define (xbindkey-keys key xdotool-keys)
  (let ((xdotool-key->xdotool-key-arg
          (lambda (key) (string-join (map symbol->string key) "+"))))
    (xbindkey
      key
      (string-join
        `("xdotool key --clearmodifiers"
          ,@(map xdotool-key->xdotool-key-arg xdotool-keys))))))


(xbindkey-keys '(release alt comma) '((XF86AudioPrev)))
(xbindkey-keys '(release alt period) '((XF86AudioNext)))
(xbindkey-keys '(release alt slash) '((XF86AudioPlay)))
(xbindkey-keys '(release alt shift comma) '((XF86AudioLowerVolume)))
(xbindkey-keys '(release alt shift period) '((XF86AudioRaiseVolume)))
(xbindkey-keys '(release alt shift slash) '((XF86AudioMute)))
