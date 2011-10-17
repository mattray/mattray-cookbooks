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

# actions :create, :stop

# attribute :torrent, :kind_of => String, :name_attribute => true
# attribute :path, :kind_of => String
# attribute :port, :kind_of => Integer, :default => 6881
# attribute :seeder, :kind_of => String
# attribute :blocking, :default => true
# attribute :continue_seeding, :default => false
# attribute :upload_limit, :kind_of => Integer

require 'chef/shell_out'

#start peering if not already doing so
action :create do
  torrentfile = new_resource.torrent
  torrent = ::File.basename(torrentfile)
  blocking = new_resource.blocking
  seeding = new_resource.continue_seeding

  package("aria2") { action :nothing }.run_action(:install)

  #construct the base aria2c command
  command = "aria2c -V --summary-interval=0 --log-level=notice "
  command += "-l /tmp/#{torrent}.log --dht-file-path=/tmp/#{torrent}-dht.dat "
  if new_resource.upload_limit
    #multiply by 1024^2 to do megabytes
    command += "--max-overall-upload-limit=#{new_resource.upload_limit * 1024*1024} "
  end
  command += "--dht-listen-port #{new_resource.port} --listen-port #{new_resource.port} "
  if new_resource.seeder
    command += "--dht-entry-point=#{new_resource.seeder}:#{new_resource.port} "
  end
  command += "-d#{new_resource.path} "

  #there are 3 states we have to account for: blocking, seeding and running.
  if blocking
    if seeding
      if running? #BYSYRY
        Chef::Log.info "Torrent #{torrentfile} already downloaded, already seeding #{new_resource.path}."
        new_resource.updated_by_last_action(false)
      else #BYSYRN
        #download in foreground
        fgcommand = command + "--seed-time=0 #{torrentfile}"
        execute fgcommand
        #seed in background
        bgcommand = command + "-D --seed-ratio=0.0 #{torrentfile}"
        execute bgcommand
        new_resource.updated_by_last_action(true)
      end #BYSN can't have Running
      #download in foreground
      fgcommand = command + "--seed-time=0 #{torrentfile}"
      execute fgcommand
      #!!!check the exit code to determine whether downloaded or not
      #new_resource.updated_by_last_action(true)
    end
  else
    if seeding
      if running? #BNSYRY
        Chef::Log.info "Torrent #{torrentfile} already seeding #{new_resource.path}."
        new_resource.updated_by_last_action(false)
      else #BNSYRN
        #seed in background
        bgcommand = command + "-D --seed-ratio=0.0 #{torrentfile}"
        execute bgcommand
        new_resource.updated_by_last_action(true)
      end
    else
      if running? #BNSNRY
        Chef::Log.info "Torrent #{torrentfile} already downloading #{new_resource.path}."
        new_resource.updated_by_last_action(false)
      else #BNSNRN
        #download in background
        bgcommand = command + "-D --seed-time=0 #{torrentfile}"
        execute bgcommand
        new_resource.updated_by_last_action(true)
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
    new_resource.updated_by_last_action(true)
    Chef::Log.info "Torrent #{torrentfile} stopped."
  else
    new_resource.updated_by_last_action(false)
    Chef::Log.debug "Torrent #{torrentfile} is already stopped."
  end
  file "/tmp/#{torrent}-dht.dat" do
    backup false
    action :delete
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

#aria2c -V --summary-interval=0 --seed-ratio=0.0 --dht-file-path=/tmp/dht.dat --dht-listen-port 6881 --listen-port 6881 --dht-entry-point=10.4.163.3:6881 test0.torrent

#scp -i ~/.ssh/mray.pem *torrent ubuntu@107.22.29.160:~/; scp -i ~/.ssh/mray.pem *torrent ubuntu@107.22.27.196:~/; scp -i ~/.ssh/mray.pem *torrent ubuntu@107.22.21.122:~/;

#test exit codes for already done
#aria2c -V --summary-interval=0 --seed-time=0 --dht-file-path=/tmp/dht.dat --dht-listen-port 6881 --listen-port 6881 --dht-entry-point=10.252.178.191:6881 test0.torrent

