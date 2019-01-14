require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::NetworkInterface')
require 'puppet/provider/network_interface/cisco_nexus'

RSpec.describe Puppet::Provider::NetworkInterface::CiscoNexus do
  let(:provider) { described_class.new }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:interfaces) do
    {
      'ethernet1/1' => interface1,
      'ethernet1/2' => interface2,
    }
  end
  let(:interface1) { instance_double('Cisco::Interface', 'interface1') }
  let(:interface2) { instance_double('Cisco::Interface', 'interface2') }

  describe '#get(_context)' do
    context 'when there are no interfaces' do
      let(:interfaces) { {} }
      let(:state) { [] }

      it 'returns nothing' do
        allow(Cisco::Interface).to receive(:interfaces).and_return(interfaces)
        expect(provider.get(context)).to eq(state)
      end
    end
    context 'when there are interfaces' do
      let(:state) do
        [
          {
            name:        'ethernet1/1',
            description: 'eth1/desc',
            mtu:         123,
            speed:       '1g',
            duplex:      'full',
            enable:      true,
          },
          {
            name:        'ethernet1/2',
            description: 'eth2/desc',
            mtu:         321,
            speed:       '40g',
            duplex:      'half',
            enable:      false,
          },
        ]
      end

      it 'correctly returns the interfaces' do
        allow(Cisco::Interface).to receive(:interfaces).and_return(interfaces)

        expect(interface1).to receive(:description).and_return('eth1/desc')
        expect(interface1).to receive(:mtu).and_return(123)
        expect(interface1).to receive(:speed).and_return(1000)
        expect(interface1).to receive(:duplex).and_return('full')
        expect(interface1).to receive(:shutdown).and_return(false)

        expect(interface2).to receive(:description).and_return('eth2/desc')
        expect(interface2).to receive(:mtu).and_return(321)
        expect(interface2).to receive(:speed).and_return(40_000)
        expect(interface2).to receive(:duplex).and_return('half')
        expect(interface2).to receive(:shutdown).and_return(true)

        expect(provider.get(context)).to eq(state)
      end
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::Interface).to receive(:interfaces).and_return(interfaces)
        expect(provider.get(context, ['ethernet1/3'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::Interface).to receive(:interfaces).and_return(interfaces)
        expect(interface2).to receive(:description).and_return('eth2/desc')
        expect(interface2).to receive(:mtu).and_return(321)
        expect(interface2).to receive(:speed).and_return(40_000)
        expect(interface2).to receive(:duplex).and_return('half')
        expect(interface2).to receive(:shutdown).and_return(true)
        expect(provider.get(context, ['ethernet1/2'])).to eq [
          {
            name:        'ethernet1/2',
            description: 'eth2/desc',
            mtu:         321,
            speed:       '40g',
            duplex:      'half',
            enable:      false,
          }
        ]
      end
    end
  end

  describe '#set(context, changes)' do
    let(:changes) do
      {
        'ethernet1/3' => {
          is:     is,
          should: should_hash,
        }
      }
    end

    context 'when there are no changes to be made' do
      let(:is) do
        {
          name:        'ethernet1/3',
          description: 'eth3/desc',
          mtu:         123,
          speed:       '1g',
          duplex:      'full',
          enable:      true,
        }
      end
      let(:should_hash) { is }

      it 'does not call update' do
        expect(provider).not_to receive(:update)
        provider.set(context, changes)
      end
    end
    context 'when there are changes to be made' do
      let(:is) do
        {
          name:        'ethernet1/3',
          description: 'eth1/desc',
          mtu:         123,
          speed:       '1g',
          duplex:      'full',
          enable:      true,
        }
      end
      let(:should_hash) do
        {
          name:        'ethernet1/3',
          description: 'eth1/desc',
          mtu:         123,
          speed:       '1g',
          duplex:      'full',
          enable:      false,
        }
      end

      it 'calls update with the changes' do
        expect(provider).to receive(:update).with(context, 'ethernet1/3', changes['ethernet1/3'][:should]).once

        provider.set(context, changes)
      end
    end
  end

  describe '#update(context, name, should)' do
    let(:if_name) { 'ethernet1/2' }

    before(:each) do
      allow(Cisco::Interface).to receive(:interfaces).and_return(interfaces)
    end

    context 'when enable is false' do
      let(:should_hash) do
        {
          name:   if_name,
          enable: false,
        }
      end

      it {
        expect(interface2).to receive(:shutdown=).with(true)
        provider.update(context, if_name, should_hash)
      }
    end

    context 'when enable is true' do
      let(:should_hash) do
        {
          name:   if_name,
          enable: true,
        }
      end

      it {
        expect(interface2).to receive(:shutdown=).with(false)
        provider.update(context, if_name, should_hash)
      }
    end

    context 'when mtu is present' do
      let(:should_hash) do
        {
          name: if_name,
          mtu:  123,
        }
      end

      it {
        expect(interface2).to receive(:mtu=).with(123)
        provider.update(context, if_name, should_hash)
      }
    end

    context 'when description is present' do
      let(:should_hash) do
        {
          name:        if_name,
          description: 'desc',
        }
      end

      it {
        expect(interface2).to receive(:description=).with('desc')
        provider.update(context, if_name, should_hash)
      }
    end

    context 'when speed is present' do
      let(:should_hash) do
        {
          name:  if_name,
          speed: '10g',
        }
      end

      it {
        expect(interface2).to receive(:speed=).with(10_000)
        provider.update(context, if_name, should_hash)
      }
    end

    context 'when duplex is present' do
      let(:should_hash) do
        {
          name:   if_name,
          duplex: 'full',
        }
      end

      it {
        expect(interface2).to receive(:duplex=).with('full')
        provider.update(context, if_name, should_hash)
      }
    end
  end

  describe '#convert_type_to_speed(type)' do
    it {
      expect(provider.convert_type_to_speed('100m')).to eq 100
    }
    it {
      expect(provider.convert_type_to_speed('1g')).to eq 1000
    }
    it {
      expect(provider.convert_type_to_speed('10g')).to eq 10_000
    }
    it {
      expect(provider.convert_type_to_speed('40g')).to eq 40_000
    }
    it {
      expect(provider.convert_type_to_speed('100g')).to eq 100_000
    }
    it {
      expect(provider.convert_type_to_speed('something')).to eq 'something'
    }
  end

  describe '#convert_speed_to_type(speed)' do
    it {
      expect(provider.convert_speed_to_type(100)).to eq '100m'
    }
    it {
      expect(provider.convert_speed_to_type(1000)).to eq '1g'
    }
    it {
      expect(provider.convert_speed_to_type(10_000)).to eq '10g'
    }
    it {
      expect(provider.convert_speed_to_type(40_000)).to eq '40g'
    }
    it {
      expect(provider.convert_speed_to_type(100_000)).to eq '100g'
    }
    it {
      expect(provider.convert_speed_to_type('something')).to eq 'something'
    }
  end

  it_behaves_like 'a noop canonicalizer'
end
