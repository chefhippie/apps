#
# Cookbook Name:: apps
# Recipe:: default
#
# Copyright 2013, Thomas Boerger
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "nginx"
include_recipe "php"
include_recipe "ruby"
include_recipe "users"

apps = if Chef::Config[:solo] and not node.recipes.include?("chef-solo-search")
  node["apps"]["apps"]
else
  search(
    node["apps"]["data_bag"],
    "available:#{node["fqdn"]} OR available:default"
  )
end

apps.each do |app|
  include_recipe "memcached" if app["services"].include? "memcached"
  include_recipe "elasticsearch" if app["services"].include? "elasticsearch"
  include_recipe "redis" if app["services"].include? "redis"

  directory app["root"] do
    owner app["owner"]
    group app["group"]
    mode 0770
    recursive true

    action :create
  end

  case app["type"]
  when "simple"
    php_app app["owner"] do
      chdir app["root"]
      user app["owner"]
      group app["group"]
    end

    nginx_app app["id"] do
      cookbook "apps"
      template "simple.conf.erb"

      variables app.to_hash

      action :create
    end
  end

  case app["database"]["type"]
  when "mysql"
    include_recipe "mysql"
  
    mysql_app app["database"]["name"] do
      username app["database"]["username"]
      password app["database"]["password"]

      action :create
    end
  when "postgresql"
    include_recipe "postgresql"
  
    postgresql_app app["database"]["name"] do
      username app["database"]["username"]
      password app["database"]["password"]

      action :create
    end
  when "mongodb"
    include_recipe "mongodb"

    mongodb_app app["database"]["name"] do
      username app["database"]["username"]
      password app["database"]["password"]

      action :create
    end
  end
end
