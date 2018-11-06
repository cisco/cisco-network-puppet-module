tacacs_server { '2.2.2.2':
  ensure     => 'present',
  key        => '44444444',
  key_format => 7,
  port       => 48,
  timeout    => 2,
}

tacacs_server { '3.3.3.3':
  ensure     => 'present',
  key        => '44444444',
  key_format => 7,
  port       => 48,
  timeout    => 2,
}

tacacs_server { '8.8.8.8':
  ensure     => 'present',
  key        => '44444444',
  key_format => 7,
  port       => 48,
  timeout    => 2,
}
