snmp_community { 'bar':
    ensure => present,
    group  => 'network-admin',
    acl    => 'testacl';
  'foo':
    ensure => present,
    group  => 'network-admin';
}
