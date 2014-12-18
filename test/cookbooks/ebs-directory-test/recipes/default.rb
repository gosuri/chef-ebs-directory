#
# Cookbook Name:: ebs-directory-test
# Recipe:: default
#
# Copyright (c) 2014 The Authors, All Rights Reserved.

include_recipe "ebs-directory"

%w(/test1 /test2).each do |dir|
  directory(dir) do
    recursive true
  end

  file("#{dir}/text.txt") do
    content "file contents"
  end

  ebs_directory(dir) do
    size 10
    file_system "ext4"
  end
end
