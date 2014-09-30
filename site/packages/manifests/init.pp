class pacakges( $packages = [] ) {
  package { $packages:
    ensure => installed,
  }
}
