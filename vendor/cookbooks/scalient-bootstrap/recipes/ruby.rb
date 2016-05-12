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
include_recipe "osx-bootstrap::homebrew"
include_recipe "osx-bootstrap::java"

recipe = self
prefix = Pathname.new(node["osx-bootstrap"]["prefix"])
rbenv_root = prefix + "var/rbenv"
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

homebrew_cask "rubymine" do
  notifies :run, "ruby_block[run RubyMine postinstall]", :immediately
  action :update
end

ruby_block "run RubyMine postinstall" do
  block do
    app_install_dir = Pathname.new(
        shell_out!(
            (prefix + "bin/brew").to_s, "cask", "info", "--", "rubymine"
        ).stdout.split("\n", -1)[3].split(" ", -1)[0]
    ) + "RubyMine.app"

    version_name = "RubyMine#{app_install_dir.parent.basename.to_s}"

    recipe.template (prefix + "bin/mine").to_s do
      source "ruby-mine.erb"
      owner recipe.owner
      group recipe.owner_group
      mode 0755
      helper(:app_install_dir) { app_install_dir }
      helper(:config_dir) { recipe.owner_dir + "Library/Preferences" + version_name }
      helper(:cache_dir) { recipe.owner_dir + "Library/Caches" + version_name }
      action :create
    end
  end

  action :nothing
end
