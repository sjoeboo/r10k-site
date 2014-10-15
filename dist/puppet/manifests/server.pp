class puppet::server {
  #does common setup for puppet ca's/compilation nodes (slaves)
  include foreman::facts
  #Add dns_alt names and other [main] settings
  concat::fragment { 'puppet_main_masters':
    target  => '/etc/puppet/puppet.conf',
    content => template('puppet/main_masters.conf.erb'),
    order   => '02',
  }
  #Add [master] base block
  concat::fragment { 'puppet_master_common':
    target  => '/etc/puppet/puppet.conf',
    content => template('puppet/master_common.conf.erb'),
    order   => '10',
  }
  # Add [production] block
  # this gets run *after* master block on both ca and slaves.
  concat::fragment { 'puppet_production_common':
    target  => '/etc/puppet/puppet.conf',
    content => template('puppet/master_production.conf.erb'),
    order   => '20',
  }
  #Install/set up apache/passenger
  $packages = ['puppetdb-terminus','puppet-server']
  package { $packages:
    ensure => installed,
  }
  user { 'puppet':
    shell => '/bin/bash',
  }
  file { '/etc/puppet/environments':
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    backup => false,
  }
  file { '/usr/share/puppet/rack/':
    ensure  => directory,
    owner   => puppet,
    group   => puppet,
  }
  file { '/usr/share/puppet/rack/puppetmasterd':
    ensure  => directory,
    owner   => puppet,
    group   => puppet,
    require => File['/usr/share/puppet/rack/']
  }
  file { '/usr/share/puppet/rack/puppetmasterd/public':
    ensure  => directory,
    owner   => puppet,
    group   => puppet,
    require => File['/usr/share/puppet/rack/puppetmasterd']
  }
  file { '/usr/share/puppet/rack/puppetmasterd/config.ru':
    source => 'file:///usr/share/puppet/ext/rack/config.ru',
    owner  => puppet,
    group  => puppet,
  }
  file { '/etc/puppet/puppetdb.conf':
    ensure => link,
    target => '/etc/puppet/environments/production/puppetdb.conf',
    backup => false,
  }
  file { '/etc/puppet/routes.yaml':
    ensure => link,
    target => '/etc/puppet/environments/production/routes.yaml',
    backup => false,
  }
  file { '/etc/puppet/auth.conf':
    ensure => link,
    target => '/etc/puppet/environments/production/auth.conf',
    backup => false,
  }
  file { '/etc/puppet/autosign.conf':
    ensure => link,
    target => '/etc/puppet/environments/production/autosign.conf',
    backup => false,
  }
  file { '/etc/puppet/fileserver.conf':
    ensure => link,
    target => '/etc/puppet/environments/production/fileserver.conf',
    backup => false,
  }
  file { '/etc/puppet/manifests':
    ensure => link,
    target => '/etc/puppet/environments/production/manifests',
    backup => false,
  }
  file { '/etc/puppet/modules':
    ensure => link,
    target => '/etc/puppet/environments/production/modules',
    backup => false,
  }
  file { '/etc/puppet/dist':
    ensure => link,
    target => '/etc/puppet/environments/production/dist',
    backup => false,
  }
  file { '/etc/puppet/namespaceauth.conf':
    ensure => link,
    target => '/etc/puppet/environments/production/namespaceauth.conf',
    backup => false,
  }
  file { '/etc/puppet/hiera.yaml':
    ensure => link,
    target => '/etc/puppet/environments/production/hiera.yaml',
    backup => false,
  }
  file { '/etc/puppet/hieradata':
    ensure => link,
    target => '/etc/puppet/environments/production/hieradata',
    backup => false,
  }
  file { '/etc/puppet/hipchat.yaml':
    ensure => link,
    target => '/etc/puppet/environments/production/hipchat.yaml',
    backup => false,
  }
  class { 'apache':
    default_vhost       => false,
  }
  class { 'apache::mod::passenger':
    passenger_high_performance  => 'on',
    passenger_max_pool_size     => $::processorcount * 2,
    passenger_pool_idle_time    => 600,
    passenger_max_requests      => 1000,
    passenger_use_global_queue  => 'on'
  }

  #ssh keys etc for deploys
  file { '/var/lib/puppet/.ssh':
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0600',
  }
  file { '/var/lib/puppet/.ssh/id_rsa':
    source => 'puppet:///modules/puppet/ssh/id_rsa',
    owner  => puppet,
    group  => puppet,
    mode   => '0700',
  }
  file { '/var/lib/puppet/.ssh/id_rsa.pub':
    source => 'puppet:///modules/puppet/ssh/id_rsa.pub',
    owner  => puppet,
    group  => puppet,
    mode   => '0700',
  }
  file { '/var/lib/puppet/.ssh/id_rsa_puppet':
    source => 'puppet:///modules/puppet/ssh/id_rsa_puppet',
    owner  => puppet,
    group  => puppet,
    mode   => '0700',
  }
  file { '/var/lib/puppet/.ssh/known_hosts':
    source => 'puppet:///modules/puppet/ssh/known_hosts',
    owner  => puppet,
    group  => puppet,
    mode   => '0700',
  }
  file { '/var/lib/puppet/.ssh/authorized_keys':
    source => 'puppet:///modules/puppet/ssh/authorized_keys',
    owner  => puppet,
    group  => puppet,
    mode   => '0700',
  }
  file { '/var/lib/puppet/deploy.rb':
    source => 'puppet:///modules/puppet/deploy.rb',
    owner  => puppet,
    group  => puppet,
    mode   => '0700',
  }
  logrotate::rule { 'httpd':
    path          => '/var/log/httpd/*.log',
    rotate        => '7',
    rotate_every  => 'day',
    sharedscripts => true,
    missingok     => true,
    postrotate    => '/sbin/service httpd reload > /dev/null 2>/dev/null || true',
  }
  #for hipchat failed run notifications
  package { 'rubygem-httparty':
    ensure => installed,
  }
  package { 'hipchat':
    ensure    => '0.11.0',
    provider  => 'gem',
    require   => Package['rubygem-httparty'],
  }
}

