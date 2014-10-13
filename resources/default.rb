#
# Cookbook Name:: apps
# Resource:: default
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

actions :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :type, :kind_of => String, :default => "simple"
attribute :root, :kind_of => String, :default => nil
attribute :owner, :kind_of => String, :default => "root"
attribute :group, :kind_of => String, :default => "root"
attribute :environment, :kind_of => String, :default => "production"
attribute :bundler, :kind_of => String, :default => "--deployment --without development test"
attribute :onlywww, :kind_of => [TrueClass, FalseClass], :default => false
attribute :nowww, :kind_of => [TrueClass, FalseClass], :default => false
attribute :services, :kind_of => Array, :default => []

attribute :domains, :kind_of => Array, :default => [
  node["fqdn"]
]

attribute :index, :kind_of => Array, :default => [
  "index.html"
]

attribute :database, :kind_of => Hash, :default => {
  "name" => "",
  "username" => "",
  "password" => "",
  "type" => "mysql"
}

default_action :create
