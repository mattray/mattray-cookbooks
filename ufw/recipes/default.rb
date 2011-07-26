#
# Author:: Matt Ray <matt@opscode.com>
# Cookbook Name:: ufw
# Recipe:: default
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

#package "ufw"

#assume this works, if not, "ufw enable" 
# service "ufw" do
#   supports :restart => true, :status => true, :reload => true
#   action [ :enable ]
# end

#default is to turn everything off
#execute "ufw default deny"

node['firewall']['rules'].each do |rule_mash|
  Chef::Log.debug "ufw:rule \"#{rule_mash}\""
  rule_mash.keys.each do |rule|
    Chef::Log.debug "ufw:rule:name \"#{rule}\""
    params = rule_mash[rule]
    Chef::Log.debug "ufw:rule:parameters \"#{params}\""
    Chef::Log.debug "ufw:rule:name #{params['name']}" if params['name']
    Chef::Log.debug "ufw:rule:protocol #{params['protocol']}" if params['protocol']
    Chef::Log.debug "ufw:rule:port #{params['port']}" if params['port']
    Chef::Log.debug "ufw:rule:source #{params['source']}" if params['source']
    Chef::Log.debug "ufw:rule:destination #{params['destination']}" if params['destination']
    Chef::Log.debug "ufw:rule:action :#{params['action']}" if params['action']
    firewall_rule rule do
      name params['name'] if params['name']
      protocol params['protocol'] if params['protocol']
      port params['port'] if params['port']
      source params['source'] if params['source']
      destination params['destination'] if params['destination']
      action ":#{params['action']}" if params['action']
      notifies :enable, "firewall[ufw]"
    end
  end
end

firewall "ufw" do
  action :nothing
end
