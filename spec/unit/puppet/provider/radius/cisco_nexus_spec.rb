require 'spec_helper'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::Radius')
require 'puppet/provider/radius/cisco_nexus'

RSpec.describe Puppet::Provider::Radius::CiscoNexus do
  let(:provider) { described_class.new }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
  end

  describe '#get(context)' do
    it 'processes resources' do
      expect(provider.get(context)).to eq [
        {
          name: 'default',
        },
      ]
    end
  end

  # Radius does not do anything apart from call a context message
  describe '#update(context, name, should)' do
    it 'updates the resource - no op - notice' do
      expect(context).to receive(:notice).with(%r{No operation in updating 'default' with }).once
      provider.update(context, 'default', '')
    end
  end

  describe '#create(context, name, should)' do
    it 'creates the resource - no op - notice' do
      expect(context).to receive(:notice).with(%r{No operation in creating 'default' with }).once
      provider.create(context, 'default', '')
    end
  end

  describe '#delete(context, name)' do
    it 'deletes the resource - no op - notice' do
      expect(context).to receive(:notice).with(%r{No operation in deleting 'default'}).once
      provider.delete(context, 'default')
    end
  end
end
