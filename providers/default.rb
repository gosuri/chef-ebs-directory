include Opscode::Aws::Ec2

def whyrun_supported?
  true
end

action :attach do
  dir = new_resource.directory
  Chef::Log.info "Moving #{dir} to a ebs volue"

  device_id = determine_free_device_id
  aws_ebs_volume "#{dir}_ebs_volume" do
    size 8
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

  # create a filesystem
  execute "mkfs-#{dir}" do
    command "mkfs -t #{new_resource.file_system} #{device_id}"
    # not_if "grep -qs #{mount_point} /proc/mounts"
  end

  ["/media#{dir}","/old#{dir}"].each do |d|
    directory(d) do
      action :create
      recursive true
    end
  end
  
  execute "rsync #{dir} to /media#{dir}" do
    command "sudo rsync -aXS --exclude='/*/.gvfs' #{dir}/. /media#{dir}/."
  end
  
  execute "move #{dir} /old#{dir}" do
    command "mv /#{dir} /old#{dir}"
  end

  mount "/media/#{dir}" do
    device device_id
    action :umount
  end

  directory "#{dir}" do
    action :create
    recursive true
  end

  mount "#{dir}" do
    device device_id
    fstype new_resource.file_system
    options 'defaults'
    action [:enable, :mount]
  end
end

action :detach do
  Chef::Log.info "detaching ebs directory"
end

private

def determine_free_device_id
  current = Dir.glob('/dev/xvd*')
  ('f'..'p').each do |i|
    id = "/dev/xvd#{i}"
    return id unless current.include?(id)
  end
end
