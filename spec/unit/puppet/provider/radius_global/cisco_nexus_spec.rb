require 'spec_helper'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::RadiusGlobal')
require 'puppet/provider/radius_global/cisco_nexus'

RSpec.describe Puppet::Provider::RadiusGlobal::CiscoNexus do
  let(:provider) { described_class.new }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:radius_global) { instance_double('Cisco::RadiusGlobal', 'radius_global') }

  let(:changes) do
    {
      'default' =>
                   {
                     is:     {
                       name:             'default',
                       timeout:          7,
                       retransmit_count: 3,
                       key:              '444444',
                       key_format:       7,
                       source_interface: ['foo'],
                     },
                     should: should_values
                   }
    }
  end

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::RadiusGlobal).to receive(:new).with('default').and_return(radius_global)
  end

  describe '#set(context, changes)' do
    context 'there are changes' do
      let(:should_values) do
        {
          name:             'default',
          timeout:          9,
          retransmit_count: 2,
          key:              '444444',
          key_format:       3,
          source_interface: ['bar'],
        }
      end

      it 'calls update' do
        expect(provider).to receive(:update).with(context, 'default', changes['default'][:should]).once

        provider.set(context, changes)
      end
    end

    context 'there are no changes' do
      let(:should_values) do
        {
          name:             'default',
          timeout:          7,
          retransmit_count: 3,
          key:              '444444',
          key_format:       7,
          source_interface: ['foo'],
        }
      end

      it 'will not call update' do
        expect(provider).to receive(:update).with(context, 'default', changes['default'][:should]).never

        provider.set(context, changes)
      end
    end

    context 'should is unset' do
      let(:should_values) do
        {
          name:             'default',
          timeout:          'unset',
          retransmit_count: 'unset',
          key:              'unset',
          source_interface: ['unset'],
        }
      end

      it 'calls update' do
        expect(provider).to receive(:update).with(context, 'default', changes['default'][:should]).once

        provider.set(context, changes)
      end
    end

    context 'should is unset and -1' do
      let(:should_values) do
        {
          name:             'default',
          timeout:          -1,
          retransmit_count: -1,
          key:              'unset',
          source_interface: ['unset'],
        }
      end

      it 'calls update' do
        expect(provider).to receive(:update).with(context, 'default', changes['default'][:should]).once

        provider.set(context, changes)
      end
    end
  end

  describe '#get' do
    it 'processes resources' do
      expect(radius_global).to receive(:timeout).and_return(7).twice
      expect(radius_global).to receive(:retransmit_count).and_return(3).twice
      expect(radius_global).to receive(:key).and_return('"444444"').exactly(4).times
      expect(radius_global).to receive(:key_format).and_return(7).once
      expect(radius_global).to receive(:source_interface).and_return('foo').exactly(3).times

      expect(provider.get(context)).to eq [
        {
          name:             'default',
          timeout:          7,
          retransmit_count: 3,
          key:              '444444',
          key_format:       7,
          source_interface: ['foo'],
        },
      ]
    end
  end

  describe '#update' do
    it 'updates the resource' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'default'}).once
      expect(radius_global).to receive(:timeout=).with(7)
      expect(radius_global).to receive(:retransmit_count=).with(3)
      expect(radius_global).to receive(:source_interface=).with('foo')
      expect(radius_global).to receive(:key_set).with('444444', 7)

      provider.update(context, 'default', name:             'default',
                                          timeout:          7,
                                          retransmit_count: 3,
                                          key:              '444444',
                                          key_format:       7,
                                          source_interface: ['foo'])
    end
  end

  munge_data = [
    {
      desc:   '`key` is unset',
      value:  'unset',
      return: nil,
    },
    {
      desc:   '`key` is not unset',
      value:  '44444',
      return: '44444',
    }
  ]

  describe '#munge' do
    munge_data.each do |test|
      context "#{test[:desc]}" do
        it 'returns munged value' do
          expect(provider.munge(test[:value])).to eq(test[:return])
        end
      end
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
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          7,
        retransmit_count: 3,
        source_interface: ['foo'],
      }],
    },
    {
      desc:      '`resources` contains unset values and returns default values',
      resources: [{
        name:             'default',
        timeout:          'unset',
        retransmit_count: 'unset',
        key:              'unset',
        source_interface: ['unset'],
      }],
      results:   [{
        name:             'default',
        timeout:          5,
        retransmit_count: 1,
        key:              'unset',
        source_interface: ['unset'],
      }],
    },
    {
      desc:      '`resources` contains -1 unset values and returns default values',
      resources: [{
        name:             'default',
        timeout:          -1,
        retransmit_count: -1,
        key:              'unset',
        source_interface: ['unset'],
      }],
      results:   [{
        name:             'default',
        timeout:          5,
        retransmit_count: 1,
        key:              'unset',
        source_interface: ['unset'],
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

  validate_should_data = [
    {
      desc:   '`name` is not `default`',
      issue:  'raise an error',
      expect: it { expect { provider.validate_should(name: 'foo') }.to raise_error Puppet::ResourceError, '`name` must be `default`' }
    },
    {
      desc:   '`name` is `default`',
      issue:  'not raise an error',
      expect: it { expect { provider.validate_should(name: 'default') }.not_to raise_error }
    },
    {
      desc:   '`enable` is present',
      issue:  'raise an error',
      expect: it { expect { provider.validate_should(name: 'default', enable: true) }.to raise_error Puppet::ResourceError, 'This provider does not support the `enable` property.' }
    },
    {
      desc:   '`vrf` is present',
      issue:  'raise an error',
      expect: it { expect { provider.validate_should(name: 'default', vrf: 'management') }.to raise_error Puppet::ResourceError, 'This provider does not support the `vrf` property.' }
    },
    {
      desc:   '`key_format` is present but `key` is not',
      issue:  'raise an error',
      expect: it { expect { provider.validate_should(name: 'default', key_format: 0) }.to raise_error Puppet::ResourceError, 'The `key` property must be set when specifying `key_format`.' }
    },
    {
      desc:   '`key_format` is present but `key` is set to `unset`',
      issue:  'raise an error',
      expect: it {
        expect { provider.validate_should(name: 'default', key_format: 0, key: 'unset') }.to raise_error Puppet::ResourceError, 'The `key` property must be set when specifying `key_format`.'
      }
    },
    {
      desc:   '`key_format` is present and so is `key`',
      issue:  'not raise an error',
      expect: it { expect { provider.validate_should(name: 'default', key_format: 0, key: '2222') }.not_to raise_error }
    },
  ]
  describe '#validate_should' do
    validate_should_data.each do |test|
      context "#{test[:desc]}" do
        it "#{test[:issue]}" do
          test[:expect]
        end
      end
    end
  end
end
