#
# Cookbook Name:: apps
# Provider:: default
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

require "chef/dsl/include_recipe"
include Chef::DSL::IncludeRecipe

action :create do
  include_recipe "nginx"
  include_recipe "users"

  directory new_resource.root do
    owner new_resource.owner
    group new_resource.group
    mode 0770
    recursive true

    action :create
  end

  case new_resource.type
  when "simple"
    include_recipe "php"

    php_app new_resource.owner do
      chdir new_resource.root
      user new_resource.owner
      group new_resource.group
    end

    nginx_app new_resource.name do
      cookbook "apps"
      template "simple.conf.erb"

      variables new_resource.to_hash

      action :create
    end
  when "rails"
    include_recipe "ruby"
    include_recipe "bundler"
    include_recipe "foreman"

    nginx_app new_resource.name do
      cookbook "apps"
      template "rails.conf.erb"

      variables new_resource.to_hash

      action :create
    end

    bundler_app new_resource.root do
      user new_resource.owner
      group new_resource.group
      params new_resource.bundler
      action [:install, :update]
    end

    # foreman_app new_resource.name do
    #   user new_resource.owner
    #   group new_resource.group
    #   root new_resource.root

    #   action :export
    # end

    #
    # rails app initialize
    # puma instead of unicorn
    # 

  end

  case new_resource.database["type"]
  when "mysql"
    include_recipe "mysql::credentials"
    include_recipe "mysql::client"
  
    mysql_app new_resource.database["name"] do
      username new_resource.database["username"]
      password new_resource.database["password"]

      connection node["mysql"]["credentials"]

      action :create
    end
  when "postgresql"
    include_recipe "postgresql::credentials"
    include_recipe "postgresql::client"
  
    postgresql_app new_resource.database["name"] do
      username new_resource.database["username"]
      password new_resource.database["password"]

      connection node["postgresql"]["credentials"]

      action :create
    end
  end

  include_recipe "memcached" if new_resource.services.include? "memcached"
  include_recipe "elasticsearch" if new_resource.services.include? "elasticsearch"
  include_recipe "redis" if new_resource.services.include? "redis"

  new_resource.updated_by_last_action(true)
end
