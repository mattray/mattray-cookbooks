#
# Author:: Matt Ray <matt@opscode.com>
# Cookbook Name:: ufw
# Recipe:: securitylevels
#
# Copyright 2011, Opscode, Inc
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

node.run_list.each do |entry|
  #pull the role or recipe name out
  id = entry[5..-2] if entry.start_with?("role[")
  id = entry[7..-2] if entry.start_with?("recipe[")
  item = data_bag_item('firewall', id)
  next if item.nil? #nothing found
  #add the list of firewall rules to the current list
  node['firewall']['rules'].concat(item[node['firewall']['securitylevel']])
end

#now go apply the rules
include_recipe "ufw::default"
