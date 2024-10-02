# frozen_string_literal: true

# Copyright 2014-2023 Roy Liu
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

include_recipe "os-bootstrap::homebrew"

node["scalient-bootstrap"]["homebrew"]["taps"].each do |tap|
  homebrew_tap tap do
    action :tap
  end
end

node["scalient-bootstrap"]["homebrew"]["formulas"].each do |formula|
  package formula do
    action :install
  end
end

node["scalient-bootstrap"]["homebrew"]["casks"].each do |cask|
  homebrew_cask cask do
    action :update
  end
end
