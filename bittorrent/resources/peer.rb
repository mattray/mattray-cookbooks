#
# Author:: Matt Ray (<matt@opscode.com>)
# Cookbook Name:: bittorrent
# Resource:: peer
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

actions :create, :stop

attribute :torrent, :kind_of => String, :name_attribute => true
attribute :path, :kind_of => String
attribute :blocking, :default => true
attribute :continue_seeding, :default => false
attribute :dht_entry_point, :kind_of => String
attribute :dht_listen_port, :kind_of => String, :default => "6881-6999"
attribute :listen_port, :kind_of => String, :default => "6881-6999"
attribute :upload_limit, :kind_of => Integer
