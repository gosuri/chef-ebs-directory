# chef-ebs-directory

The cookbook includes recipe and LWRP to move a directory in a partition to a new ebs volume

## Resources/Providers

### ```ebs_directory```

The LWRP provides an easy way to move an existing directory to a new ebs volume

#### Actions

* ```:add```: moves the directory to a new volume
* ```:detach```: TODO:  moves the directory to the root partition if attached to a volume

#### Attribute Parameters

* ```directory```: Directory to move to a new volume.
* ```size```: Size of the volume. Defaults to 8
* ```file_system```: File system of the new mount. Defaults to ```ext4```
* ```mount_options```: Options to mount the directory with. Defaults to ```defaults```

#### Examples

The below will move ```/home``` directory to a new volume

```
ebs_directory("/home") do
  size 8
  file_system 'ext3`
end
```
