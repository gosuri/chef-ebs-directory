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

  file "#{dir}/text.txt" do
    content "file contents"
  end

  ebs_directory(dir) do
    aws_access_key node[:aws_access_key]
    aws_secret_access_key node[:aws_secret_access_key]
    size 10
    file_system "ext4"
  end
end
