require 'spec_helper'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::TacacsGlobal')
require 'puppet/provider/tacacs_global/cisco_nexus'

RSpec.describe Puppet::Provider::TacacsGlobal::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:tacacs_global) { instance_double('Cisco::TacacsGlobal', 'tacacs_global') }

  let(:changes) do
    {
      'default' =>
                   {
                     is:     {
                       name:             'default',
                       timeout:          5,
                       key:              '22222',
                       key_format:       7,
                       source_interface: ['ethernet1/1'],
                     },
                     should: should_values
                   }
    }
  end

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::TacacsGlobal).to receive(:tacacs_global).and_return({})
  end

  describe '#set' do
    context 'should is different' do
      let(:should_values) do
        {
          name:             'default',
          timeout:          5,
          key:              '44444',
          key_format:       7,
          source_interface: ['ethernet1/6'],
        }
      end

      it 'performs an update' do
        allow(Cisco::TacacsGlobal).to receive(:tacacs_global).and_return('default' => tacacs_global)
        expect(tacacs_global).to receive(:encryption_key_set).with(7, '44444')
        expect(tacacs_global).to receive(:timeout=).with(5)
        expect(tacacs_global).to receive(:source_interface=).with('ethernet1/6')
        expect(context).to receive(:notice).with(%r{Updating 'default' with})

        provider.set(context, changes)
      end
    end

    context 'should is the same' do
      let(:should_values) do
        {
          name:             'default',
          timeout:          5,
          key:              '22222',
          key_format:       7,
          source_interface: ['ethernet1/1'],
        }
      end

      it 'does not update' do
        expect(context).not_to receive(:notice).with(anything)

        provider.set(context, changes)
      end
    end
  end

  describe '#get' do
    context 'tacacs_global is not empty' do
      it 'returns the results' do
        allow(Cisco::TacacsGlobal).to receive(:tacacs_global).and_return('default' => tacacs_global)
        expect(tacacs_global).to receive(:key).and_return('22222').exactly(6).times
        expect(tacacs_global).to receive(:timeout).and_return(5, 5)
        expect(tacacs_global).to receive(:key_format).and_return(7)
        expect(tacacs_global).to receive(:source_interface).and_return('ethernet1/1').exactly(3).times

        expect(provider.get(context)).to eq [
          {
            name:             'default',
            timeout:          5,
            key:              '22222',
            key_format:       7,
            source_interface: ['ethernet1/1'],
          }
        ]
      end
    end
  end

  describe '#update' do
    context 'tacacs_global is not empty' do
      let(:should_values) do
        {
          name:             'default',
          timeout:          5,
          key:              '44444',
          key_format:       7,
          source_interface: ['ethernet1/6'],
        }
      end

      it 'returns the results' do
        allow(Cisco::TacacsGlobal).to receive(:tacacs_global).and_return('default' => tacacs_global)
        expect(tacacs_global).to receive(:encryption_key_set).with(7, '44444')
        expect(tacacs_global).to receive(:timeout=).with(5)
        expect(tacacs_global).to receive(:source_interface=).with('ethernet1/6')
        expect(context).to receive(:notice).with(%r{Updating 'default' with})

        provider.update(context, 'default', should_values)
      end
    end
  end

  describe '#validate_should' do
    it { expect { provider.validate_should(name: 'foo') }.to raise_error Puppet::ResourceError, "This provider only supports namevar of 'default'." }
    it { expect { provider.validate_should(name: 'default', key_format: 7) }.to raise_error Puppet::ResourceError, "The 'key' property must be set when specifying 'key_format'." }
    it { expect { provider.validate_should(name: 'default', key_format: 7, key: '44444') }.not_to raise_error }
  end

  describe '#munge' do
    it { expect(provider.munge(nil)).to eq(nil) }
    it { expect(provider.munge('unset')).to eq(nil) }
    it { expect(provider.munge('foo')).to eq('foo') }
  end

  canonicalize_data = [
    {
      desc:      '`resources` contains key surrounded in ""',
      resources: [{
        name:             'default',
        timeout:          7,
        key:              '"444444"',
        key_format:       7,
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          7,
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
        key:              'foo"bar"444444',
        key_format:       7,
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          7,
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
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          7,
        key:              'unset',
        source_interface: ['foo'],
      }],
    },
    {
      desc:      '`resources` contains the "unset" key value',
      resources: [{
        name:             'default',
        timeout:          7,
        key:              'unset',
        key_format:       7,
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          7,
        key:              'unset',
        key_format:       7,
        source_interface: ['foo'],
      }],
    },
    {
      desc:      '`resources` does not contain the timeout value',
      resources: [{
        name:             'default',
        key:              'unset',
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          'unset',
        key:              'unset',
        source_interface: ['foo'],
      }],
    },
    {
      desc:      '`resources` contains -1 timeout value',
      resources: [{
        name:             'default',
        timeout:          -1,
        key:              'unset',
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          'unset',
        key:              'unset',
        source_interface: ['foo'],
      }],
    },
    {
      desc:      '`resources` contains -1 values',
      resources: [{
        name:             'default',
        timeout:          -1,
        key:              'unset',
        source_interface: ['foo'],
      }],
      results:   [{
        name:             'default',
        timeout:          'unset',
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
