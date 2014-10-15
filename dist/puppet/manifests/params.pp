class puppet::params {
  $puppet_ca = hiera('puppet_ca','puppet')
  $puppet_server = hiera('puppet_server','puppet')
  $puppet_version = hiera('puppet_version','installed')
  $puppet_interval = hiera('puppet_interval','7200')
  $puppet_ssldir = hiera('puppet_ssldir','/var/lib/puppet/ssl')
  $puppet_repo = $::osfamily ? {
    'Debian' => '/etc/apt/sources.list.d/puppet.list',
    'RedHat' => '/etc/yum.repos.d/puppet.repo',
    default => '',
  }

  if $::operatingsystem == 'Fedora' and $::lsbmajdistrelease == '17' {
    $puppet_service = 'puppetagent'
  } else {
    $puppet_service = 'puppet'
  }
}
