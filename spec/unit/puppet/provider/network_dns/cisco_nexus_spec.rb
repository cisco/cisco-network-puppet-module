require 'spec_helper'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::NetworkDns')
require 'puppet/provider/network_dns/cisco_nexus'

RSpec.describe Puppet::Provider::NetworkDns::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:domain) { instance_double('Cisco::DomainName', 'domain') }
  let(:searches) { instance_double('Cisco::DnsDomain', 'searches') }
  let(:servers) { instance_double('Cisco::NameServer', 'servers') }
  let(:hostname) { instance_double('Cisco::HostName', 'hostname') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::DomainName).to receive(:domainnames).and_return({})
    allow(Cisco::DnsDomain).to receive(:dnsdomains).and_return({})
    allow(Cisco::NameServer).to receive(:nameservers).and_return({})
    allow(Cisco::HostName).to receive(:hostname).and_return({})
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        expect(provider.get(context)).to eq [
          {
            name:     'settings',
            ensure:   'present',
            domain:   nil,
            hostname: nil,
            search:   [],
            servers:  [],
          }
        ]
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        allow(Cisco::DomainName).to receive(:domainnames).and_return('foo' => {})
        allow(Cisco::DnsDomain).to receive(:dnsdomains).and_return('foo' => {}, 'bar' => {})
        allow(Cisco::NameServer).to receive(:nameservers).and_return('moo' => {}, 'wow' => {})
        allow(Cisco::HostName).to receive(:hostname).and_return('bar' => {})

        expect(provider.get(context)).to eq [
          {
            name:     'settings',
            ensure:   'present',
            domain:   'foo',
            hostname: 'bar',
            search:   ['bar', 'foo'],
            servers:  ['moo', 'wow'],
          }
        ]
      end
    end
  end

  describe '#update' do
    context 'update is called' do
      let(:should_values) do
        {
          name:     'settings',
          ensure:   'present',
          domain:   'foo',
          hostname: 'bar',
          search:   ['1.1.1.1'],
          servers:  ['2.2.2.2'],
        }
      end

      it 'performs an update' do
        expect(Cisco::DomainName).to receive(:new).with('foo')
        expect(Cisco::HostName).to receive(:new).with('bar')
        expect(Cisco::DnsDomain).to receive(:new).with('1.1.1.1')
        expect(Cisco::NameServer).to receive(:new).with('2.2.2.2')
        expect(context).to receive(:notice).with(%r{\AUpdating 'settings'})
        provider.update(context, 'settings', should_values)
      end
    end
    context 'update is called without hostname' do
      let(:should_values) do
        {
          name:    'settings',
          ensure:  'present',
          domain:  'foo',
          search:  ['1.1.1.1'],
          servers: ['2.2.2.2'],
        }
      end

      it 'performs an update' do
        expect(Cisco::DomainName).to receive(:new).with('foo')
        expect(Cisco::HostName).to receive(:new).with('bar').never
        expect(Cisco::DnsDomain).to receive(:new).with('1.1.1.1')
        expect(Cisco::NameServer).to receive(:new).with('2.2.2.2')
        expect(context).to receive(:notice).with(%r{\AUpdating 'settings'})
        provider.update(context, 'settings', should_values)
      end
    end
    context 'update is called without domain' do
      let(:should_values) do
        {
          name:    'settings',
          ensure:  'present',
          search:  ['1.1.1.1'],
          servers: ['2.2.2.2'],
        }
      end

      it 'performs an update' do
        expect(Cisco::DomainName).to receive(:new).with('foo').never
        expect(Cisco::HostName).to receive(:new).with('bar').never
        expect(Cisco::DnsDomain).to receive(:new).with('1.1.1.1')
        expect(Cisco::NameServer).to receive(:new).with('2.2.2.2')
        expect(context).to receive(:notice).with(%r{\AUpdating 'settings'})
        provider.update(context, 'settings', should_values)
      end
    end
  end

  describe '#handle_servers' do
    context 'has to delete a value' do
      it 'calls destroy for that value' do
        allow(Cisco::NameServer).to receive(:nameservers).and_return('moo' => {}, 'wow' => {})
        expect(Cisco::NameServer.nameservers['moo']).to receive(:destroy)
        expect(Cisco::NameServer.nameservers['wow']).not_to receive(:destroy)
        expect(Cisco::NameServer).not_to receive(:new).with(anything)
        provider.handle_servers(['wow'])
      end
    end
    context 'has to create a value' do
      it 'calls new for that value' do
        allow(Cisco::NameServer).to receive(:nameservers).and_return('moo' => {}, 'wow' => {})
        expect(Cisco::NameServer.nameservers['moo']).not_to receive(:destroy)
        expect(Cisco::NameServer.nameservers['wow']).not_to receive(:destroy)
        expect(Cisco::NameServer).to receive(:new).with('foo')
        provider.handle_servers(['moo', 'wow', 'foo'])
      end
    end
    context 'has to delete all values' do
      it 'calls destory for those values' do
        allow(Cisco::NameServer).to receive(:nameservers).and_return('moo' => {}, 'wow' => {})
        expect(Cisco::NameServer.nameservers['moo']).to receive(:destroy)
        expect(Cisco::NameServer.nameservers['wow']).to receive(:destroy)
        expect(Cisco::NameServer).not_to receive(:new).with(anything)
        provider.handle_servers([])
      end
    end
  end

  describe '#handle_searches' do
    context 'has to delete a value' do
      it 'calls destroy for that value' do
        allow(Cisco::DnsDomain).to receive(:dnsdomains).and_return('foo' => {}, 'bar' => {})
        expect(Cisco::DnsDomain.dnsdomains['foo']).to receive(:destroy)
        expect(Cisco::DnsDomain.dnsdomains['bar']).not_to receive(:destroy)
        expect(Cisco::DnsDomain).not_to receive(:new).with(anything)
        provider.handle_searches(['bar'])
      end
    end
    context 'has to create a value' do
      it 'calls new for that value' do
        allow(Cisco::DnsDomain).to receive(:dnsdomains).and_return('foo' => {}, 'bar' => {})
        expect(Cisco::DnsDomain.dnsdomains['foo']).not_to receive(:destroy)
        expect(Cisco::DnsDomain.dnsdomains['bar']).not_to receive(:destroy)
        expect(Cisco::DnsDomain).to receive(:new).with('wow')
        provider.handle_searches(['foo', 'bar', 'wow'])
      end
    end
    context 'has to delete all values' do
      it 'calls destory for those values' do
        allow(Cisco::DnsDomain).to receive(:dnsdomains).and_return('foo' => {}, 'bar' => {})
        expect(Cisco::DnsDomain.dnsdomains['foo']).to receive(:destroy)
        expect(Cisco::DnsDomain.dnsdomains['bar']).to receive(:destroy)
        expect(Cisco::DnsDomain).not_to receive(:new).with(anything)
        provider.handle_searches([])
      end
    end
  end

  describe '#handle_hostname' do
    context 'empty string passed' do
      it 'calls destroy for the hostname values' do
        allow(Cisco::HostName).to receive(:hostname).and_return('foo' => hostname)
        expect(Cisco::HostName.hostname['foo']).to receive(:destroy)
        provider.handle_hostname('')
      end
    end
    context 'a valid string is passed' do
      it 'calls new' do
        allow(Cisco::HostName).to receive(:hostname).and_return('foo' => hostname)
        expect(Cisco::HostName.hostname['foo']).to receive(:destroy)
        expect(Cisco::HostName).to receive(:new).with('foo')
        provider.handle_hostname('foo')
      end
    end
  end

  describe '#handle_domain' do
    context 'empty string passed' do
      it 'calls destroy for the hostname values' do
        allow(Cisco::DomainName).to receive(:domainnames).and_return('foo' => domain)
        expect(Cisco::DomainName.domainnames['foo']).to receive(:destroy)
        provider.handle_domain('')
      end
    end
    context 'a valid string is passed' do
      it 'calls new' do
        allow(Cisco::DomainName).to receive(:domainnames).and_return('foo' => domain)
        expect(Cisco::DomainName.domainnames['foo']).to receive(:destroy)
        expect(Cisco::DomainName).to receive(:new).with('foo')
        provider.handle_domain('foo')
      end
    end
  end

  describe '#delete' do
    context 'delete is called' do
      it { expect { provider.delete(anything, anything) }.to raise_error Puppet::ResourceError, 'This provider does not support ensure => absent' }
    end
  end

  describe '#validate_name' do
    context '`name` is `settings`' do
      it { expect { provider.validate_name('settings') }.not_to raise_error }
    end
    context '`name` is not `settings`' do
      it { expect { provider.validate_name('not `settings`') }.to raise_error Puppet::ResourceError, %r{`name` must be `settings`} }
    end
  end

  canonicalize_data = [
    {
      desc:      '`resources` already sorted',
      resources: [{
        name:    'settings',
        ensure:  'present',
        servers: ['2001:2008:2008::2000', '2010:2008:2008::2000'],
        search:  ['abc', 'bcd', 'cdf'],
      }],
      results:   [{
        name:    'settings',
        ensure:  'present',
        servers: ['2001:2008:2008::2000', '2010:2008:2008::2000'],
        search:  ['abc', 'bcd', 'cdf'],
      }],
    },
    {
      desc:      '`resources` requires sorting',
      resources: [{
        name:    'settings',
        ensure:  'present',
        servers: ['2001:2008:2008::2000', '2010:2008:2008::2000', '2001:2008:2008::2348'],
        search:  ['abc', 'bcd', 'cdf'],
      }],
      results:   [{
        name:    'settings',
        ensure:  'present',
        servers: ['2001:2008:2008::2000', '2001:2008:2008::2348', '2010:2008:2008::2000'],
        search:  ['abc', 'bcd', 'cdf'],
      }],
    },
    {
      desc:      '`resources` does not contain `servers`',
      resources: [{
        name:   'settings',
        ensure: 'present',
        search: ['abc', 'bcd', 'cdf'],
      }],
      results:   [{
        name:   'settings',
        ensure: 'present',
        search: ['abc', 'bcd', 'cdf'],
      }],
    },
    {
      desc:      '`resources` does not contain `search`',
      resources: [{
        name:    'settings',
        ensure:  'present',
        servers: ['2001:2008:2008::2000', '2001:2008:2008::2348', '2010:2008:2008::2000'],
      }],
      results:   [{
        name:    'settings',
        ensure:  'present',
        servers: ['2001:2008:2008::2000', '2001:2008:2008::2348', '2010:2008:2008::2000'],
      }],
    }
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
end
