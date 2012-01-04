name "btseeder"
description "Seed a file with bittorrent."
run_list(
  "recipe[bittorrent::seed]"
  )

default_attributes(
  "bittorrent" => {
    "file" => "testfile.big",
    "path" => "/home/ubuntu/"
    "torrent" => "/tmp/testfile.torrent"
  }
  )
