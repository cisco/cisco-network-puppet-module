require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::SearchDomain')
require 'puppet/provider/search_domain/cisco_nexus'

RSpec.describe Puppet::Provider::SearchDomain::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:domainname) { instance_double('Cisco::DomainName', 'domainname') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::DomainName).to receive(:domainnames).and_return({})
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        expect(provider.get(context)).to eq []
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        allow(Cisco::DomainName).to receive(:domainnames).and_return('foo.bar.com' => domainname)
        expect(provider.get(context)).to eq [
          {
            name:   'foo.bar.com',
            ensure: 'present',
          }
        ]
      end
    end
    context 'with multiple domain searches' do
      it 'still processes' do
        allow(Cisco::DomainName).to receive(:domainnames).and_return('foo.bar.com'  => domainname,
                                                                     'fizz.bar.com' => domainname)
        expect(provider.get(context)).to eq [
          {
            name:   'foo.bar.com',
            ensure: 'present',
          },
          {
            name:   'fizz.bar.com',
            ensure: 'present',
          }
        ]
      end
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::DomainName).to receive(:domainnames).and_return('foo.bar.com'  => domainname,
                                                                     'fizz.bar.com' => domainname)
        expect(provider.get(context, ['bar.fizz.com'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::DomainName).to receive(:domainnames).and_return('foo.bar.com'  => domainname,
                                                                     'fizz.bar.com' => domainname)

        allow(domainname).to receive(:name).and_return('fizz.bar.com')
        expect(provider.get(context, ['fizz.bar.com'])).to eq [
          {
            name:   'fizz.bar.com',
            ensure: 'present',
          }
        ]
      end
    end
  end

  describe '#create' do
    context 'create is called with all values' do
      let(:should_values) do
        {
          name:   'foo.bar.com',
          ensure: 'present',
        }
      end

      it 'creates the domain' do
        expect(context).to receive(:notice).with(%r{\ACreating 'foo.bar.com'})
        expect(Cisco::DomainName).to receive(:new).with('foo.bar.com')
        provider.create(context, 'foo.bar.com', should_values)
      end
    end
  end

  describe '#delete' do
    context 'delete is called' do
      it 'destroys the domain name' do
        expect(context).to receive(:notice).with(%r{\ADestroying 'foo.bar.com'})
        allow(Cisco::DomainName).to receive(:domainnames).and_return('foo.bar.com'  => domainname,
                                                                     'fizz.bar.com' => domainname)
        expect(domainname).to receive(:destroy).once
        provider.delete(context, 'foo.bar.com')
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
