class puppet::client::linux {
  include puppet::params
  include puppet::common
  concat::fragment { 'puppet_conf_agent':
    target  => '/etc/puppet/puppet.conf',
    content => template('puppet/agent.conf.erb'),
    order   => '05',
  }
  # common puppet client configs for all linux hosts
  $hour = fqdn_rand(24)
  $minute = fqdn_rand(50)
  $second = fqdn_rand(60)
  file { '/etc/facter/':
    ensure => directory,
    backup => false,
  }
  file { '/etc/facter/facts.d':
    ensure  => directory,
    backup  => false,
    require => File['/etc/facter/'],
  }
  file { '/usr/local/bin/cobbler_facts.rb':
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/puppet/cobbler_facts.rb',
  }
  cron { 'cobbler_facts':
    ensure  => present,
    command => "sleep ${second}; /usr/local/bin/cobbler_facts.rb >/dev/null 2>&1",
    hour    => $hour,
    minute  => $minute,
    require => File['/usr/local/bin/cobbler_facts.rb'],
  }
  #file { '/etc/puppet/namespaceauth.conf':
  #  path   => '/etc/puppet/namespaceauth.conf',
  #  owner  => root,
  #  group  => root,
  #  mode   => '0644',
  #  source => 'puppet:///modules/puppet/client/namespaceauth.conf',
  #  notify => Service[$puppet::params::puppet_service],
  #}
  #file { '/etc/puppet/auth.conf':
  #  path   => '/etc/puppet/auth.conf',
  #  owner  => root,
  #  group  => root,
  #  mode   => '0644',
  #  source => 'puppet:///modules/puppet/client/auth.conf',
  #  notify => Service[$puppet::params::puppet_service],
  #}
  service { $puppet::params::puppet_service:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    # subscribe  => Concat['/etc/puppet/puppet.conf'],
    }
    cron { 'puppet':
      ensure  => present,
      command => "sleep ${second}; PATH=\"\$PATH:/sbin:/usr/sbin\" service puppet stop >/dev/null; rm -f /var/lib/puppet/state/puppetdlock /var/lib/puppet/state/agent_catalog_run.lock; PATH=\"\$PATH:/sbin:/usr/sbin\" service puppet start >/dev/null",
      hour    => $hour,
      minute  => $minute,
    }
    $puppet_repo = $::osfamily ? {
      'Debian' => '/etc/apt/sources.list.d/puppet.list',
      'RedHat' => '/etc/yum.repos.d/puppet.repo',
    }
}
