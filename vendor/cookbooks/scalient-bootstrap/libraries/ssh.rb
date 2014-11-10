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

require "chef/shell_out"

module Scalient
  module Bootstrap
    module Ssh
      class << self
        include Chef::Mixin::ShellOut
      end

      KEY_PATTERN = Regexp.new("\\A([1-9][0-9]*) ((?:[0-9a-f]{2}:){15}[0-9a-f]{2}) (.*) \\((?:RSA|DSA)\\)\\z")
      Key = Struct.new(:length, :fingerprint, :file)

      # Lists the SSH agent's stored keys.
      def self.stored_keys(user = nil)
        cmd = shell_out("ssh-agent", "--", "ssh-add", "-l", user: user)

        if !cmd.error?
          cmd.stdout.chomp("\n").split("\n", -1).map do |line|
            m = KEY_PATTERN.match(line)

            raise "Invalid line #{line.dump}" \
              if !m

            Key.new(m[1].to_i, m[2], Pathname.new(m[3]))
          end
        else
          cmd.error! \
            if cmd.stdout != "The agent has no identities.\n"

          []
        end
      end
    end
  end
end
