Description
===========
Configures ddclient for connecting to DynDNS or other dynamic dns providers supported by ddclient. ddclient runs as a daemon.

Requirements
============
Tested with Ubuntu 10.04.

Recipes
=======
default
-------
The `default` recipe installs ddclient and fills out the `/etc/ddclient.conf` and `/etc/default/ddclient`.

Usage
=====
You will need to set the attributes for your DynDNS user, password and domain. Check the `attributes/default.rb` for other available attributes. Here is an example role:

    name "ddclient"
    description "ddclient"
    
    run_list [
      "recipe[ddclient]"
    ]
    
    override_attributes(
      "ddclient" => {
        "login" => "myuser",
        "password" => "mypassword,
        "fqdn" => "mydomain.dyndns-server.com"
      }
    )

License and Author
==================
Author:: Matt Ray (<matt@opscode.com>)

Copyright:: 2011 Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
