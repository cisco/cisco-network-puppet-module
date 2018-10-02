require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'test_something',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage ...
    EOS
  features: ['remote_resource'],
  attributes:   {
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    name:        {
      type:      'String',
      desc:      'The name of the resource you want to manage.',
      behaviour: :namevar,
    },
    enable: {
      type: 'Boolean',
      desc:      'The name of the resource you want to manage.',
    },
    contact: {
      type: 'String',
      desc:      'The name of the resource you want to manage.',
    },
    location: {
      type: 'String',
      desc:      'The name of the resource you want to manage.',
    },
  },
)
