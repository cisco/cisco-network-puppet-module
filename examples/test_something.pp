test_something { 'default':
  ensure   => 'present',
  enable   => true,
  contact  => 'foo',
  location => 'unset',
}
