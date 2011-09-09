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

package "mktorrent"

#make the torrent
#mktorrent -a node://10.0.111.3:6881/ -o centos3.torrent CentOS-5.6-i386-bin-DVD.iso

#split out the dht_listen_port first entry.
#could be "123", "123-234", "123,456"
dht_port =

# create a torrent for using trackerless with DHT
bittorrent_create node['bittorrent']['torrent'] do
  path node['bittorrent']['file']
  tracker "node://#{node.ipaddress}:#{dht_port}"
  action :create
  #provider will check for existing file
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
  #provider will check for running torrent
end

#seed
#aria2c -V --summary-interval=0 --seed-ratio=0.0 --dht-file-path=/tmp/dht.dat --dht-listen-port 6881 --listen-port 6882 centos3.torrent
