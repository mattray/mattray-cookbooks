Description
===========
Manages the use of [BitTorrent](http://en.wikipedia.org/wiki/BitTorrent) for distributing files with the [Aria2 BitTorrent Client](http://aria2.sourceforge.net). It includes LWRPs for downloading files, creating torrents and seeding files. There are also example `seed` and `peer` recipes that use attributes to share and download torrents.

Requirements
============
Platform
--------
Tested with Ubuntu 10.04 and 11.04. Uses the `aria2` and `mktorrent` packages.

Resource/Provider
=================
bittorrent_peer
---------------
Download the file or files specified by a torrent via the [BitTorrent protocol](http://en.wikipedia.org/wiki/BitTorrent).

# Actions
- :create: Download the contents of a torrent via the BitTorrent protocol
- :stop: Stop a download (usually used to end seeding).

# Attribute Parameters
- torrent: torrent file of the swarm to join. Can either be a url or local file path.
- path: directory to for the download.
- blocking: should the file be downloaded in a blocking way? If `true` Chef will download the file in a single Chef run, if `false` will start the download and continue seeding in the background. Default is `true`.
- continue_seeding: should the file continue to be seeded to the swarm after download? Default is `false`.
- dht_entry_point: HOST:PORT for initializing trackerless transfers with DHT.
- dht_listen_port: UDP port or ports to listen for DHT. Default is "6881-6999".
- listen_port: TCP port or ports to listen for incoming peers. Default is "6881-6999".
- upload_limit: maximum upload speed limit in kilobytes/sec.

# Examples
    # download the lucid iso
    bittorrent_peer "http://releases.ubuntu.com/lucid/ubuntu-10.04.1-server-i386.iso.torrent" do
      path "/home/ubuntu/"
      action :create
    end
    
    # do the same thing but continue seeding after download
    bittorrent_peer "http://releases.ubuntu.com/lucid/ubuntu-10.04.1-server-i386.iso.torrent" do
      path "/home/ubuntu/"
      continue_seeding true
      action :create
    end

    # peer a trackerless local torrent with a megabyte limit
    bittorrent_peer "/tmp/bigpackage.torrent" do
      path "/tmp/"
      continue_seeding true
      dht_entry_point "10.0.111.10:6881"
      dht_listen_port "6881"
      listen_port "6882"
      upload_limit 1024
      action :create
    end

    # stop the previous torrent
    bittorrent_peer "/tmp/bigpackage.torrent" do
      action :stop
    end

bittorrent_create
-----------------
Create a .torrent file for sharing a local file or directory via the [BitTorrent protocol](http://en.wikipedia.org/wiki/BitTorrent). You can use the `bittorrent_seed` LWRP to share the .torrent after it is created.

# Actions
- :create: Create a .torrent for sharing a local file via the BitTorrent protocol.

# Attribute Parameters
- torrent: torrent file to create. Local file path. Name attribute.
- path: path of the source file or directory.
- tracker: tracker or trackers to list.
- group: group owner of the .torrent file (string or id).
- mode: mode of the .torrent file.
- owner: owner for the .torrent file.

# Example
    # create a torrent for the the lucid iso
    bittorrent_create "/home/ubuntu/ubuntu.iso.torrent" do
      path "/home/ubuntu/ubuntu.iso"
      action :create
    end

    # create a torrent for using trackerless with DHT
    bittorrent_create "/tmp/bigpackage.torrent" do
      path "/tmp/bigpackage"
      tracker "node://10.0.111.3:6881/"
      action :create
    end

bittorrent_seed
---------------
Share a local file via the [BitTorrent protocol](http://en.wikipedia.org/wiki/BitTorrent) and a .torrent. You can use the `bittorrent_create` LWRP to create the .torrent file.

# Actions
- :create: Seed a local file from a .torrent and share it via BitTorrent.
- :stop: Stop a download (usually used to end seeding).

# Attribute Parameters
- torrent: torrent file of the swarm to join. Can either be a url or local file path.
- path: directory to for the download.
- dht_listen_port: UDP port or ports to listen for DHT. Default is "6881-6999".
- listen_port: TCP port or ports to listen for incoming peers. Default is "6881-6999".
- upload_limit: maximum upload speed limit in kilobytes/sec.

# Examples
    # share the lucid iso
    bittorrent_seed "http://releases.ubuntu.com/lucid/ubuntu-10.04.1-server-i386.iso.torrent" do
      path "/home/ubuntu/"
      action :create
    end
    
    # seed a trackerless local torrent with a megabyte limit
    bittorrent_seed "/tmp/bigpackage.torrent" do
      path "/tmp/"
      dht_listen_port "6881"
      listen_port "6882"
      upload_limit 1024
      action :create
    end

    # stop the previous torrent
    bittorrent_seed "/tmp/bigpackage.torrent" do
      action :stop
    end

Recipes
=======
These recipes are provided as an easy way to use bittorrent to share and download files.

peer
----
Pass a torrent and a path

seed
----
Pass a torrent, a file and a path

Attributes
==========
* `node["bittorrent"]["config_dir"]` - Bittorrent's config directory, default `/var/lib/bittorrent-daemon/info`.
* `node["bittorrent"]["config_file"]` - Bittorrent's config directory, default `/var/lib/bittorrent-daemon/info`.
* `node["bittorrent"]["download_dir"]` - Directory to move complete files to, default `/var/lib/bittorrent-daemon/downloads`.

License and Author
==================

Author: Matt Ray (<matt@opscode.com>)

Copyright 2011, Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
