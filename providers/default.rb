include Opscode::Aws::Ec2

def whyrun_supported?
  true
end

action :attach do
  dir = new_resource.directory
  if directory_mounted?(dir)
    Chef::Log.info "#{dir} already on ebs volume. Ignoring"
  else
    Chef::Log.info "Moving #{dir} to a ebs volue"
    attach_and_move(dir)
    new_resource.updated_by_last_action(true)
  end
end

action :detach do
  Chef::Log.info "detaching ebs directory"
  new_resource.updated_by_last_action(true)
end

private

def attach_and_move(dir)
  device_id = determine_free_device_id
  Chef::Log.debug "#{dir} Attaching a new ebs volume to #{device_id}"
  aws_ebs_volume "#{dir}_ebs_volume" do
    aws_access_key new_resource.aws_access_key
    aws_secret_access_key new_resource.aws_secret_access_key
    size new_resource.size
    device device_id.gsub('xvd', 'sd')
    action [ :create, :attach ]
  end

  # wait for the drive to attach, before making a filesystem
  ruby_block "wait-for-drive-attachment" do
    block do
      timeout = 0
      until ::File.stat(device_id).blockdev? || timeout == 1000
        Chef::Log.debug("device #{device_id} not ready - sleeping 10s")
        timeout += 10
        sleep 10
      end
    end
  end

  Chef::Log.info "Creating a #{new_resource.file_system} file system on #{device_id}"
  execute "mkfs-#{dir}" do
    command "mkfs -t #{new_resource.file_system} #{device_id}"
  end

  ["/media#{dir}","/old#{dir}"].each do |d|
    directory(d) do
      action :create
      recursive true
    end
  end
  
  Chef::Log.info "Mounting /media#{dir} to #{device_id}"
  mount "/media#{dir}" do
    device device_id
    fstype new_resource.file_system
    options 'defaults'
    action :mount
  end
  
  Chef::Log.info "Copying all files on #{dir} to /media#{dir}"
  execute "rsync #{dir} to /media#{dir}" do
    command "rsync -aXS --exclude='/*/.gvfs' #{dir}/. /media#{dir}/."
  end
  
  Chef::Log.info "Moving  #{dir} /old#{dir}"
  execute "move #{dir} /old#{dir}" do
    command "mv #{dir} /old#{dir}"
  end

  Chef::Log.info "Unmounting media#{dir}"
  mount "/media#{dir}" do
    device device_id
    action :umount
  end

  directory(dir) do
    action :create
    recursive true
  end

  Chef::Log.info "Mounting #{dir} to #{device_id}"
  mount(dir) do
    device device_id
    fstype new_resource.file_system
    options 'defaults'
    action [:enable, :mount]
  end
end

def directory_mounted?(dir)
  Mixlib::ShellOut.new("grep -s #{dir} /proc/mounts") != ''
end

def determine_free_device_id
  current = Dir.glob('/dev/xvd*')
  ('f'..'p').each do |i|
    id = "/dev/xvd#{i}"
    return id unless current.include?(id)
  end
end
