require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::DomainName')
require 'puppet/provider/domain_name/cisco_nexus'

RSpec.describe Puppet::Provider::DomainName::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:domain) { instance_double('Cisco::DomainName', 'domain') }
  let(:domain2) { instance_double('Cisco::DomainName', 'domain2') }
  let(:domain3) { instance_double('Cisco::DomainName', 'domain3') }
  let(:domainnames) do
    {
      'test.puppet.com'    => domain,
      'example.puppet.com' => domain2,
      'nexus.puppet.com'   => domain3,
    }
  end

  describe '#get(_context)' do
    it 'processes resources' do
      allow(Cisco::DomainName).to receive(:domainnames).and_return(domainnames)

      expect(provider.get(context)).to eq [
        {
          name:   'test.puppet.com',
          ensure: 'present',
        },
        {
          name:   'example.puppet.com',
          ensure: 'present',
        },
        {
          name:   'nexus.puppet.com',
          ensure: 'present',
        },
      ]
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::DomainName).to receive(:domainnames).and_return(domainnames)
        expect(provider.get(context, ['www.foo.com'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::DomainName).to receive(:domainnames).and_return(domainnames)
        expect(provider.get(context, ['example.puppet.com'])).to eq [
          {
            name:   'example.puppet.com',
            ensure: 'present',
          }
        ]
      end
    end
  end

  describe '#create(_context, name, _should)' do
    it 'creates the resource' do
      expect(Cisco::DomainName).to receive(:new).with('test.puppet.com')

      provider.create(context, 'test.puppet.com', name: 'test.puppet.com', ensure: 'present')
    end
  end

  describe '#delete(context, name)' do
    it 'deletes the resource' do
      expect(Cisco::DomainName).to receive(:domainnames).and_return(domainnames)
      expect(domainnames['test.puppet.com']).not_to receive(:destroy)
      expect(domainnames['example.puppet.com']).to receive(:destroy)
      expect(domainnames['nexus.puppet.com']).not_to receive(:destroy)

      provider.delete(context, 'example.puppet.com')
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
