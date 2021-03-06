#
# Cookbook Name:: apps
# Recipe:: default
#
# Copyright 2013-2014, Thomas Boerger <thomas@webhippie.de>
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

entries = if Chef::Config[:solo] and not node.recipes.include?("chef-solo-search")
  node["apps"]["apps"]
else
  search(
    node["apps"]["data_bag"],
    "available:#{node["fqdn"]} OR available:default"
  )
end

entries.each do |app|
  apps app["id"] do
    type app["type"] || "simple"

    root app["root"]
    owner app["owner"]
    group app["group"]
    database app["database"]

    domains app["domains"] || [node["fqdn"]]
    index app["index"] || ["index.html"]
    services app["services"] || []

    onlywww app["onlywww"] || false
    nowww app["nowww"] || false

    action :create
  end
end
