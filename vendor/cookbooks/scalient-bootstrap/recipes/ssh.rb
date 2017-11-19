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

require "openssl"
require "pathname"
require "shellwords"

class << self
  include Os::Bootstrap
end

include_recipe "os-bootstrap::ssh"

recipe = self
work_dir = Pathname.new(node["scalient-bootstrap"]["work_root"])

key_files = (Pathname.glob("#{owner_dir.to_s}/.ssh/id_{rsa,dsa,ecdsa}") +
    Pathname.glob("#{work_dir.to_s}/*/auth/keys/ssh/*.pem")).each do |key_file|
  begin
    run_context.resource_collection.find(file: key_file.to_s)

    resource_exists = true
  rescue Chef::Exceptions::ResourceNotFound
    resource_exists = false
  end

  file key_file.to_s do
    mode 0600
    action :create
  end if !resource_exists
end

directory "create `.profile.d` for #{recipe_full_name}" do
  path (recipe.owner_dir + ".profile.d").to_s
  owner recipe.owner
  group recipe.owner_group
  mode 0755
  action :create
end

# Install the Bash hook.
template (owner_dir + ".profile.d/0010_ssh_keys.sh").to_s do
  source "bash-0010_ssh_keys.sh.erb"
  owner recipe.owner
  group recipe.owner_group
  mode 0644
  helper(:key_files) { key_files }
  action :create
end
