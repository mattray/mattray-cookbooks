#
# Author:: Matt Ray <matt@opscode.com>
# Cookbook Name:: bittorrent
# Attributes:: default
#
# Copyright 2011,2012 Opscode, Inc
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

default[:bittorrent][:torrent] = "/tmp/chef.torrent"
default[:bittorrent][:file] = ""
default[:bittorrent][:path] = "/tmp"
default[:bittorrent][:seed] = false
default[:bittorrent][:port] = 6881
default[:bittorrent][:upload_limit] = 0 #0 is unlimited

#no good packages exist for aria2 for RHEL/CentOS
case node['platform']
when "ubuntu"
  default[:bittorrent][:source] = false
when "redhat","centos"
  default[:bittorrent][:source] = true
end

default[:bittorrent][:aria2version] = "1.14.1"
