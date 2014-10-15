class puppet::client::rhel {
  include puppet::client::linux
  package { 'puppet':
    ensure  => $puppet::params::puppet_version,
    notify  => Service[$puppet::params::puppet_service],
    require => File[$puppet::client::linux::puppet_repo],
  }
}
