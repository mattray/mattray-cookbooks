#
# Author:: Matt Ray (<matt@opscode.com>)
# Cookbook Name:: bittorrent
# Recipe:: peer
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

package "aria2"

template node['bittorrent']['config_file'] do
  mode 0600
  source "aria2.conf.erb"
end

#use search to find the seed
seed = search()
entrypoint = seed.ipaddress:seed.bittorrent.dht_listen_port

#peer
bittorrent_peer node['bittorrent']['torrent'] do
  path node['bittorrent']['path']
  continue_seeding true
  dht_entry_point entrypoint
  dht_listen_port node['bittorrent']['dht_listen_port']
  listen_port node['bittorrent']['listen_port']
  action :create
end

#aria2c    --summary-interval=0 --seed-ratio=0.0 --dht-file-path=/tmp/dht.dat --dht-listen-port 6881 --listen-port 6882 --dht-entry-point=10.0.111.3:6881 centos3.torrent
