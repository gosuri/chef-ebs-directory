# ebs-directory

The cookbook includes recipe and LWRP to move a directory in a partition to a new aws ebs volume

**Note** This cookbook depends on Opscode's [aws](http://community.opscode.com/cookbooks/aws) cookbook and uses `right_aws` RubyGem to interact with the AWS API

## Requirements

Requires Chef 0.7.10 or higher for Lightweight Resource and Provider
support. Chef 0.8+ is recommended. While this cookbook can be used in
`chef-solo` mode, to gain the most flexibility, we recommend using
`chef-client` with a Chef Server.

An Amazon Web Services account is required. The Access Key and Secret
Access Key are used to authenticate with EC2.

### AWS Credentials

In order to manage AWS components, authentication credentials need to
be available to the node. There are 2 way to handle this:
1. explicitly pass credentials parameter to the resource
2. or let the resource pick up credentials from the IAM role assigned to the instance

### Using resource parameters

To pass the credentials to the resource, credentials should be available to the node.
There are a number of ways to handle this, such as node attributes or Chef roles.

We recommend storing these in a databag (Chef 0.8+), and loading them in the recipe where the
resources are needed.

DataBag recommendation:

    % knife data bag show aws main
    {
      "id": "main",
      "aws_access_key_id": "YOUR_ACCESS_KEY",
      "aws_secret_access_key": "YOUR_SECRET_ACCESS_KEY"
    }

This can be loaded in a recipe with:

    aws = data_bag_item("aws", "main")

And to access the values:

    aws['aws_access_key_id']
    aws['aws_secret_access_key']

We'll look at specific usage below.

#### Using IAM instance role

If your instance has an IAM role, then the credentials can be automatically resolved by the cookbook
using Amazon instance metadata API.

You can then omit the resource parameters `aws_secret_access_key` and `aws_access_key`.

Of course, the instance role must have the required policies. Here is a sample policy for EBS volume
management:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateVolume",
        "ec2:ModifyVolumeAttribute",
        "ec2:DescribeVolumeAttribute",
        "ec2:DescribeVolumeStatus",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:EnableVolumeIO"
      ],
      "Sid": "Stmt1381536011000",
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    }
  ]
}
```

For resource tags:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:CreateTags"
      ],
      "Sid": "Stmt1381536708000",
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    }
  ]
}
```

## Recipes

### default.rb

The default recipe installs the ```right_aws``` RubyGem, which this cookbook requires in order to work with the EC2 API. Make sure that the aws recipe is in the node or role ```run_list``` before any resources from this cookbook are used.

    "run_list": [
      "recipe[ebs-directory]"
    ]

The ```gem_package``` is created as a Ruby Object and thus installed during the Compile Phase of the Chef run.

## Resources/Providers

### ```ebs_directory```

The LWRP provides an easy way to move an existing directory to a new ebs volume

#### Actions

* ```:add```: moves the directory to a new volume
* ```:detach```: TODO:  moves the directory to the root partition if attached to a volume

#### Attribute Parameters

* ```aws_secret_access_key```, ```aws_access_key``` - passed to Opscode::AWS:Ec2 to authenticate required, unless using IAM roles for authentication.
* ```directory```: Directory to move to a new volume.
* ```size```: Size of the volume. Defaults to 8
* ```file_system```: File system of the new mount. Defaults to ```ext4```
* ```mount_options```: Options to mount the directory with. Defaults to ```defaults```

#### Examples

The below will move ```/home``` directory to a new volume

```
ebs_directory "/home" do
  size 8
  file_system 'ext3`
end
```

## Testing

This cookbook uses test-kitchen for testing. Install the required using ```bundle install``` or ```chef exec bundle install``` if using ChefDk. After placing your keys run ```kitchen test```

### AWS keys in .env file

Place aws keys in .env file for convenience

```
$ cat > .env <<EOF
AWS_ACCESS_KEY_ID='AK...'
AWS_SECRET_ACCESS_KEY="WU.."
AWS_SSH_KEY_ID="deploy.."
EOF
```

## License and Author

* Author:: Greg Osuri (<gosuri@demandbase.com>)

Copyright 2014, Demandbase, Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
