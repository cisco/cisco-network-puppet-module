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
