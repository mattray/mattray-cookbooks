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
  source = "#{new_resource.path}/#{new_resource.file}"
  #check if the file exists, check if it has changed
  if ::File.exists?(torrent)
    #generate a new version
    test_torrent = "#{Chef::Config[:file_cache_path]}/#{::File.basename(torrent)}"
    shell_out("mktorrent -t 4 -d -c \"Generated with Chef\" -a #{new_resource.tracker} -o #{test_torrent} #{source}")
    existing_hash = checksum(torrent)
    Chef::Log.debug "Old hash: #{existing_hash}"
    test_hash = checksum(test_torrent)
    Chef::Log.debug "New hash: #{test_hash}"
    if existing_hash.eql?(test_hash)
      Chef::Log.info "Torrent #{torrent} validated and is unchanged."
      file test_torrent do
        backup false
        action :delete
      end
    else
      Chef::Log.info "Replacing existing torrent #{torrent} for #{source}."
      ruby_block "copying new torrent over existing" do
        block do
          ::FileUtils.copy(test_torrent,torrent)
        end
      end
      file test_torrent do
        backup false
        action :delete
      end
      new_resource.updated_by_last_action(true)
    end
  else
    Chef::Log.info "Creating new torrent #{torrent} for #{source}."
    execute "mktorrent -t 4 -d -c \"Generated with Chef\" -a #{new_resource.tracker} -o #{torrent} #{source}"
    new_resource.updated_by_last_action(true)
  end
  file torrent do
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
  end
end
