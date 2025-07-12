vim9script

# Copyright 2025 David Mandelberg
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# TODO(https://github.com/vim/vim/issues/16659): Delete this file.


au BufNewFile,BufRead *.conf.{j2,jinja,jinja2} setl ft=conf.jinja
au BufNewFile,BufRead *.ini.{j2,jinja,jinja2} setl ft=dosini.jinja
au BufNewFile,BufRead *.html.{j2,jinja,jinja2} setl ft=html.jinja
au BufNewFile,BufRead *.ninja.{j2,jinja,jinja2} setl ft=ninja.jinja
au BufNewFile,BufRead *.atom.{j2,jinja,jinja2} setl ft=xml.jinja
au BufNewFile,BufRead *.xml.{j2,jinja,jinja2} setl ft=xml.jinja
au BufNewFile,BufRead *.{yaml,yml}.{j2,jinja,jinja2} setl ft=yaml.jinja
