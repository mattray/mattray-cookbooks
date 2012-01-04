#
# Author:: Matt Ray (<matt@opscode.com>)
# Cookbook Name:: bittorrent
# Recipe:: peer
#
# Copyright 2011,2012 Opscode, Inc.
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

#search on the node['bittorrent']['seeding'] and node['bittorrent']['file'] for seeding nodes
#iterate get the magnet URI and append some &tr= to the ends
#magnetURI

# bittorrent_peer magnetURI do
#   path node['bittorrent']['file']
#   path node['bittorrent']['path']
#   port node['bittorrent']['port']
#   blocking true
#   continue_seeding true
#   upload_limit node['bittorrent']['upload_limit']
#   action :create
# end

#search on the bittorrent::seed recipe for nodes
server = search(:node, 'recipes:bittorrent\:\:seed') || []
if server.length > 0
  seed = server[0].ipaddress
  Chef::Log.info("bittorrent::seed server found at #{seed}.")

  bittorrent_peer node['bittorrent']['torrent'] do
    path "/tmp/"
    seeder seed
    blocking true
    continue_seeding false
    action :create
  end

else
  Chef::Log.info("No bittorrent::seed server found, file not downloaded.")
end


