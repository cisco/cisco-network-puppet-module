require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::PortChannel')
require 'puppet/provider/port_channel/cisco_nexus'

RSpec.describe Puppet::Provider::PortChannel::CiscoNexus do
  let(:provider) { described_class.new }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:interfaces) do
    {
      'ethernet1/1' => interface1,
      'ethernet1/2' => interface2,
    }
  end
  let(:interface1) { instance_double('Cisco::InterfaceChannelGroup', 'interface1') }
  let(:interface2) { instance_double('Cisco::InterfaceChannelGroup', 'interface2') }
  let(:portchannelinterfaces) do
    {
      'port-channel42' => portchannel42,
      'port-channel43' => portchannel43,
    }
  end
  let(:portchannel42) { instance_double('Cisco::InterfacePortChannel', 'portchannel42') }
  let(:portchannel43) { instance_double('Cisco::InterfacePortChannel', 'portchannel43') }
  let(:should_hash) do
    {
      name:          'port-channel42',
      minimum_links: 24,
      id:            42,
      interfaces:    ['ethernet1/1', 'ethernet1/2'],
      ensure:        'present',
    }
  end

  describe '#get(_context)' do
    context 'when there are no port channel interfaces' do
      let(:interfaces) { {} }
      let(:portchannelinterfaces) { {} }
      let(:state) { [] }

      it 'returns nothing' do
        allow(Cisco::InterfaceChannelGroup).to receive(:interfaces).and_return(interfaces)
        allow(Cisco::InterfacePortChannel).to receive(:interfaces).and_return(portchannelinterfaces)
        expect(provider.get(context)).to eq(state)
      end
    end

    before(:each) do
      allow(interface1).to receive(:channel_group).and_return(42).twice
      allow(interface2).to receive(:channel_group).and_return(42).twice
    end

    context 'when there are portchannels' do
      let(:state) do
        [
          {
            name:          'port-channel42',
            minimum_links: 24,
            id:            42,
            interfaces:    ['ethernet1/1', 'ethernet1/2'],
            ensure:        'present',
          },
          {
            name:          'port-channel43',
            minimum_links: 25,
            id:            43,
            ensure:        'present',
          },
        ]
      end

      it 'correctly returns the portchannels' do
        allow(Cisco::InterfaceChannelGroup).to receive(:interfaces).and_return(interfaces)
        allow(Cisco::InterfacePortChannel).to receive(:interfaces).and_return(portchannelinterfaces)
        expect(portchannel42).to receive(:lacp_min_links).and_return(24)
        expect(portchannel43).to receive(:lacp_min_links).and_return(25)

        expect(provider.get(context)).to eq(state)
      end
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::InterfaceChannelGroup).to receive(:interfaces).and_return(interfaces)
        allow(Cisco::InterfacePortChannel).to receive(:interfaces).and_return(portchannelinterfaces)
        expect(provider.get(context, ['port-channel4'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::InterfaceChannelGroup).to receive(:interfaces).and_return(interfaces)
        allow(Cisco::InterfacePortChannel).to receive(:interfaces).and_return(portchannelinterfaces)
        expect(portchannel43).to receive(:lacp_min_links).and_return(25)
        expect(provider.get(context, ['port-channel43'])).to eq [
          {
            name:          'port-channel43',
            minimum_links: 25,
            id:            43,
            ensure:        'present',
          }
        ]
      end
    end
  end

  describe '#create(context, name, should)' do
    context 'calls create_update' do
      it 'calls create_update with create true' do
        expect(provider).to receive(:create_update).with('port-channel42', should_hash, true)
        expect(context).to receive(:notice).with("Creating 'port-channel42' with #{should_hash.inspect}")
        provider.create(context, 'port-channel42', should_hash)
      end
    end
    context 'calls create_update' do
      it 'calls create_update with create false' do
        expect(provider).to receive(:create_update).with('port-channel42', should_hash, false)
        expect(context).to receive(:notice).with("Updating 'port-channel42' with #{should_hash.inspect}")
        provider.update(context, 'port-channel42', should_hash)
      end
    end
  end

  describe '#delete(context, name)' do
    context 'calls destroy' do
      it 'calls destroy' do
        expect(Cisco::InterfacePortChannel).to receive(:new).with('port-channel42', false).and_return(portchannel42)
        expect(portchannel42).to receive(:destroy)
        expect(context).to receive(:notice).with("Deleting 'port-channel42'")
        provider.delete(context, 'port-channel42')
      end
    end
  end

  describe '#create_update(name, should, create_bool)' do
    context 'create_update true with minimum_links and interfaces' do
      it 'create_update makes appropriate calls' do
        expect(Cisco::InterfacePortChannel).to receive(:new).with('port-channel42', true).and_return(portchannel42)
        expect(portchannel42).to receive(:lacp_min_links=).with(24)
        expect(Cisco::InterfaceChannelGroup).to receive(:interfaces).and_return(interfaces).twice
        expect(interface1).to receive(:channel_group_mode_set).with(42)
        expect(interface2).to receive(:channel_group_mode_set).with(42)
        provider.create_update('port-channel42', should_hash, true)
      end
    end

    context 'create_update false with basic portchannel' do
      let(:should_hash) do
        {
          name:       'port-channel42',
          id:         42,
          interfaces: [],
          ensure:     'present',
        }
      end

      it 'create_update makes appropriate calls' do
        expect(Cisco::InterfacePortChannel).to receive(:new).with('port-channel42', false).and_return(portchannel42)
        provider.create_update('port-channel42', should_hash, false)
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
