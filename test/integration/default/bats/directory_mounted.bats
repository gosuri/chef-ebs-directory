#!/usr/bin/env bats

@test "/dev/xvdg is a block device" {
  [ -b "/dev/xvdg" ] 
}

@test "/test1 is mounted" {
  [ -n "$(grep -s /test1 /proc/mounts)" ]
}

@test "/test1 is in fstab" {
  [ -n "$(grep -s /test1 /etc/fstab)" ]
}

@test "/test1/text.txt has valid contents" {
  [ "$(cat /test1/text.txt)" == "file contents" ] 
}
