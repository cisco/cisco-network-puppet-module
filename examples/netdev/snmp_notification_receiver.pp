snmp_notification_receiver { '2.3.4.5':
  ensure           => present,
  source_interface => 'ethernet1/3',
  port             => 47,
  type             => 'traps',
  username         => 'admin',
  version          => 'v3',
  security         => 'priv',
}
