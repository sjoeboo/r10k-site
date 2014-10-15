class puppet::client ($env = $environment){
  case $::operatingsystem {
    'RedHat', 'CentOS': { include puppet::client::rhel }
    'Debian', 'Ubuntu': { include puppet::client::debian }
    'Windows':          { include puppet::client::windows}
    default:           { fail('Unsupported operating system found in Class[puppet::client]')}
  }
}
