network_trunk { 'ethernet1/4':
    ensure        => 'present',
    mode          => 'trunk',
    tagged_vlans  => ['12', '16', '9', '3', '4', '6', '7', '8'],
    untagged_vlan => 1;
  'ethernet1/1':
    ensure        => 'present',
    mode          => 'trunk',
    tagged_vlans  => ['12', '10', '9', '3', '4', '6', '7', '8'],
    untagged_vlan => 1;
}
