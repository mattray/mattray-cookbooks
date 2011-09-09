#
# Author:: Matt Ray (<matt@opscode.com>)
# Cookbook Name:: bittorrent
# Provider:: peer
#
# Copyright:: 2011, Opscode, Inc <legal@opscode.com>
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

# centos5: removed trailing '/', try not using --dht-start WORKS!
# aria2c --summary-interval=0 --seed-ratio=0.0 --dht-file-path=/tmp/dht.dat --dht-listen-port 6881 --listen-port 6882 centos5.torrent

# test -d option
# aria2c -V --summary-interval=0 --seed-ratio=0.0 --dht-file-path=/tmp/dht.dat --dht-listen-port 6881 --listen-port 6882 -d/home/mray fnm1.torrent
# aria2c --summary-interval=0 --seed-ratio=0.0 --dht-file-path=/tmp/dht.dat --dht-listen-port 6881 --listen-port 6882 -d/home/mray fnm1.torrent
# aria2c -V --summary-interval=0 --seed-ratio=0.0 --dht-file-path=/tmp/dht.dat --dht-listen-port 6881 --listen-port 6882 -d/home/mray fnm1.torrent
# WORKS!


# actions :create, :stop

# attribute :torrent, :kind_of => String, :name_attribute => true
# attribute :path, :kind_of => String
# attribute :blocking, :default => true
# attribute :continue_seeding, :default => false
# attribute :dht_listen_port, :kind_of => String, :default => "6881-6999"
# attribute :listen_port, :kind_of => String, :default => "6881-6999"
# attribute :upload_limit, :kind_of => Integer

# if blocking
# bittorrent_peer node['bittorrent']['torrent'] do
#   path node['bittorrent']['path']
#   dht_listen_port node['bittorrent']['dht_listen_port']
#   listen_port node['bittorrent']['listen_port']
#   action :create
# end

# if continue_seeding
# bittorrent_seed
# else



# file -> only works on single file 
#(check for Mode: multi in output of aria2c --show-files blahblah.torrent
# read the filename
# owner, group, mode


#aria2c    --summary-interval=0 --seed-ratio=0.0 --dht-file-path=/tmp/dht.dat --dht-listen-port 6881 --listen-port 6882 --dht-entry-point=10.0.111.3:6881 centos3.torrent
