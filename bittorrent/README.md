Description
===========
Manages the use of [BitTorrent](http://en.wikipedia.org/wiki/BitTorrent) for distributing files with the [Aria2 BitTorrent Client](http://aria2.sourceforge.net). It includes LWRPs for downloading files, creating torrents and for seeding files. There are also recipes that use attributes to share and download files via bittorrent with minimal interaction.

Requirements
============
Platform
--------
Tested with Ubuntu 10.04, Ubuntu 11.04 and CentOS 5.3. Uses the `aria2` and `mktorrent` packages. RHEL packages are unavailable for `aria2`, so they are built from source.

Networking
----------
For torrentless trackers you must have both TCP and UDP open on the firewall for whatever port you may be using. For simplicity and efficiency only a single port is supported (DHT uses UDP and transfers use TCP). EC2 instances can communicate between each other as long as they are in the same security group.

Resource/Provider
=================
To have access to the LWRPs without using the recipes, you must include the `bittorrent` recipe, which installs the `mktorrent` and `aria2` packages (and builds them if necessary).

bittorrent_peer
---------------
Download the file or files specified by a torrent via the [BitTorrent protocol](http://en.wikipedia.org/wiki/BitTorrent). Update notifications are triggered when a blocking download completes and on the initiation of seeding.

# Actions
- :create: Download the contents of a torrent via the BitTorrent protocol
- :stop: Stop a download (usually used to end seeding).

# Attribute Parameters
- torrent: torrent file of the swarm to join.  Can either be a url or local file path. Name attribute.
- file: file to download.
- path: directory for the downloaded file.
- port: listening port for peers. (default 6881)
- blocking: should the file be downloaded in a blocking way? If `true` Chef will download the file in a single Chef run, if `false` will start the download and continue in the background (and based on `continue_seeding` stop or continue when finished). (default true)
- seeder: hostname or address of the seeder if the torrent does not have a tracker. (optional)
- continue_seeding: should the file continue to be seeded to the swarm after download? You will need to use the :stop action to stop it. (default false)
- upload_limit: maximum upload speed limit in megabytes/sec. (optional)

# Examples
    # download the lucid iso
    bittorrent_peer "http://releases.ubuntu.com/lucid/ubuntu-10.04.3-server-i386.iso.torrent" do
      file "ubuntu-10.04.3-server-i386.iso"
      path "/home/ubuntu/"
      action :create
    end

    # continue seeding with a local torrent after download
    bittorrent_peer "/tmp/bigfile.torrent" do
      file "bigfile.tar.gz"
      path "/home/ubuntu/"
      continue_seeding true
      action :create
    end

    # stop the previous torrent
    bittorrent_peer "bigfile.tar.gz do
      action :stop
    end

bittorrent_seed
---------------
Share a local file via the [BitTorrent protocol](http://en.wikipedia.org/wiki/BitTorrent).

# Actions
- :create: Seed a local file and share it via BitTorrent.
- :stop: Stop a download (used to end seeding).

# Attribute Parameters
- file: source file to share. Name attribute.
- path: path to the source file.
- torrent: torrent file to seed. Can either be a url or local file path. (optional)
- port: listening port for peers. (default 6881)
- upload_limit: maximum upload speed limit in megabytes/sec. (optional)

# Examples
    # share an ubuntu iso via a torrent
    bittorrent_seed "ubuntu.iso" do
      path "/home/ubuntu/"
      torrent "/home/ubuntu/ubuntu.iso.torrent"
      action :create
    end

    # seed without a torrent with a megabyte limit
    bittorrent_seed "bigpackage.zip" do
      path "/tmp"
      upload_limit 1
      action :create
    end

    # stop the previous torrent
    bittorrent_seed "bigpackage.zip" do
      action :stop
    end

bittorrent_torrent
------------------
Creates a .torrent file for sharing a local file via the [BitTorrent protocol](http://en.wikipedia.org/wiki/BitTorrent). You can use the `bittorrent_seed` LWRP to share the .torrent after it is created.

# Actions
- :create: Generate a .torrent for sharing a local file via the BitTorrent protocol.

# Attribute Parameters
- torrent: torrent file to generate. Local file path. Name attribute.
- file: source file.
- path: directory of the source file.
- tracker: tracker or trackers to list. (optional)
- owner: owner of the generated .torrent file. (optional)
- group: group of the generated .torrent file. (optional)
- mode: mode of the generated .torrent file. (optional)

# Example
    # create a torrent for the the lucid iso
    bittorrent_torrent "/home/ubuntu/ubuntu.iso.torrent" do
      file "ubuntu.iso"
      path "/home/ubuntu"
      tracker "http://mytracker.example.com:6969/announce"
      action :create
    end

    # create a torrent for using trackerless with DHT
    bittorrent_torrent "/tmp/bigpackage.torrent" do
      file "bigpackage.zip"
      path "/tmp/"
      tracker "node://#{node.ipaddress}:#{node['bittorrent']['port']}"
      action :create
    end

Recipes
=======
These recipes are provided as an easy way to use bittorrent to share and download files simply by passing the path and filename. They currently require the presence of a `bittorrent` data bag for automating the distribution of torrent files (the plan is to move to magnet URIs in the future). The default recipe is necessary if you are only using the LWRPs, it is included by all the other recipes since it installs the required packages.

```
knife data bag create bittorrent
```

default
-------
This recipe installs the `mktorrent` and `aria2` packages. If the `['bittorrent']['source']` attribute is set to "true" it will build `aria2` from source (the default for RHEL/CentOS and recommended for Ubuntu 10.04 because of the bugs fixed in the newer releases). This recipe is included by all the other recipes and only needs to be explicitly included if you are only using the LWRPs.

seed
----
Given the filename and path via `['bittorrent']['file']` and `['bittorrent']['path']`, the file will be seeded via bittorrent (you may optionally set the `['bittorrent']['torrent']` file name). A torrent file is created and stored in the `bittorrent` data bag with the ip address of the seeding node for use by downloading peers.

peer
----
Given the filename and path via `['bittorrent']['file']` and `['bittorrent']['path']`, the file will be downloaded and seeded via bittorrent (you may optionally set the `['bittorrent']['torrent']` file name). The torrent file is pulled from the `bittorrent` data bag, written to the filesystem and the file is downloaded. If you wish to speed up the distribution of your files by continuing to seed after downloading, set the `[:bittorrent][:seed]` to true.

stop
----
Stops the seeding and peering of the the `['bittorrent']['file']` file.

Roles
=====
There are a pair of roles in the `examples` directory called `btpeer.rb` and `btseeder.rb`. Thsese examples show how to automate the seeding and peering of a "crm84.tar.gz" file with just the attributes and included recipes.

Attributes
==========
* `['bittorrent']['torrent]` - Filename of the .torrent file for sharing, defaults to "/tmp/chef.torrent"
* `['bittorrent']['file']` - File to download or share via bittorrent
* `['bittorrent']['path']` - Path to save or share the `node['bittorrent']['file']`, defaults to "/tmp"
* `['bittorrent']['seed']` - Whether the node is seeding, defaults to `false`
* `['bittorrent']['port']` - Bittorrent port to use, default is 6881
* `['bittorrent']['upload_limit']` - Megabytes/second limit, default is 0 which is unlimited
* `['bittorrent']['source']` - Whether to build `aria2` from source, defaults to "false" for Ubuntu and "true" for RHEL/CentOS since packages are unavailable.

License and Author
==================

Author: Matt Ray (<matt@opscode.com>)

Copyright 2011,2012 Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
