ntp_server {'5.5.5.5':
  ensure  => 'present',
  maxpoll => 5,
}
