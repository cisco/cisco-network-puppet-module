require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::NameServer')
require 'puppet/provider/name_server/cisco_nexus'

RSpec.describe Puppet::Provider::NameServer::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:nameserver1) { instance_double('Cisco::NameServer', 'nameserver1') }
  let(:nameserver2) { instance_double('Cisco::NameServer', 'nameserver2') }
  let(:nameserver_rtn) do
    {
      '1.2.3.4' => nameserver1,
      '4.3.2.1' => nameserver2
    }
  end

  describe '#get' do
    it 'gets resources' do
      allow(Cisco::NameServer).to receive(:nameservers).and_return(nameserver_rtn)
      expect(provider.get(context)).to eq [
        {
          name:   '1.2.3.4',
          ensure: 'present',
        },
        {
          name:   '4.3.2.1',
          ensure: 'present',
        },
      ]
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::NameServer).to receive(:nameservers).and_return(nameserver_rtn)
        expect(provider.get(context, ['2.2.2.2'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::NameServer).to receive(:nameservers).and_return(nameserver_rtn)
        expect(provider.get(context, ['1.2.3.4'])).to eq [
          {
            name:   '1.2.3.4',
            ensure: 'present',
          }
        ]
      end
    end
  end

  describe 'create(_context, name, _should)' do
    it 'creates the resource' do
      expect(context).to receive :notice
      expect(Cisco::NameServer).to receive(:new).with('1.1.1.1')
      provider.create(context, '1.1.1.1', name: '1.1.1.1', ensure: 'present')
    end
  end
  describe 'delete(context, name)' do
    it 'deletes the resource' do
      expect(context).to receive :notice
      expect(Cisco::NameServer).to receive(:nameservers).and_return(nameserver_rtn)
      expect(nameserver1).not_to receive(:destroy)
      expect(nameserver2).to receive(:destroy)
      provider.delete(context, '4.3.2.1')
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
