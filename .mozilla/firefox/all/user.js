// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


user_pref("browser.aboutConfig.showWarning", false);

user_pref("browser.download.always_ask_before_handling_new_types", true);
// https://bugzilla.mozilla.org/show_bug.cgi?id=1738574#c133
user_pref("browser.download.start_downloads_in_tmp_dir", true);
user_pref("browser.download.useDownloadDir", false);

user_pref("browser.formfill.enable", false);

user_pref("browser.newtabpage.enabled", false);

user_pref("browser.search.suggest.enabled", false);

user_pref("browser.startup.homepage", "about:blank");

user_pref("browser.tabs.crashReporting.sendReport", false);

user_pref("browser.urlbar.quicksuggest.enabled", false);

user_pref("dom.security.https_only_mode", true);

user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.creditCards.enabled", false);

user_pref("intl.regional_prefs.use_os_locales", true);

// https://kb.mozillazine.org/Keyword.enabled
user_pref("keyword.enabled", false);

user_pref("media.hardwaremediakeys.enabled", false);

// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_prefetching
user_pref("network.http.speculative-parallel-limit", 0);

user_pref("signon.rememberSignons", false);

// Prevent tapping Alt from showing the hidden menu bar.
user_pref("ui.key.menuAccessKeyFocuses", false);
