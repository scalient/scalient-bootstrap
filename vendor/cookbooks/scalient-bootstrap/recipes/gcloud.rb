# frozen_string_literal: true

# Copyright 2024 Roy Liu
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

require "shellwords"

class << self
  include Os::Bootstrap
  include Os::Bootstrap::Homebrew
end

recipe = self

homebrew_cask "google-cloud-sdk" do
  action :update
end

template "#{owner_dir}/.profile.d/0011_gcloud.sh".to_s do
  source "bash-0011_gcloud.sh.erb"
  owner recipe.owner
  group recipe.owner_group
  mode 0o644
  helper(:prefix) { recipe.homebrew_prefix }
  action :create
end
