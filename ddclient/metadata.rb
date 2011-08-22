maintainer       "Matt Ray"
maintainer_email "matt@opscode.com"
license          "Apache 2.0"
description      "Installs/Configures ddclient"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1"

%w{ ubuntu }.each do |os|
  supports os
end
