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

include_recipe "bittorrent"

#should there be a flag for already downloaded? maybe store md5 in data bag?

#pull the .torrent file from the data bag
torrent = data_bag_item('bittorrent', bittorrent_item_id(node['bittorrent']['file']))
if torrent
  #write out the .torrent file and base64 decode
  #should this use the File resource, does it handle binary?
  nf = File.open(node['bittorrent']['torrent'], 'wb')
  nf.write(Base64.decode64(torrent['torrent']))

  bittorrent_peer node['bittorrent']['torrent'] do
    path node['bittorrent']['path']
    seeder torrent['seed']
    blocking true
    continue_seeding node[:bittorrent][:seed]
    action :create
  end
else
  Chef::Log.info("No torrent for #{node['bittorrent']['file']} found in data bag, file not downloaded.")
end
