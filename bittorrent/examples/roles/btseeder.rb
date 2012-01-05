name "btseeder"
description "Seed a file with bittorrent."
run_list(
  "recipe[bittorrent::seed]"
  )

default_attributes(
  "bittorrent" => {
    "file" => "crm84.tar.gz",
    "path" => "/home/ubuntu/",
    "torrent" => "/tmp/crm84.torrent"
  }
  )
