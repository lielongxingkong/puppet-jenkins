exec { 'update apt':
  command => '/usr/bin/apt-get update',
}

# Installing ssl-cert in order to get snakeoil certs
package { 'ssl-cert':
  ensure  => present,
  require => Exec['update apt'],
}

vcsrepo { '/etc/project-config':
  ensure   => latest,
  provider => git,
  revision => 'master',
  source   => 'git://git.openstack.org/openstack-infra/project-config',
}

# Generates ssh rsa keys
define ssh_keygen (
  $ssh_directory = undef
) {
  Exec { path => '/bin:/usr/bin' }

  $ssh_key_file = "${ssh_directory}/${name}"

  exec { "ssh-keygen for ${name}":
    command => "ssh-keygen -t rsa -f ${ssh_key_file} -N ''",
    creates => $ssh_key_file,
  }
}

$ssh_key_directory = '/tmp/jenkins-ssh-keys'
file { $ssh_key_directory:
  ensure => directory,
}
ssh_keygen { 'ssh_rsa_key':
  ssh_directory => $ssh_key_directory,
  require       => File[$ssh_key_directory],
}
