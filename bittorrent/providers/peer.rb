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

require 'chef/shell_out'
include Chef::Mixin::ShellOut

action :create do
  torrentfile = new_resource.torrent
  torrent = ::File.basename(torrentfile)
  blocking = new_resource.blocking
  seeding = new_resource.continue_seeding

  #construct the base aria2c command
  command = "aria2c -V --summary-interval=0 --log-level=notice -d#{new_resource.path}/#{new_resource.file} "
  command += "-l /tmp/#{torrent}.log --dht-file-path=/tmp/#{torrent}-dht.dat "
  command += "--dht-listen-port #{new_resource.port} --listen-port #{new_resource.port} "
  if new_resource.upload_limit
    #multiply by 1024^2 to do megabytes
    command += "--max-overall-upload-limit=#{new_resource.upload_limit * 1024*1024} "
  end
  if new_resource.seeder
    command += "--dht-entry-point=#{new_resource.seeder}:#{new_resource.port} "
  end

  #there are 3 states we have to account for: blocking, seeding and running.
  if blocking
    if seeding
      if running? #BYSYRY
        Chef::Log.info "Torrent #{torrentfile} already downloaded and seeding."
      else #BYSYRN
        torrentcleanup()
        #download in foreground
        Chef::Log.info "Torrent #{torrentfile} downloaded and seeding."
        fgcommand = command + "--seed-time=0 #{torrentfile}"
        execute fgcommand
        #seed in background
        bgcommand = command + "-D --seed-ratio=0.0 #{torrentfile}"
        execute bgcommand
        new_resource.updated_by_last_action(true)
      end
    else #BYSN can't have Running
      torrentcleanup()
      #download in foreground
      fgcommand = command + "--seed-time=0 #{torrentfile}"
      #!!!check the exit code to determine whether downloaded or not
      Chef::Log.info fgcommand
      download = Chef::ShellOut.new(fgcommand)
      download.live_stream = STDOUT
      download.run_command
      #Chef::Log.info download.stdout
      if download.stdout.include?("downloaded=0B")
        Chef::Log.info "Torrent #{torrentfile} already downloaded."
      else
        Chef::Log.info "Torrent #{torrentfile} downloaded."
        new_resource.updated_by_last_action(true)
      end
    end
  else
    if seeding
      if running? #BNSYRY
        Chef::Log.info "Torrent #{torrentfile} already seeding."
      else #BNSYRN
        torrentcleanup()
        #seed in background
        Chef::Log.info "Torrent #{torrentfile} seeding."
        bgcommand = command + "-D --seed-ratio=0.0 #{torrentfile}"
        execute bgcommand
        new_resource.updated_by_last_action(true)
      end
    else
      if running? #BNSNRY
        Chef::Log.info "Torrent #{torrentfile} already downloading."
      else #BNSNRN
        torrentcleanup()
        #download in background, no updated_by_last_action
        Chef::Log.info "Torrent #{torrentfile} downloading."
        bgcommand = command + "-D --seed-time=0 #{torrentfile}"
        execute bgcommand
      end
    end
  end
end

#kill the process if running and remove the dht file
action :stop do
  torrentfile = new_resource.torrent
  torrent = ::File.basename(torrentfile)
  if running?
    execute "pkill -f #{torrent}"
    torrentcleanup()
    new_resource.updated_by_last_action(true)
    Chef::Log.info "Torrent #{torrentfile} stopped."
  else
    Chef::Log.debug "Torrent #{torrentfile} is already stopped."
  end
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
