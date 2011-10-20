#
# Author:: Matt Ray (<matt@opscode.com>)
# Cookbook Name:: bittorrent
# Provider:: seed
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

# attribute :torrent, :kind_of => String, :name_attribute => true
# attribute :path, :kind_of => String
# attribute :port, :kind_of => Integer, :default => 6881
# attribute :upload_limit, :kind_of => Integer, :default => 0

require 'chef/shell_out'

#start seeding if not already doing so
action :create do
  torrentfile = new_resource.torrent
  torrent = ::File.basename(torrentfile)
  if running?
    Chef::Log.info "Torrent #{torrentfile} for #{new_resource.path} already seeding."
    new_resource.updated_by_last_action(false)
  else
    package("aria2") { action :nothing }.run_action(:install)
    command = "aria2c -D -V --seed-ratio=0.0 --log-level=notice "
    command += "-l /tmp/#{torrent}.log "
    command += "--dht-file-path=/tmp/#{torrent}-dht.dat "
    if new_resource.upload_limit
      #multiply by 1024^2 to do megabytes
      command += "--max-overall-upload-limit=#{new_resource.upload_limit * 1024*1024} "
    end
    command += "--dht-listen-port #{new_resource.port} "
    command += "--listen-port #{new_resource.port} "
    command += "-d#{new_resource.path} #{torrentfile}"
    torrentcleanup()
    execute command
    new_resource.updated_by_last_action(true)
  end
end

#kill the process if running and remove the dht file
action :stop do
  torrentfile = new_resource.torrent
  torrent = ::File.basename(torrentfile)
  if running?
    execute "pkill -f #{torrent}"
    new_resource.updated_by_last_action(true)
    Chef::Log.info "Torrent #{torrentfile} stopped."
  else
    Chef::Log.debug "Torrent #{torrentfile} is already stopped."
    new_resource.updated_by_last_action(false)
  end
  torrentcleanup()
end

#check if the torrent process is currently running
def running?
  torrent = ::File.basename(new_resource.torrent)
  cmd = Chef::ShellOut.new("pgrep -f #{torrent}")
  pgrep = cmd.run_command
  Chef::Log.debug "Output of 'pgrep -f #{torrent}' is #{pgrep.stdout}."
  if pgrep.stdout.length == 0
    return false
  else
    return true
  end
end

#remove any existing dht or log files
def torrentcleanup
  torrent = ::File.basename(new_resource.torrent)
  file "/tmp/#{torrent}.log" do
    backup false
    action :delete
  end
  file "/tmp/#{torrent}-dht.dat" do
    backup false
    action :delete
  end
end
