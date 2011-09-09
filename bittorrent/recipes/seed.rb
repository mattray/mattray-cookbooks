#
# Author:: Matt Ray (<matt@opscode.com>)
# Cookbook Name:: bittorrent
# Recipe:: seed
#
# Copyright 2011, Opscode, Inc.
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

#split out the dht_listen_port first entry.
#could be "123", "123-234", "123,456"
dht_port = node['bittorrent']['dht_listen_port']

# create a torrent for using trackerless with DHT
bittorrent_torrent node['bittorrent']['torrent'] do
  path node['bittorrent']['file']
  tracker "node://#{node.ipaddress}:#{dht_port}"
  action :create
end

package "aria2"

template node['bittorrent']['config_file'] do
  mode 0600
  source "aria2.conf.erb"
end

#seed
bittorrent_seed node['bittorrent']['torrent'] do
  path node['bittorrent']['path']
  dht_listen_port node['bittorrent']['dht_listen_port']
  listen_port node['bittorrent']['listen_port']
  action :create
end

