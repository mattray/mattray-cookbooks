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

# actions :create, :stop

# attribute :file, :kind_of => String, :name_attribute => true
# attribute :path, :kind_of => String
# attribute :torrent, :kind_of => String
# attribute :port, :kind_of => Integer, :default => 6881
# attribute :upload_limit, :kind_of => Integer

require 'chef/shell_out'
#require 'base32'
#require 'rubytorrent'

#start seeding if not already doing so
action :create do
  file = new_resource.file
  path = new_resource.path
  #are we going to use a torrent file or create a magnet URI?
  if new_resource.torrent
    torrent = new_resource.torrent
  else
    gem_package("rubytorrent") { action :nothing }.run_action(:install)
    #make a magnetURI and set the torrent to that
    #make sure this isn't expecting to read from a torrent file, if so generate
    #info = RubyTorrent::MetaInfo.from_location(path).info
    #torrent = 'magnet:?xt=urn:btih:' + Base32.encode(info.sha1)
    #what sort of location do we need to add to this?
  end
  if running?(file)
    Chef::Log.info "Torrent #{torrent} for #{path}/#{file} already seeding."
    new_resource.updated_by_last_action(false)
  else
    command = "aria2c -D -V --seed-ratio=0.0 --log-level=notice "
    command += "-l /tmp/#{file}-torrent.log "
    command += "--dht-file-path=/tmp/#{file}-torrent-dht.dat "
    if new_resource.upload_limit
      #multiply by 1024^2 to do megabytes
      command += "--max-overall-upload-limit=#{new_resource.upload_limit * 1024*1024} "
    end
    command += "--dht-listen-port #{new_resource.port} "
    command += "--listen-port #{new_resource.port} "
    command += "-d#{path} #{torrent}"
    torrentcleanup(file)
    execute command
    new_resource.updated_by_last_action(true)
  end
end

#kill the process if running and remove the dht file
action :stop do
  file = new_resource.file
  if running?(file)
    execute "pkill -f #{file}"
    new_resource.updated_by_last_action(true)
    Chef::Log.info "Torrent #{file} stopped."
  else
    Chef::Log.debug "Torrent #{file} is already stopped."
    new_resource.updated_by_last_action(false)
  end
  torrentcleanup(file)
end

# check if the torrent process for the file is currently running
def running?(file)
  cmd = Chef::ShellOut.new("pgrep -f #{file}")
  pgrep = cmd.run_command
  Chef::Log.debug "Output of 'pgrep -f #{file}' is #{pgrep.stdout}."
  if pgrep.stdout.length == 0
    return false
  else
    return true
  end
end

# remove any existing dht or log files
def torrentcleanup(file)
  file "/tmp/#{file}-torrent.log" do
    backup false
    action :delete
  end
  file "/tmp/#{file}-torrent-dht.dat" do
    backup false
    action :delete
  end
end
