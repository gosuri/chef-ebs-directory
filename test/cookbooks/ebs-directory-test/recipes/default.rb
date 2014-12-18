#
# Cookbook Name:: ebs-directory-test
# Recipe:: default
#
# Copyright (c) 2014 The Authors, All Rights Reserved.

include_recipe "ebs-directory"

dir = "/test3"

directory(dir) do
  recursive true
end

ebs_directory(dir) do
  size 10
  file_system "ext4"
end
