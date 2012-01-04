name "btpeer"
description "Peer a file with bittorrent."
run_list(
  "recipe[bittorrent::peer]"
  )

default_attributes(
  "bittorrent" => {
    "file" => "testfile.big",
    "path" => "/home/ubuntu/",
    "torrent" => "/tmp/testfile.torrent"
  }
  )
