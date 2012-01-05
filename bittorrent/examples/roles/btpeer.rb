name "btpeer"
description "Peer a file with bittorrent."
run_list(
  "recipe[bittorrent::peer]"
  )

default_attributes(
  "bittorrent" => {
    "seed" => true,
    "file" => "crm84.tar.gz",
    "path" => "/home/ubuntu/",
    "torrent" => "/tmp/crm84.torrent"
  }
  )
