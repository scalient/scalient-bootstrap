# -*- coding: utf-8 -*-
#
# Copyright 2014 Roy Liu
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

require "pathname"
require "shellwords"

class << self
  include OsX::Bootstrap
end

include_recipe "scalient-bootstrap::homebrew"

recipe = self
work_dir = Pathname.new(node["scalient-bootstrap"]["work_root"])
default_organization = node["scalient-bootstrap"]["chef"]["default_organization"]
multichef_config_dir = owner_dir + ".chef/multichef"

[multichef_config_dir.parent.to_s,
 multichef_config_dir.to_s,
 (multichef_config_dir + "configs").to_s].each do |dir|
  directory dir.to_s do
    owner recipe.owner
    group recipe.owner_group
    mode 0755
    action :create
  end
end

Pathname.glob("#{work_dir.to_s}/*/auth/config").each do |config_dir|
  link (multichef_config_dir + "configs" + config_dir.parent.parent.basename).to_s do
    to config_dir.to_s
    owner recipe.owner
    group recipe.owner_group
    action :create
  end
end

if default_organization
  file (multichef_config_dir + "config").to_s do
    content default_organization + "\n"
    user recipe.owner
    group recipe.owner_group
    mode 0644
    action :create
  end
end
