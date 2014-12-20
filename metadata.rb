name             'ebs-directory'
maintainer       'Greg Osuri'
maintainer_email 'gosuri@demandbase.com'
license          'MIT'
description      'The cookbook includes recipe and LWRP to move a directory in a partition to a new aws ebs volume'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'
recipe           'ebs-directory', 'Installs the right_aws gem during compile time'

depends 'aws', '2.5.0'
