require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::Banner')
require 'puppet/provider/banner/cisco_nexus'

RSpec.describe Puppet::Provider::Banner::CiscoNexus do
  let(:provider) { described_class.new }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:banner) { instance_double('Cisco::Banner', 'banner') }
  let(:changes) do
    {
      'default' =>
                   {
                     is:     {
                       name: 'default',
                       motd: 'This is a new MOTD.'
                     },
                     should: should_values
                   }
    }
  end

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::Banner).to receive(:new).with('default').and_return(banner).once
  end

  describe '#set(context, changes)' do
    context 'there are changes' do
      let(:should_values) do
        {
          name: 'default',
          motd: 'This is the newest MOTD.'
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
          name: 'default',
          motd: 'This is a new MOTD.'
        }
      end

      it 'will not call update' do
        expect(provider).to receive(:update).with(context, 'default', changes['default'][:should]).never

        provider.set(context, changes)
      end
    end
  end

  describe '#get(context)' do
    it 'processes resources' do
      allow(banner).to receive(:motd).and_return('some motd')

      expect(provider.get(context)).to eq [
        {
          name: 'default',
          motd: 'some motd',
        },
      ]
    end
  end

  describe '#update(context, name, should)' do
    it 'updates the resource' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'default'}).once
      expect(banner).to receive(:motd=).with('new motd').once
      expect(Cisco::Banner).to receive(:new).with('default').once
      expect(provider).to receive(:validate_name).with('default').once

      provider.update(context, 'default', motd: 'new motd')
    end
  end

  describe '#validate_name(name)' do
    context '`name` is `default`' do
      it { expect { provider.validate_name('default') }.not_to raise_error }
    end
    context '`name` is not `default`' do
      it { expect { provider.validate_name('not `default`') }.to raise_error Puppet::ResourceError, %r{`name` must be `default`} }
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
