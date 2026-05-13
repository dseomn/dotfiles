/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// General.
user_pref("apz.gtk.kinetic_scroll.enabled", false);
user_pref("apz.overscroll.enabled", false);
user_pref('general.warnOnAboutConfig', false);
user_pref('mail.uidensity', 0);
user_pref("ui.key.menuAccessKeyFocuses", false);

// Localization. Thunderbird doesn't appear to honor some things from the
// general locale system, so we override things here to match the locale.
// https://bugzilla.mozilla.org/show_bug.cgi?id=1426907
// https://searchfox.org/comm-central/source/mozilla/intl/locale/OSPreferences.cpp
// https://unicode.org/reports/tr35/tr35-dates.html#Date_Format_Patterns
// https://github.com/unicode-cldr/cldr-dates-modern/tree/master/main
user_pref('calendar.week.start', 0);
user_pref('intl.date_time.pattern_override.time_short', 'HH:mm');
user_pref('intl.date_time.pattern_override.time_medium', 'HH:mm:ss');
user_pref('intl.date_time.pattern_override.time_long', 'HH:mm:ss z');
user_pref('intl.date_time.pattern_override.time_full', 'HH:mm:ss zzzz');
user_pref('intl.date_time.pattern_override.date_short', 'yyyy-MM-dd');
user_pref('intl.date_time.pattern_override.date_medium', 'd MMM y');
user_pref('intl.date_time.pattern_override.date_long', 'd MMMM y');
user_pref('intl.date_time.pattern_override.date_full', 'EEEE d MMMM y');
user_pref('intl.date_time.pattern_override.connector_short', '{1} {0}');
user_pref('intl.locale.requested', '');

// Calendar.
user_pref('calendar.alarms.playsound', false);
user_pref('calendar.alarms.show', false);
user_pref('calendar.alarms.showmissed', false);
user_pref('calendar.integration.notify', false);
user_pref('calendar.view.dayendhour', 24);
user_pref('calendar.view.daystarthour', 0);
user_pref('calendar.view.visiblehours', 24);

// Mail and news.
user_pref('mail.biff.play_sound', false);
user_pref('mail.biff.show_alert', false);
user_pref('mail.collect_email_address_outgoing', false);
user_pref('mail.compose.big_attachments.notify', false);
user_pref('mail.display_glyph', false);  // Don't convert :) to emoji.
user_pref('mail.identity.default.archive_enabled', false);
user_pref('mail.identity.default.compose_html', false);
user_pref('mail.identity.default.sig_on_fwd', true);
// https://github.com/thunderbird/thunderbird-desktop/blob/762ee446617ca2b80655476bf1c6e56d4c0faa9d/suite/mailnews/content/mailWindowOverlay.js#L12-L14
user_pref('mail.pane_config.dynamic', 0);
user_pref('mail.phishing.detection.enabled', false);
user_pref('mail.server.default.check_all_folders_for_new', true);
user_pref('mail.server.default.login_at_startup', true);
// TODO(https://bugzilla.mozilla.org/show_bug.cgi?id=1798436): Switch to false.
user_pref('mail.server.default.using_subscription', true);
user_pref('mail.showCondensedAddresses', false);
// https://github.com/thunderbird/thunderbird-desktop/blob/762ee446617ca2b80655476bf1c6e56d4c0faa9d/mailnews/base/public/nsIMsgDBView.idl#L27
user_pref('mailnews.default_sort_order', 1);
// https://searchfox.org/comm-central/rev/59f3615b36c5ce10b1458e03aa5d68dae0e45d60/mailnews/base/public/nsIMsgDBView.idl#45
user_pref('mailnews.default_view_flags', 33);
user_pref('mailnews.start_page.enabled', false);
