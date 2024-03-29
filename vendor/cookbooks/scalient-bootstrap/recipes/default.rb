# frozen_string_literal: true
#
# Copyright 2014-2016 Roy Liu
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

include_recipe "os-bootstrap"
include_recipe "os-bootstrap::editor"
include_recipe "os-bootstrap::gnupg2"
include_recipe "os-bootstrap::java"
include_recipe "os-bootstrap::ruby"
include_recipe "scalient-bootstrap::chef"
include_recipe "scalient-bootstrap::gcloud"
include_recipe "scalient-bootstrap::gnu_utils"
include_recipe "scalient-bootstrap::homebrew"
include_recipe "scalient-bootstrap::miscellaneous"
include_recipe "scalient-bootstrap::ruby"
include_recipe "scalient-bootstrap::ssh"
