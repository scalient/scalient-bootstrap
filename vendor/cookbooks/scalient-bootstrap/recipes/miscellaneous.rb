# -*- coding: utf-8 -*-
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

include_recipe "os-bootstrap::preferences"

prefs = node["scalient-bootstrap"]["miscellaneous"]

service "com.apple.locate" do
  # Enable the `locate.updatedb` service for building the `locate` database.
  action :enable
end

service "com.apple.rcd" do
  # Don't start iTunes when the user presses the "Play" media key.
  action :disable
end

plist_file "com.apple.LaunchServices" do
  # Don't warn about applications freshly downloaded from the internet.
  set "LSQuarantine", prefs["launch_services"]["ls_quarantine"]

  format :binary

  # We need to restart `Finder` for the changes to take effect.
  notifies :run, "execute[`killall -- Finder`]", :immediately

  action :create
end

plist_file "com.apple.desktopservices" do
  # Don't write `.DS_Store` files to network volumes.
  set "DSDontWriteNetworkStores", "true"

  # We need to restart `Finder` for the changes to take effect.
  notifies :run, "execute[`killall -- Finder`]", :immediately

  action :create
end
