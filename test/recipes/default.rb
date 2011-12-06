#
# Cookbook Name:: test
# Recipe:: default
#
#

Chef::Log.info "TESTING!"

template "/tmp/testoutput.txt" do
  source "testfile.erb"
  mode "0644"
  variables(:vars => node['test']['yuck'])
  action :create
end

