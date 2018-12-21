require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::Radius')
require 'puppet/provider/radius/cisco_nexus'

RSpec.describe Puppet::Provider::Radius::CiscoNexus do
  subject(:provider) { described_class.new }

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

  describe '#set' do
    it 'reports no-op for this provider' do
      expect(context).to receive(:notice).with("No operations for managing 'radius', use 'radius_global'").once
      provider.set(context, anything)
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
