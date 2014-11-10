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
  include OsX::Bootstrap
end

recipe = self
work_dir = Pathname.new(node["scalient-bootstrap"]["work_root"])
stored_keys = Scalient::Bootstrap::Ssh.stored_keys(owner)

(Pathname.glob("#{owner_dir.to_s}/.ssh/id_{rsa,dsa}") \
 + Pathname.glob("#{work_dir.to_s}/*/auth/keys/*/*.{rsa,dsa}")).each do |key_file|
  public_key = OpenSSL::PKey.read(key_file.open("rb") { |f| f.read }).public_key

  case public_key
    when OpenSSL::PKey::RSA
      blob = [7].pack("N") + "ssh-rsa" \
        + public_key.e.to_s(0) \
        + public_key.n.to_s(0)
    when OpenSSL::PKey::DSA
      blob = [7].pack("N") + "ssh-dss" \
        + public_key.p.to_s(0) \
        + public_key.q.to_s(0) \
        + public_key.g.to_s(0) \
        + public_key.pub_key.to_s(0)
    else
      raise "Unsupported key type #{public_key.class.to_s.dump}"
  end

  fingerprint = OpenSSL::Digest::MD5.new(blob).to_s.scan(Regexp.new("[0-9a-f]{2}")).join(":")

  if !stored_keys.find { |key| key.fingerprint == fingerprint }
    file key_file.to_s do
      mode 0600
      action :nothing
    end.action(:create)

    bash "Add the private key file `#{key_file.to_s}` to the keychain" do
      code "ssh-agent -- ssh-add -K -- #{Shellwords.escape(key_file.to_s)}"
      user recipe.owner
      group recipe.owner_group

      # Kill any running SSH agent so that another one can start up and see the newly added key.
      notifies :run, "bash[`killall -- ssh-agent`]", :immediately

      action :run
    end
  end
end

bash "`killall -- ssh-agent`" do
  code "killall -u #{Shellwords.escape(recipe.owner)} -- ssh-agent"
  returns [0, 1]
  notifies :write, "log[shell restart notice]", :immediately
  action :nothing
end

log "shell restart notice" do
  message "A private key was added to your keychain, and any running SSH agents were killed. Please restart your" \
    " shell for the change to take effect."
  level :info
  action :nothing
end