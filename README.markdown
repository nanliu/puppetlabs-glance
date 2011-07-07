# Openstack Glance Puppet Module #

## Overview ##
This module manages Openstack glance:
http://glance.openstack.org/

This module will be available on github and also released to the forge:
(http://forge.puppetlabs.com/)

Warning! While this software is written in the best interest of quality it has not been formally tested by our QA teams. Use at your own risk, but feel free to enjoy and perhaps improve it while you do.

Please see the included Apache Software License for more legal details regarding warranty.

## Installation ##

This is a component of Openstack modules:
https://github.com/puppetlabs/puppetlabs-openstack

## Usage ##

## Glance provider ##

A native puppet type/provider have been implemented for glance to facilitate management of images:

    $ puppet resource glance
    glance { 'kernel':
      ensure    => 'present',
      container => 'ari',
      disk      => 'ari',
      id        => '2',
      location  => 'file:///var/lib/glance/images/2',
      public    => 'true',
      size      => '4404752',
    }
    glance { 'ramdisk':
      ensure    => 'present',
      container => 'ari',
      disk      => 'ari',
      id        => '1',
      location  => 'file:///var/lib/glance/images/1',
      public    => 'true',
      size      => '5882349',
    }
    glance { 'ttylinux_ami':
      ensure    => 'present',
      container => 'ami',
      disk      => 'ami',
      id        => '3',
      location  => 'file:///var/lib/glance/images/3',
      public    => 'true',
      size      => '25165824',
    }

Warning, the glance cli does not detect non-public images, do not configure size since it's derived from the image.

## Contact ##
* Dan Bode <dan@puppetlabs.com>
* Nan Liu <nan@puppetlabs.com>
