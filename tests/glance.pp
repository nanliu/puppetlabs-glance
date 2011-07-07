# Using sample ttylinux image from http://wiki.openstack.org/GettingImages

Exec {
  path => '/bin:/sbin:/usr/bin:/usr/sbin',
}
exec { 'fetch_ttylinux':
  command => 'curl -s -o /tmp/ttylinux.tar.gz http://smoser.brickies.net/ubuntu/ttylinux-uec/ttylinux-uec-amd64-12.1_2.6.35-22_1.tar.gz',
  creates => '/tmp/ttylinux.tar.gz',
} ~>
exec { 'extract_ttylinux':
  command     => 'tar xvf /tmp/ttylinux.tar.gz',
  cwd         => '/tmp/',
  refreshonly => true,
  before      => Glance['ttylinux-initrd', 'ttylinux-vmlinux', 'ttylinux-img'],
}

glance { 'ttylinux-initrd':
  ensure    => 'present',
  container => 'ari',
  disk      => 'ari',
  image     => '/tmp/ttylinux-uec-amd64-12.1_2.6.35-22_1-initrd',
} ->
glance { 'ttylinux-vmlinux':
  ensure    => 'present',
  container => 'aki',
  disk      => 'aki',
  image     => '/tmp/ttylinux-uec-amd64-12.1_2.6.35-22_1-vmlinuz',
} ->
glance { 'ttylinux-img':
  ensure    => 'present',
  container => 'ami',
  disk      => 'ami',
  image     => '/tmp/ttylinux-uec-amd64-12.1_2.6.35-22_1.img',
}
