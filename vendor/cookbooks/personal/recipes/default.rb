# -*- coding: utf-8 -*-
#
# Copyright 2014 Clark Slater
# All rights reserved.

class << self
  include OsX::Bootstrap
end

recipe = self

template (owner_dir + ".profile.d/0010_clark.sh").to_s do
  source "0010_clark.sh.erb"
  owner recipe.owner
  group recipe.owner_group
  mode 0644
  action :nothing
end.action(:create)

