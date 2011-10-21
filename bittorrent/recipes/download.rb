#
# Author:: Matt Ray (<matt@opscode.com>)
# Cookbook Name:: bittorrent
# Recipe:: download
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

#downl
bittorrent_seed node['bittorrent']['torrent'] do
  path node['bittorrent']['path']
  port node['bittorrent']['port']
  upload_limit node['bittorrent']['upload_limit']
  action :create
end

