default[:dhcp][:interfaces] = [ "eth0" ]

default[:dhcp][:parameters] = {
  "default-lease-time" => "600",
  "max_lease-time" => "7200",
  "ddns-update-style" => "none",
  "log-facility" => "local7"
}

default[:dhcp][:options] = {
  "domain-name" => "\"example.org\"",
  "domain-name-servers" => ["ns1.example.org", "ns2.example.org"]
}

