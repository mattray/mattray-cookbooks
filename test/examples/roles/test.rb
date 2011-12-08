name "test"
description "Break things"
run_list(
  "recipe[test]"
  )

default_attributes(
  "test" => {
    "yuck" => ["def","ddeeff"]
  }
  )
