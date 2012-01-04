#
# Author:: Matt Ray (<matt@opscode.com>)
# Cookbook Name:: bittorrent
# Recipe:: seed
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

bittorrent_torrent node['bittorrent']['torrent'] do
  path node['bittorrent']['path']
  file node['bittorrent']['file']
  tracker "node://#{node.ipaddress}:#{node['bittorrent']['port']}"
  action :create
end

bittorrent_seed node['bittorrent']['file'] do
  torrent node['bittorrent']['torrent']
  path node['bittorrent']['path']
  port node['bittorrent']['port']
  upload_limit node['bittorrent']['upload_limit']
  action :create
end

#stash the .torrent file in a data bag for distributing it
