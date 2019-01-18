require 'spec_helper'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::RadiusServer')
require 'puppet/provider/radius_server/cisco_nexus'
require 'fixtures/modules/netdev_stdlib/lib/puppet/type/radius_server'

RSpec.describe Puppet::Provider::RadiusServer::CiscoNexus do
  let(:provider) { described_class.new }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:radius_server) { instance_double('Cisco::RadiusServer', 'radius_server') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::RadiusServer).to receive(:new).and_return(radius_server)
  end

  describe '#get' do
    it 'processes resources' do
      type_name = described_class.instance_method(:get).source_location.first.match(%r{provider\/(.*)\/})[1]
      new_type = Puppet::Type.type(type_name)
      dummy_context = Puppet::ResourceApi::PuppetContext
      dummy_context = dummy_context.new(new_type.type_definition.definition)

      expect(Cisco::RadiusServer).to receive(:radiusservers).and_return('a' => radius_server)
      expect(radius_server).to receive(:name).and_return('1.2.3.4')
      expect(radius_server).to receive(:auth_port).twice.and_return(44)
      expect(radius_server).to receive(:acct_port).twice.and_return(55)
      expect(radius_server).to receive(:timeout).twice.and_return(42)
      expect(radius_server).to receive(:retransmit_count).twice.and_return(43)
      expect(radius_server).to receive(:key).twice.and_return('"12345678"')
      expect(radius_server).to receive(:key_format).twice.and_return(7)
      expect(radius_server).to receive(:accounting).and_return(false)
      expect(radius_server).to receive(:authentication).and_return(true)

      expect(provider.get(dummy_context)).to eq [
        {
          ensure:              'present',
          name:                '1.2.3.4',
          auth_port:           44,
          acct_port:           55,
          timeout:             42,
          retransmit_count:    43,
          key:                 '12345678',
          key_format:          7,
          accounting_only:     false,
          authentication_only: true,
        },
      ]
    end

    it 'processes resources with default values' do
      type_name = described_class.instance_method(:get).source_location.first.match(%r{provider\/(.*)\/})[1]
      new_type = Puppet::Type.type(type_name)
      dummy_context = Puppet::ResourceApi::PuppetContext
      dummy_context = dummy_context.new(new_type.type_definition.definition)

      expect(Cisco::RadiusServer).to receive(:radiusservers).and_return('a' => radius_server)
      expect(radius_server).to receive(:name).and_return('1.2.3.4')
      # Default value from nodeutils 1812
      expect(radius_server).to receive(:auth_port).twice.and_return(1812)
      # Default value from nodeutils 1813
      expect(radius_server).to receive(:acct_port).twice.and_return(1813)
      expect(radius_server).to receive(:timeout).and_return(nil)
      expect(radius_server).to receive(:retransmit_count).and_return(nil)
      expect(radius_server).to receive(:key).and_return(nil)
      expect(radius_server).to receive(:key_format).and_return(nil)
      expect(radius_server).to receive(:accounting).and_return(true)
      expect(radius_server).to receive(:authentication).and_return(false)

      expect(provider.get(dummy_context)).to eq [
        {
          ensure:              'present',
          name:                '1.2.3.4',
          auth_port:           1812,
          acct_port:           1813,
          timeout:             'unset',
          retransmit_count:    'unset',
          key:                 'unset',
          key_format:          'unset',
          accounting_only:     true,
          authentication_only: false,
        },
      ]
    end
  end

  describe '#create' do
    it 'creates the resource' do
      expect(context).to receive(:notice).with(%r{\ACreating '1.2.3.4'}).once
      expect(radius_server).to receive(:accounting=).with(true)
      expect(radius_server).to receive(:acct_port=).with(66)
      expect(radius_server).to receive(:auth_port=).with(77)
      expect(radius_server).to receive(:authentication=).with(false)
      expect(radius_server).to receive(:timeout=).with(2)
      expect(radius_server).to receive(:retransmit_count=).with(4)
      expect(radius_server).to receive(:key_set).with('12345678', 7)

      provider.create(context, '1.2.3.4', name:                '1.2.3.4',
                                          ensure:              'present',
                                          accounting_only:     true,
                                          acct_port:           66,
                                          auth_port:           77,
                                          authentication_only: false,
                                          key:                 '12345678',
                                          key_format:          7,
                                          retransmit_count:    4,
                                          timeout:             2)
    end

    it 'creates the resource with unset values' do
      expect(context).to receive(:notice).with(%r{\ACreating '1.2.3.4'}).once
      expect(radius_server).to receive(:accounting=).with(false)
      expect(radius_server).to receive(:authentication=).with(true)
      expect(radius_server).to receive(:timeout=).with(nil)
      expect(radius_server).to receive(:retransmit_count=).with(nil)
      expect(radius_server).to receive(:key_set).with(nil, nil)

      provider.create(context, '1.2.3.4', name:                '1.2.3.4',
                                          ensure:              'present',
                                          accounting_only:     false,
                                          authentication_only: true,
                                          key:                 'unset',
                                          retransmit_count:    -1,
                                          timeout:             -1)
    end
  end

  describe '#update' do
    it 'updates the resource' do
      expect(context).to receive(:notice).with(%r{\Updating '1.2.3.4'}).once
      expect(radius_server).to receive(:accounting=).with(true)
      expect(radius_server).to receive(:acct_port=).with(66)
      expect(radius_server).to receive(:auth_port=).with(77)
      expect(radius_server).to receive(:authentication=).with(false)
      expect(radius_server).to receive(:timeout=).with(2)
      expect(radius_server).to receive(:retransmit_count=).with(4)
      expect(radius_server).to receive(:key_set).with('12345678', 7)

      provider.update(context, '1.2.3.4', name:                '1.2.3.4',
                                          ensure:              'present',
                                          accounting_only:     true,
                                          acct_port:           66,
                                          auth_port:           77,
                                          authentication_only: false,
                                          key:                 '12345678',
                                          key_format:          7,
                                          retransmit_count:    4,
                                          timeout:             2)
    end

    it 'updates the resource with unset values' do
      expect(context).to receive(:notice).with(%r{\Updating '1.2.3.4'}).once
      expect(radius_server).to receive(:accounting=).with(false)
      expect(radius_server).to receive(:authentication=).with(true)
      expect(radius_server).to receive(:timeout=).with(nil)
      expect(radius_server).to receive(:retransmit_count=).with(nil)
      expect(radius_server).to receive(:key_set).with(nil, nil)

      provider.update(context, '1.2.3.4', name:                '1.2.3.4',
                                          ensure:              'present',
                                          accounting_only:     false,
                                          authentication_only: true,
                                          key:                 'unset',
                                          retransmit_count:    -1,
                                          timeout:             -1)
    end
  end

  describe '#delete' do
    it 'updates the resource' do
      expect(context).to receive(:notice).with(%r{\ADeleting '1.2.3.4'}).once
      expect(radius_server).to receive(:destroy)

      provider.delete(context, '1.2.3.4')
    end
  end

  munge_data = [
    {
      desc:   'string value is unset',
      value:  'unset',
      return: nil,
    },
    {
      desc:   'string value is not unset',
      value:  '1.1.1.1',
      return: '1.1.1.1',
    },
    {
      desc:   'integer value is -1',
      value:  -1,
      return: nil,
    },
    {
      desc:   'integer value is not -1',
      value:  1,
      return: 1,
    },
    {
      desc:   'symbol returned as string',
      value:  :name,
      return: 'name',
    },
    {
      desc:   'any other value returned as is',
      value:  true,
      return: true,
    }
  ]

  describe '#munge_data' do
    munge_data.each do |test|
      context "#{test[:desc]}" do
        it 'returns munged value' do
          expect(provider.munge_flush(test[:value])).to eq(test[:return])
        end
      end
    end
  end

  describe '#validate' do
    it 'fails on hostname value' do
      should_values = {
        ensure:              'present',
        hostname:            '1.2.3.4',
        name:                '1.2.3.4',
        auth_port:           1812,
        acct_port:           1813,
        timeout:             -1,
        retransmit_count:    -1,
        key:                 'unset',
        key_format:          -1,
        accounting_only:     true,
        authentication_only: false,
      }

      expect {
        provider.validate(should_values)
      }.to raise_error(Puppet::ResourceError, "This provider does not support the 'hostname' property. The namevar should be set to the IP of the Radius Server")
    end

    it 'fails on unsupported property' do
      should_values = {
        ensure:              'present',
        group:               'group4',
        deadtime:            true,
        vrf:                 'default',
        source_interface:    'ethernet1/10',
        name:                '1.2.3.4',
        auth_port:           1812,
        acct_port:           1813,
        timeout:             -1,
        retransmit_count:    -1,
        key:                 'unset',
        key_format:          -1,
        accounting_only:     true,
        authentication_only: false,
      }

      expect {
        provider.validate(should_values)
      }.to raise_error(Puppet::ResourceError, 'This provider does not support the following properties: [:group, :deadtime, :vrf, :source_interface]')
    end

    it 'fails on key with key_format not being set' do
      should_values = {
        ensure:              'present',
        name:                '1.2.3.4',
        auth_port:           1812,
        acct_port:           1813,
        timeout:             -1,
        retransmit_count:    -1,
        key_format:          7,
        accounting_only:     true,
        authentication_only: false,
      }

      expect {
        provider.validate(should_values)
      }.to raise_error(Puppet::ResourceError, "The 'key' property must be set when specifying 'key_format'.")
    end

    it 'fails on accounting_only and authentication_only both set to false' do
      should_values = {
        ensure:              'present',
        name:                '1.2.3.4',
        auth_port:           1812,
        acct_port:           1813,
        timeout:             -1,
        retransmit_count:    -1,
        key:                 '"12345678"',
        key_format:          7,
        accounting_only:     false,
        authentication_only: false,
      }

      expect {
        provider.validate(should_values)
      }.to raise_error(Puppet::ResourceError, "The 'accounting_only' and 'authentication_only' properties cannot both be set to false.")
    end
  end

  canonicalize_data = [
    {
      desc:      '`resources` contains key surrounded in ""',
      resources: [{
        name:             'default',
        timeout:          7,
        retransmit_count: 3,
        key:              '"444444"',
        key_format:       7,
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          7,
        retransmit_count: 3,
        key:              '444444',
        key_format:       7,
        source_interface: ['foo'],
      }],
    },
    {
      desc:      '`resources` contains " in the key',
      resources: [{
        name:             'default',
        timeout:          7,
        retransmit_count: 3,
        key:              'foo"bar"444444',
        key_format:       7,
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          7,
        retransmit_count: 3,
        key:              'foo"bar"444444',
        key_format:       7,
        source_interface: ['foo'],
      }],
    },
    {
      desc:      '`resources` does not contain the key value',
      resources: [{
        name:             'default',
        timeout:          7,
        retransmit_count: 3,
        key_format:       7,
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          7,
        retransmit_count: 3,
        key:              'unset',
        key_format:       7,
        source_interface: ['foo'],
      }],
    },
    {
      desc:      '`resources` contains the "unset" key value',
      resources: [{
        name:             'default',
        timeout:          7,
        retransmit_count: 3,
        key:              'unset',
        key_format:       7,
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          7,
        retransmit_count: 3,
        key:              'unset',
        key_format:       7,
        source_interface: ['foo'],
      }],
    },
    {
      desc:      '`resources` does not contain the timeout value',
      resources: [{
        name:             'default',
        retransmit_count: 3,
        key:              'unset',
        key_format:       7,
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          'unset',
        retransmit_count: 3,
        key:              'unset',
        key_format:       7,
        source_interface: ['foo'],
      }],
    },
    {
      desc:      '`resources` contains -1 timeout value',
      resources: [{
        name:             'default',
        retransmit_count: 3,
        timeout:          -1,
        key:              'unset',
        key_format:       7,
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          'unset',
        key_format:       7,
        retransmit_count: 3,
        key:              'unset',
        source_interface: ['foo'],
      }],
    },
    {
      desc:      '`resources` contains -1 values',
      resources: [{
        name:             'default',
        retransmit_count: -1,
        timeout:          -1,
        key:              'unset',
        key_format:       -1,
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          'unset',
        key_format:       'unset',
        retransmit_count: 'unset',
        key:              'unset',
        source_interface: ['foo'],
      }],
    },
    {
      desc:      '`resources` does not contain unsettable values',
      resources: [{
        name:             'default',
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          'unset',
        key_format:       'unset',
        retransmit_count: 'unset',
        key:              'unset',
        source_interface: ['foo'],
      }],
    },
  ]

  describe '#canonicalize' do
    canonicalize_data.each do |test|
      context "#{test[:desc]}" do
        it 'returns canonicalized value' do
          expect(provider.canonicalize(context, test[:resources])).to eq(test[:results])
        end
      end
    end
  end
end
