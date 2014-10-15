class puppet::common {
  #common to all (non-windows) puppet running systems
  #puppet.conf generation
  include puppet::params
  concat { '/etc/puppet/puppet.conf':
    owner   => root,
    group   => root,
    mode    => 0644,
    notify  => Service[$puppet::params::puppet_service]
  }
  concat::fragment { 'puppet_conf_main_common':
    target  => '/etc/puppet/puppet.conf',
    content => template('puppet/main_common.conf.erb'),
    order   => '01',
  }
}
