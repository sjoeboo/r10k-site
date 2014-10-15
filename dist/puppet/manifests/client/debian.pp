class puppet::client::debian {
  include puppet::client::linux
  package { 'puppet-common':
    ensure  => $puppet::params::puppet_version,
    notify  => Service[$puppet::params::puppet_service],
    require => File[$puppet::params::puppet_repo],
  }

  # We need the backported libaugeas-ruby1.8 in rc-extras to fix
  # http://projects.puppetlabs.com/issues/16203
  if $::lsbdistcodename == 'lucid' {
    package { 'libaugeas-ruby1.8':
      ensure => latest,
    }
  }

  # osfamily was added upstream in facter 1.6.2. These Ubuntu
  # releases have a facter that's older.
  if $::lsbdistcodename =~ /^(hardy|lucid|oneiric)$/ {
    file { '/usr/lib/ruby/site_ruby':
      ensure => directory,
    }
    file { '/usr/lib/ruby/site_ruby/1.8':
      ensure => directory,
    }
    file { '/usr/lib/ruby/site_ruby/1.8/facter':
      ensure => directory,
    }
    file { '/usr/lib/ruby/site_ruby/1.8/facter/osfamily.rb':
      source => 'puppet:///modules/puppet/osfamily.rb',
    }
  }
}
