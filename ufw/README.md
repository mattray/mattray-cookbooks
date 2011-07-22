Description
===========
Configures Uncomplicated Firewall (ufw) on Ubuntu. Including the `ufw` recipe in a run list means the firewall will be enabled and will deny everything except SSH and ICMP ping by default.

Rules may be added to the node by adding them to the `['firewall']['rules']` attributes in roles or on the node directly. There is an LWRP that may be used to apply rules directly from other recipes as well. There is no need to explicitly remove rules, they are reevaluated on changes and reset. Rules are applied in the order of the run list, unless ordering is explictly added.

Requirements
============
Tested with Ubuntu 10.04 and 11.04.

Recipes
=======
default
-------
The `default` recipe looks for the list of firewall rules to apply from the `['firewall']['rules']` attribute added to roles and on the node itself. The list of rules is then applied to the node in the order specified.

securitylevels
--------------
The `securitylevels` recipe looks in the `firewall` data bag for different security levels to apply firewall rules. The list of rules to apply is found by looking at the run list for keys that map to the data bag and applied in the the order specified. The `securitylevels` recipe calls the `default` recipe after the `['firewall']['rules']` attribute is set to appy the rules.

Attributes
==========
Roles and the node may have the `['firewall']['rules']` attribute set. This attribute is a list of hashes, the key will be rule name, the value will be the hash of parameters. Application order is based on run list.

If you are using security levels, there will be a `['firewall']['securitylevel']` attribute used to key the 'firewall' data bag.

# Example Role
    name "fw_examples"
    description "Firewall rules for Examples"
    override_attributes(
      "firewall" => {
        "rules" => {
          "tftp" => {},
          "http" => {
            "port" => "80"
          },
          "block tomcat from 192.168.1.0/24" => {
            "port" => "8080",
            "source" => "192.168.1.0/24",
            "action" => "deny"
          },
          "Allow access to udp 1.2.3.4 port 5469 from 1.2.3.5 port 5469" => {
            "protocol" => "udp",
            "port" => "5469",
            "source" => "1.2.3.4",
            "destination" => "1.2.3.5",
            "dest_port" => "5469"
          }
        }
      }
      )


Data Bags
=========
If you are using security levels, the 'firewall' data bag will contain items that map to role names (eg. the 'apache' role will map to the 'apache' item in the 'firewall' data bag). Either roles or recipes may be keys (role[webserver] is 'webserver', recipe[apache2] is 'apache2' and recipe[apache2::mod_ssl] is 'apache2::mod_ssl'. Within the item, there will be a keys corresponding to security levels (ie. 'green', 'red', 'yellow'). These keys will contain hashes to apply to the  `['firewall']['rules']` attribute.

# Example 'firewall' data bag item

    {
        "id": "apache2",
        "green": {
            "http": {
                "port": "80"
            }
        },
        "red": {
            "http": {
                "port": "80"
            },
            "block http from 192.168.1.0/24": {
                "port" => "80",
                "source" => "192.168.1.0/24",
                "action" => "deny"
            }
        },
        "yellow": {
            "http": {
                "port": "81"
            }
        }
    }

Resources/Providers
===================
rule
----
# Actions
- :allow: adds the specified rule to the `['firewall']['rules']` list of the node. Default.
- :deny: adds the specified rule to the `['firewall']['rules']` list of the node as a DENY rule.
- :reject: adds the specified rule to the `['firewall']['rules']` list of the node as a REJECT rule.

# Attribute Parameters
- rule: name attribute. If only parameter, service name is assumed.
- port: port number to use. Optional.
- dest_port: destination port number to use. Optional.
- protocol: tcp or udp. Optional.
- direction: 'INPUT', 'OUTPUT' or 'FORWARD'. Optional, defaults to incoming traffic.
- source: ip address or subnet. (ie. '10.0.10.12' or '192.168.1.0/24'. Optional.
- dest: ip address or subnet. (ie. '10.0.10.12' or '192.168.1.0/24'. Optional.
- order: inserts the rule at a position. Optional, defaults to inserting at top of list so rules get inserted in run list ordering.
- interface: optional, defaults to all interfaces.

# Examples
    firewall_rule "tftp"

    firewall_rule "tomcat" do
       port "8080"
       action :allow
    end

    firewall_rule "block tomcat from 192.168.1.0/24" do
       port "8080"
       source "192.168.1.0/24"
       action :deny
    end

    firewall_rule "Allow access to udp 1.2.3.4 port 5469 from 1.2.3.5 port 5469" do
       protocol "udp"
       port "5469"
       source "1.2.3.4"
       destination "1.2.3.5"
       dest_port "5469"
       action :allow
    end

Limitations
=====
Logging and limiting are not yet supported. Logging will be added next.

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
