class puppet::server::ca {
  include puppet::server

  concat::fragment { 'puppet_conf_master_ca':
    target  => '/etc/puppet/puppet.conf',
    content => template('puppet/master_ca.conf.erb'),
    order   => '15',
  }
  apache::vhost { $::fqdn:
    port              => 8140,
    ssl               => true,
    ssl_protocol      => '-ALL +SSLv3 +TLSv1',
    ssl_cipher        => 'ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP',
    ssl_verify_client => 'optional',
    ssl_verify_depth  => '1',
    ssl_options       => '+StdEnvVars',
    ssl_cert          => "/var/lib/puppet/ssl/certs/${::fqdn}.pem",
    ssl_key           => "/var/lib/puppet/ssl/private_keys/${::fqdn}.pem",
    ssl_chain         => '/var/lib/puppet/ssl/ca/ca_crt.pem',
    ssl_ca            => '/var/lib/puppet/ssl/ca/ca_crt.pem',
    ssl_crl           => '/var/lib/puppet/ssl/ca/ca_crl.pem',
    docroot           => '/usr/share/puppet/rack/puppetmasterd/public',
    directories       => [
      { path            => '/usr/share/puppet/rack/puppetmasterd/',
        options         => 'None',
        allow_override  => 'None',
        order           => 'allow,deny',
        allow           => 'from all',
        },
    ],
    request_headers   => [
    'set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
    'set X-Client-DN %{SSL_CLIENT_S_DN}e',
    'set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
    ],
  }
}
