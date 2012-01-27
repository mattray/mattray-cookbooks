#
# Author:: Matt Ray (<matt@opscode.com>)
# Cookbook Name:: bittorrent
# Recipe:: default
#
# Copyright 2012 Opscode, Inc.
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

#mktorrent
if platform?("redhat","centos")
  include_recipe "yum::epel"
  yum_repository "mktorrent" do
    name "mktorrent"
    #url "http://repos.fedorapeople.org/repos/peter/erlang/epel-5Server/#{node['kernel']['machine']}"
    action :add
  end
end
package "mktorrent"

#aria2
if node['bittorrent']['source']
  include_recipe "build-essential"

  #install packages for building
  ["libgnutls-dev", "libgcrypt-dev", "libc-ares-dev", "libxml2-dev"].each do |pkg|
    package pkg
  end

  #put the tarball in the build directory
  cookbook_file "#{Chef::Config[:file_cache_path]}/aria2-#{node['bittorrent']['aria2version']}.tar.bz2" do
    source "aria2-#{node['bittorrent']['aria2version']}.tar.bz2"
  end

  #build stuff
  bash "compile_aria2" do
    cwd Chef::Config[:file_cache_path]
    creates "/usr/local/bin/aria2c"
    code <<-EOH
      tar -xjf aria2-#{node['bittorrent']['aria2version']}.tar.bz2
      cd #{Chef::Config[:file_cache_path]}/aria2-#{node['bittorrent']['aria2version']}
      ./configure --without-libnettle --with-libgcrypt --quiet
      make install --quiet
    EOH
 end
else
  package "aria2"
end
