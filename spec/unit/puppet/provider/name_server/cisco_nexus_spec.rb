require 'spec_helper'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::NameServer')
require 'puppet/provider/name_server/cisco_nexus'

RSpec.describe Puppet::Provider::NameServer::CiscoNexus do
  subject(:provider) { described_class.new }

  name_server_ips = ['1.2.3.4', '4.3.2.1', '8.8.8.8']

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:nameserver) { instance_double('Cisco::NameServer', 'nameserver') }

  let(:nameservers) do
    nameservers_hash = {}
    name_server_ips.each do |name_server|
      nameservers_hash["#{name_server}"] = nameserver
    end
    nameservers_hash
  end

  describe '#get' do
    it 'gets resources' do
      allow(Cisco::NameServer).to receive(:nameservers).and_return(nameservers)

      expect_array = []
      name_server_ips.each do |name_server|
        new_name_hash = { name: name_server, ensure: 'present' }
        expect_array << new_name_hash
      end
      expect(provider.get(context)).to eq expect_array
    end
  end

  describe 'create(_context, name, _should)' do
    it 'creates the resource' do
      name_server_ips.each do |name_server|
        expect(context).to receive :notice
        expect(Cisco::NameServer).to receive(:new).with(name_server)
        provider.create(context, name_server, name: name_server, ensure: 'present')
      end
    end
  end
  describe 'delete(context, name)' do
    name_server_ips.each do |name_server_name|
      it 'deletes the resource' do
        expect(context).to receive :notice
        expect(Cisco::NameServer).to receive(:nameservers).and_return(nameservers)
        expect(nameserver).to receive(:destroy)
        provider.delete(context, name_server_name)
      end
    end
  end
end
