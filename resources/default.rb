actions :attach, :detach

default_action :attach

attribute :directory,     :kind_of => String,     :name_attribute => true
attribute :size,          :kind_of => Integer,    :default => 8
attribute :file_system,   :kind_of => String,     :default => "ext4"
attribute :mount_options, :kind_of => String,     :default => "defaults"
