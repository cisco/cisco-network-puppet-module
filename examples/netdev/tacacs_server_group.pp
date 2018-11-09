tacacs {'default':
  enable => true,
}

tacacs_server_group { 'red':
  ensure  => 'present',
  servers => ['2.2.2.2', '3.3.3.3', '8.8.8.8']
}
