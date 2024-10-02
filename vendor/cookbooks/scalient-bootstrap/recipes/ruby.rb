# frozen_string_literal: true

# Copyright 2014-2021 Roy Liu
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
  include Os::Bootstrap
  include Os::Bootstrap::Homebrew
end

include_recipe "os-bootstrap::homebrew"

recipe = self
prefix = Pathname.new(node["os-bootstrap"]["prefix"])
work_dir = Pathname.new(node["scalient-bootstrap"]["work_root"])
rubocop_yml_file = work_dir.join("scalient/playbook/coding_conventions/.rubocop.yml")

homebrew_cask "rubymine" do
  action :update
end

ruby_block "run RubyMine postinstall" do
  block do
    version_line_pattern = Regexp.new("\\A.*rubymine: (.*?\\..*?)(?:\\..*)?,.*\\z")

    major_minor_version = version_line_pattern.match(
      shell_out!(
        recipe.homebrew_executable.to_s, "info", "--cask", "--", "rubymine", user: recipe.owner
      ).stdout.split("\n", -1)[0]
    )[1]

    version_name = "RubyMine#{major_minor_version}"

    recipe.template prefix.join("bin/mine").to_s do
      source "ruby-mine.erb"
      owner recipe.owner
      group recipe.owner_group
      mode 0o755
      helper(:config_dir) { recipe.owner_dir.join("Library/Application Support/JetBrains", version_name) }
      helper(:cache_dir) { recipe.owner_dir.join("Library/Caches/JetBrains", version_name) }
      action :create
    end
  end

  action :run
end

if rubocop_yml_file.file?
  # Link the `.rubocop.yml` file from the Scalient Playbook into the user's home directory to serve as a default.
  link recipe.owner_dir.join(".rubocop.yml").to_s do
    to rubocop_yml_file.to_s
    owner recipe.owner
    group recipe.owner_group
    action :create
  end
end
