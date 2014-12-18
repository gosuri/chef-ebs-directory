#!/usr/bin/env bats

@test "/dev/xvdg is a block device" {
  [ -b "/dev/xvdg" ] 
}

@test "/test1/text.txt has valid contents" {
  [ $(cat /test1/text.txt) == 'file contents' ] 
}
