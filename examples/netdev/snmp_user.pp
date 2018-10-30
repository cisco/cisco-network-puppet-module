snmp_user { 'test_snmp_user':
    ensure        => present,
    roles         => ['network-operator'],
    auth          => 'md5',
    password      => '0x7e5030ffd26d7e1b366a9041e9c63c94',
    privacy       => 'aes128',
    private_key   => '0xcc012f26b3384d4b3da979bff48b4ffe',
    localized_key => true;
}
