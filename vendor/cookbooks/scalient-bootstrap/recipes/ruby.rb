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

require "etc"
require "pathname"

class << self
  include OsX::Bootstrap
end

include_recipe "osx-bootstrap::rbenv"

recipe = self
rbenv_root = Pathname.new(node["osx-bootstrap"]["prefix"]) + "var/rbenv"
versions = node["osx-bootstrap"]["rbenv"]["versions"]
global_version = node["osx-bootstrap"]["rbenv"]["global_version"]

versions = [versions] \
  if versions.is_a?(String)

versions = versions.map do |version|
  version = ENV["RBENV_VERSION"] \
    if version == "inherit"

  version
end

global_version = ENV["RBENV_VERSION"] \
  if global_version == "inherit"

versions = versions.push(global_version).uniq \
  if global_version

node["scalient-bootstrap"]["ruby"]["gems"].each do |gem|
  versions.each do |version|
    rbenv_gem gem do
      user recipe.owner
      root_path rbenv_root.to_s
      rbenv_version version
      action :install
    end
  end
end
