maintainer       "Opscode, Inc."
maintainer_email "matt@opscode.com"
license          "Apache 2.0"
description      "Manages use of BitTorrent for file distribution."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.0"
depends          "build-essential"
depends          "yum"

%w{ ubuntu rhel centos }.each do |os|
  supports os
end
