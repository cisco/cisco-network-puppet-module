require 'spec_helper'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::NetworkTrunk')
require 'puppet/provider/network_trunk/cisco_nexus'

RSpec.describe Puppet::Provider::NetworkTrunk::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:interface) { instance_double('Cisco::Interface', 'interface') }
  let(:non_trunk) { instance_double('Cisco::Interface', 'non_trunk') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::Interface).to receive(:interfaces).and_return({})
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        expect(provider.get(context)).to eq []
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        allow(Cisco::Interface).to receive(:interfaces).and_return('ethernet1' => interface)
        allow(interface).to receive(:send).with(:switchport_mode).and_return(:trunk)
        allow(interface).to receive(:send).with(:switchport_trunk_allowed_vlan).and_return('2-3,6-10')
        allow(interface).to receive(:send).with(:switchport_trunk_native_vlan).and_return(1)

        expect(provider.get(context)).to eq [
          {
            ensure:        'present',
            mode:          'trunk',
            name:          'ethernet1',
            tagged_vlans:  ['2', '3', '6', '7', '8', '9', '10'],
            untagged_vlan: 1,
          }
        ]
      end
    end
    context 'with non `trunk` interface' do
      it 'still processes' do
        allow(Cisco::Interface).to receive(:interfaces).and_return('ethernet1' => interface,
                                                                   'ethernet2' => non_trunk)
        allow(interface).to receive(:send).with(:switchport_mode).and_return(:trunk)
        allow(non_trunk).to receive(:send).with(:switchport_mode).and_return(:access)
        allow(interface).to receive(:send).with(:switchport_trunk_allowed_vlan).and_return('2-3,6-10')
        allow(interface).to receive(:send).with(:switchport_trunk_native_vlan).and_return(1)

        expect(provider.get(context)).to eq [
          {
            ensure:        'present',
            mode:          'trunk',
            name:          'ethernet1',
            tagged_vlans:  ['2', '3', '6', '7', '8', '9', '10'],
            untagged_vlan: 1,
          }
        ]
      end
    end
    context 'with multiple `trunk` interface' do
      it 'still processes' do
        allow(Cisco::Interface).to receive(:interfaces).and_return('ethernet1' => interface,
                                                                   'ethernet2' => non_trunk,
                                                                   'ethernet3' => interface)
        allow(interface).to receive(:send).with(:switchport_mode).and_return(:trunk)
        allow(non_trunk).to receive(:send).with(:switchport_mode).and_return(:access)
        allow(interface).to receive(:send).with(:switchport_trunk_allowed_vlan).and_return('2-3,6-10')
        allow(interface).to receive(:send).with(:switchport_trunk_native_vlan).and_return(1)

        expect(provider.get(context)).to eq [
          {
            ensure:        'present',
            mode:          'trunk',
            name:          'ethernet1',
            tagged_vlans:  ['2', '3', '6', '7', '8', '9', '10'],
            untagged_vlan: 1,
          },
          {
            ensure:        'present',
            mode:          'trunk',
            name:          'ethernet3',
            tagged_vlans:  ['2', '3', '6', '7', '8', '9', '10'],
            untagged_vlan: 1,
          }
        ]
      end
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::Interface).to receive(:interfaces).and_return('ethernet1' => interface,
                                                                   'ethernet2' => non_trunk)
        allow(interface).to receive(:send).with(:switchport_mode).and_return(:access)
        allow(non_trunk).to receive(:send).with(:switchport_mode).and_return(:access)
        allow(interface).to receive(:send).with(:switchport_trunk_allowed_vlan).and_return('2-3,6-10')
        allow(interface).to receive(:send).with(:switchport_trunk_native_vlan).and_return(1)

        expect(provider.get(context, ['ethernet1'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::Interface).to receive(:interfaces).and_return('ethernet1'  => interface,
                                                                   'ethernet2'  => non_trunk,
                                                                   'ethernet23' => non_trunk)
        allow(interface).to receive(:send).with(:switchport_mode).and_return(:trunk)
        allow(non_trunk).to receive(:send).with(:switchport_mode).and_return(:trunk)
        allow(interface).to receive(:send).with(:switchport_trunk_allowed_vlan).and_return('2-3,6-10')
        allow(interface).to receive(:send).with(:switchport_trunk_native_vlan).and_return(1)

        expect(provider.get(context, ['ethernet1'])).to eq [
          {
            ensure:        'present',
            mode:          'trunk',
            name:          'ethernet1',
            tagged_vlans:  ['2', '3', '6', '7', '8', '9', '10'],
            untagged_vlan: 1,
          }
        ]
      end
    end
  end

  describe '#update' do
    context 'update is called' do
      let(:should_values) do
        {
          name:          'ethernet1',
          ensure:        'present',
          mode:          'trunk',
          tagged_vlans:  ['2', '3', '4', '6', '7', '8'],
          untagged_vlan: 1,
        }
      end

      it 'performs an update' do
        expect(context).to receive(:notice).with(%r{\AUpdating 'ethernet1'})
        allow(Cisco::Interface).to receive(:interfaces).and_return('ethernet1'  => interface,
                                                                   'ethernet2'  => non_trunk,
                                                                   'ethernet23' => non_trunk)
        allow(interface).to receive(:switchport_mode=).with(:trunk).and_return(interface)
        allow(interface).to receive(:switchport_trunk_allowed_vlan=).with('2-4,6-8').and_return(interface)
        allow(interface).to receive(:switchport_trunk_native_vlan=).with(1).and_return(interface)

        provider.update(context, 'ethernet1', should_values)
      end
    end
  end

  describe '#create' do
    context 'create is called' do
      let(:should_values) do
        {
          name:          'ethernet1',
          ensure:        'present',
          mode:          'trunk',
          tagged_vlans:  ['2', '3', '4', '6', '7', '8'],
          untagged_vlan: 1,
        }
      end

      it 'creates an interface' do
        expect(context).to receive(:notice).with(%r{\AUpdating 'ethernet1'})
        allow(Cisco::Interface).to receive(:new).with('ethernet1')
        allow(Cisco::Interface).to receive(:interfaces).and_return('ethernet1'  => interface,
                                                                   'ethernet2'  => non_trunk,
                                                                   'ethernet23' => non_trunk)
        allow(interface).to receive(:switchport_mode=).with(:trunk).and_return(interface)
        allow(interface).to receive(:switchport_trunk_allowed_vlan=).with('2-4,6-8').and_return(interface)
        allow(interface).to receive(:switchport_trunk_native_vlan=).with(1).and_return(interface)

        provider.create(context, 'ethernet1', should_values)
      end
    end
  end

  describe '#delete' do
    context 'delete is called' do
      it 'destroys an interface' do
        expect(context).to receive(:notice).with(%r{\ADestroying 'ethernet1'})
        allow(Cisco::Interface).to receive(:interfaces).and_return('ethernet1'  => interface,
                                                                   'ethernet2'  => non_trunk,
                                                                   'ethernet23' => non_trunk)
        expect(interface).to receive(:destroy).and_return(interface).once
        expect(non_trunk).to receive(:destroy).and_return(interface).never

        provider.delete(context, 'ethernet1')
      end
    end
  end

  describe '#convert_allowed_vlan_to_array' do
    context 'solo range is entered' do
      it 'returns an ordered array' do
        expect(provider.convert_allowed_vlan_to_array('1-6')).to eq ['1', '2', '3', '4', '5', '6']
      end
    end
    context 'multi separate ranges are entered' do
      it 'returns an ordered array' do
        expect(provider.convert_allowed_vlan_to_array('1-3,6-9')).to eq ['1', '2', '3', '6', '7', '8', '9']
      end
    end
    context 'range with extra entry' do
      it 'returns an ordered array' do
        expect(provider.convert_allowed_vlan_to_array('1-3,10')).to eq ['1', '2', '3', '10']
      end
    end
  end

  describe '#convert_array_to_allowed_vlan' do
    context 'empty array is entered' do
      it 'returns nil' do
        expect(provider.convert_array_to_allowed_vlan([])).to eq nil
      end
    end
    context 'array without ranges' do
      it 'returns CSV list' do
        expect(provider.convert_array_to_allowed_vlan(['1', '3', '5'])).to eq '1,3,5'
      end
    end
    context 'array with ranges' do
      it 'returns ranged list' do
        expect(provider.convert_array_to_allowed_vlan(['1', '2', '3', '4', '5'])).to eq '1-5'
      end
    end
    context 'array with separate ranges' do
      it 'returns ranged list' do
        expect(provider.convert_array_to_allowed_vlan(['1', '2', '3', '4', '5', '8', '9', '10'])).to eq '1-5,8-10'
      end
    end
    context 'array with mixture of ranges and single values' do
      it 'returns ranged list' do
        expect(provider.convert_array_to_allowed_vlan(['1', '2', '3', '5', '8', '9', '10'])).to eq '1-3,5,8-10'
      end
    end
  end

  canonicalize_data = [
    {
      desc:      '`resources` already sorted',
      resources: [{
        name:         'ethernet1',
        ensure:       'present',
        tagged_vlans: ['1', '2', '3', '10'],
      }],
      results:   [{
        name:         'ethernet1',
        ensure:       'present',
        tagged_vlans: ['1', '2', '3', '10'],
      }],
    },
    {
      desc:      '`resources` requires sorting',
      resources: [{
        name:         'ethernet1',
        ensure:       'present',
        tagged_vlans: ['10', '2', '3', '1'],
      }],
      results:   [{
        name:         'ethernet1',
        ensure:       'present',
        tagged_vlans: ['1', '2', '3', '10'],
      }],
    },
    {
      desc:      '`resources` does not contain `tagged_vlans`',
      resources: [{
        name:   'ethernet1',
        ensure: 'present',
      }],
      results:   [{
        name:   'ethernet1',
        ensure: 'present',
      }],
    },
  ]

  describe '#canonicalize' do
    canonicalize_data.each do |test|
      context "#{test[:desc]}" do
        it 'returns canonicalized resource' do
          expect(provider.canonicalize(context, test[:resources])).to eq(test[:results])
        end
      end
    end
  end

  describe '#validate_should' do
    context 'invalid modes entered' do
      it { expect { provider.validate_should(mode: 'dynamic_auto') }.to raise_error Puppet::ResourceError, 'The mode `dynamic_auto` is not supported' }
      it { expect { provider.validate_should(mode: 'dynamic_desirable') }.to raise_error Puppet::ResourceError, 'The mode `dynamic_desirable` is not supported' }
      it { expect { provider.validate_should(mode: 'foo') }.to raise_error Puppet::ResourceError, 'The mode `foo` is not supported' }
      it { expect { provider.validate_should(mode: '') }.to raise_error Puppet::ResourceError, 'The mode `` is not supported' }
    end
    context 'valid modes entered' do
      it { expect { provider.validate_should(mode: 'access') }.not_to raise_error }
      it { expect { provider.validate_should(mode: 'trunk') }.not_to raise_error }
    end
    context 'encapsulation key entered/present' do
      it { expect { provider.validate_should(encapsulation: 'negotiate') }.to raise_error Puppet::ResourceError, 'VLAN-Tagging encapsulation is not supported on this device' }
      it { expect { provider.validate_should(encapsulation: 'dot1q') }.to raise_error Puppet::ResourceError, 'VLAN-Tagging encapsulation is not supported on this device' }
      it { expect { provider.validate_should(encapsulation: 'isl') }.to raise_error Puppet::ResourceError, 'VLAN-Tagging encapsulation is not supported on this device' }
      it { expect { provider.validate_should(encapsulation: '') }.to raise_error Puppet::ResourceError, 'VLAN-Tagging encapsulation is not supported on this device' }
    end
    context 'pruned_vlans key entered/present' do
      it { expect { provider.validate_should(pruned_vlans: ['1', '2']) }.to raise_error Puppet::ResourceError, 'VLAN pruning is not supported on this device' }
      it { expect { provider.validate_should(pruned_vlans: []) }.to raise_error Puppet::ResourceError, 'VLAN pruning is not supported on this device' }
      it { expect { provider.validate_should(pruned_vlans: '') }.to raise_error Puppet::ResourceError, 'VLAN pruning is not supported on this device' }
    end
    context 'valid should' do
      let(:should_values) do
        {
          name:          'ethernet1',
          ensure:        'present',
          mode:          'trunk',
          tagged_vlans:  ['2', '3', '4', '6', '7', '8'],
          untagged_vlan: 1,
        }
      end

      it { expect { provider.validate_should(should_values) }.not_to raise_error }
    end
  end
end
