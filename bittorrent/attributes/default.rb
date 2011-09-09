#
# Author:: Matt Ray <matt@opscode.com>
# Cookbook Name:: bittorrent
# Attributes:: default
#
# Copyright 2011 Opscode, Inc
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

default[:bittorrent][:seed] = false

default[:bittorrent][:file] = ""
default[:bittorrent][:path] = "/tmp"
default[:bittorrent][:torrent] = "/tmp/my.torrent"

default[:bittorrent][:config_file] = "/etc/aria2.conf"
default[:bittorrent][:logfile] = "/var/log/bittorrent.log"

default[:bittorrent][:dht_listen_port] = "6881-6890"
default[:bittorrent][:listen_port] = "6881-6890"
default[:bittorrent][:upload_limit] = 0 #0 is unlimited
