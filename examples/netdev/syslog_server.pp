syslog_server {'1.2.3.4':
  ensure         => present,
  severity_level => 2,
  port           => 48,
  vrf            => 'default',
  facility       => 'local2',
}

syslog_server {'2.2.2.2':
  ensure   => present,
  vrf      => 'default',
  facility => 'mail',
}
