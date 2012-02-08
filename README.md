Description
===========
These cookbooks are not yet part of the Opscode repository for various reasons, so they are officially "unsupported".

Cookbooks
=========
annoyances
----------
This cookbook has moved to https://github.com/mattray/annoyances-cookbook.

bittorrent
----------
This cookbook has moved to https://github.com/mattray/bittorrent-cookbook.

chrony
------
Configures the time synchronization application `chrony` as a client or master timeserver, maintaining the accuracy of the system clock (similar to NTP). Isolated networks are supported as well.

dhcp
----
In development cookbook to configure and manage DHCP tables via data bags.

one-shot
--------
This cookbook provides a framework for making single-use, one-shot recipes. By including the `one-shot` recipe in the node's run_list, on the next chef-client run the contents of the `one-shot::one-shot` recipe will be called. This is parameterized as an attribute, so you can change these out by setting the `["one_shot"]["recipe"]` to include different recipes. The file `roles/one-shot.rb` is included so you can simply change the role instead of changing the source directly.

squid
-----
This cookbook has moved to https://github.com/mattray/squid-cookbook.

License and Author
==================
Author: Matt Ray <matt@opscode.com>

Copyright: 2011 Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
