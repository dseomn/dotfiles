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
user_pref('general.warnOnAboutConfig', false);

// Calendar.
user_pref('calendar.alarms.playsound', false);
user_pref('calendar.alarms.show', false);
user_pref('calendar.alarms.showmissed', false);
user_pref('calendar.integration.notify', false);
user_pref('calendar.view.dayendhour', 24);
user_pref('calendar.view.daystarthour', 0);
user_pref('calendar.view.visiblehours', 24);

// Calendar accounts.
user_pref('calendar.registry.13946703-f1ef-473a-84fb-fe13311f277b.name', 'US Holidays');
user_pref('calendar.registry.13946703-f1ef-473a-84fb-fe13311f277b.uri', 'https://www.mozilla.org/media/caldata/USHolidays.ics');
user_pref('calendar.registry.13946703-f1ef-473a-84fb-fe13311f277b.type', 'ics');
user_pref('calendar.registry.13946703-f1ef-473a-84fb-fe13311f277b.readOnly', true);
user_pref('calendar.registry.13946703-f1ef-473a-84fb-fe13311f277b.color', '#e78074');
user_pref('calendar.registry.13946703-f1ef-473a-84fb-fe13311f277b.cache.enabled', true);
user_pref('calendar.registry.13946703-f1ef-473a-84fb-fe13311f277b.calendar-main-in-composite', true);
user_pref('calendar.registry.13946703-f1ef-473a-84fb-fe13311f277b.disabled', false);
user_pref('calendar.registry.13946703-f1ef-473a-84fb-fe13311f277b.refreshInterval', 60);

// CardBook.
user_pref('extensions.cardbook.autocompleteSortByPopularity', false);
user_pref('extensions.cardbook.autocompleteWithColor', false);
user_pref('extensions.cardbook.technicalTabView', true);
user_pref('extensions.cardbook.vcardTabView', true);

// Mail and news.
user_pref('mail.biff.play_sound', false);
user_pref('mail.biff.show_alert', false);
user_pref('mail.collect_email_address_outgoing', false);
user_pref('mail.compose.big_attachments.notify', false);
user_pref('mail.display_glyph', false);  // Don't convert :) to emoji.
user_pref('mail.identity.default.archive_enabled', false);
user_pref('mail.identity.default.compose_html', false);
user_pref('mail.identity.default.sig_on_fwd', true);
user_pref('mail.server.default.check_all_folders_for_new', true);
user_pref('mail.server.default.login_at_startup', true);
user_pref('mail.showCondensedAddresses', false);
// https://dxr.mozilla.org/comm-central/rev/2a29ee0adb310b54a6a2df72034953fed8f2b043/comm/mailnews/base/public/nsIMsgDBView.idl#45
user_pref('mailnews.default_view_flags', 33);
