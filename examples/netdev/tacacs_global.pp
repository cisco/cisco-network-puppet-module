tacacs {'default':
  enable => true,
}

tacacs_global { 'default':
  key              => '44444444',
  key_format       => 7,
  timeout          => 5,
  source_interface => ['ethernet1/1'],
}
