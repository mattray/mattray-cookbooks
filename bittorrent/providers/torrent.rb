#
# Author:: Matt Ray (<matt@opscode.com>)
# Cookbook Name:: bittorrent
# Provider:: torrent
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

require 'chef/mixin/checksum'
require 'chef/mixin/shell_out'
include Chef::Mixin::Checksum
include Chef::Mixin::ShellOut


action :create do
  torrent = new_resource.torrent
  package("mktorrent") { action :nothing }.run_action(:install)
  #check if the file exists, check if it has changed 
  if ::File.exists?(torrent)
    #generate a new version
    test_torrent = "#{Chef::Config[:file_cache_path]}/#{::File.basename(torrent)}"
    shell_out("mktorrent -d -c \"Generated with Chef\" -a #{new_resource.tracker} -o #{test_torrent} #{new_resource.path}")
    existing_hash = checksum(torrent)
    Chef::Log.debug "Existing hash: #{existing_hash}"
    test_hash = checksum(test_torrent)
    Chef::Log.debug "Test hash: #{test_hash}"
    if existing_hash.eql?(test_hash)
      Chef::Log.debug "Torrent #{torrent} exists and unchanged."
      file test_torrent do
        action :delete
      end
    else
      Chef::Log.info "Replacing existing torrent #{torrent} from #{new_resource.path}."
      file torrent do
        action :delete
      end
      execute "mv #{test_torrent} #{torrent}"
      new_resource.updated_by_last_action(true)
    end
  else
    Chef::Log.info "Creating new torrent #{torrent} from #{new_resource.path}."
    execute "mktorrent -d -c \"Generated with Chef\" -a #{new_resource.tracker} -o #{torrent} #{new_resource.path}"
    new_resource.updated_by_last_action(true)
  end
  file torrent do
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
  end
end
