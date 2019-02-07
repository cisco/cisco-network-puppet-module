node 'nexus', 'n9kv1' {
  banner { 'default':
    motd => 'This is the newest MOTD.',
  }

  ntp_auth_key { '1':
      password => 'zzqcZaicguln',
      mode     => 7;
    '2':
      password => 'thisPassword',
      mode     => 7;
    '3':
      ensure    => 'absent',
      algorithm => 'md5',
      password  => 'thisPassword',
      mode      => 7;
    '65535':
      algorithm => 'md5',
      password  => 'thisPassword',
      mode      => 7;
    '99':
      algorithm => 'md5',
      password  => 'thisPassword',
      mode      => 7;
  }

  ntp_server {'5.5.5.5':
    ensure  => 'present',
    maxpoll => 5,
    key     => 1,
  }

  network_dns { 'settings':
    domain   => 'foo.bar.com',
    hostname => 'foo',
    search   => ['test.com', 'test.net'],
    servers  => ['8.8.8.8', '2001:4860:4860::8888'],
  }

  radius_global { 'default':
    retransmit_count => 4,
    timeout          => 1,
    source_interface => ['ethernet1/3'],
  }
}
