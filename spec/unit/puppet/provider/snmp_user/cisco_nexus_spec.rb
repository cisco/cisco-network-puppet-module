require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::SnmpUser')
require 'puppet/provider/snmp_user/cisco_nexus'

RSpec.describe Puppet::Provider::SnmpUser::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:snmpuser) { instance_double('Cisco::SnmpUser', 'snmpuser') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::SnmpUser).to receive(:users).and_return({})
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        expect(provider.get(context)).to eq []
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        allow(Cisco::SnmpUser).to receive(:users).and_return('test' => snmpuser)
        expect(snmpuser).to receive(:engine_id).and_return('foo')
        expect(snmpuser).to receive(:groups).and_return(['bar', 'car'])
        expect(snmpuser).to receive(:auth_protocol).and_return(:dog, :dog)
        expect(snmpuser).to receive(:auth_password).and_return('moooocow', 'moooocow')
        expect(snmpuser).to receive(:priv_protocol).and_return(:cat, :cat)
        expect(snmpuser).to receive(:priv_password).and_return('cowwwwmoo')
        expect(provider.get(context)).to eq [
          {
            name:          'test',
            ensure:        'present',
            engine_id:     'foo',
            roles:         ['bar', 'car'],
            auth:          'dog',
            password:      'moooocow',
            privacy:       'cat',
            private_key:   'cowwwwmoo',
            localized_key: true,
          }
        ]
      end
    end
    context 'with multiple users' do
      it 'still processes' do
        allow(Cisco::SnmpUser).to receive(:users).and_return('test'  => snmpuser,
                                                             'admin' => snmpuser)
        expect(snmpuser).to receive(:engine_id).and_return('foo', 'moo')
        expect(snmpuser).to receive(:groups).and_return(['bar', 'car'], [])
        expect(snmpuser).to receive(:auth_protocol).and_return(:dog, :dog, nil, nil)
        expect(snmpuser).to receive(:auth_password).and_return('moooocow', 'moooocow', nil, nil)
        expect(snmpuser).to receive(:priv_protocol).and_return(:cat, :cat, nil, nil)
        expect(snmpuser).to receive(:priv_password).and_return('cowwwwmoo', nil, nil)
        expect(provider.get(context)).to eq [
          {
            name:          'test',
            ensure:        'present',
            engine_id:     'foo',
            roles:         ['bar', 'car'],
            auth:          'dog',
            password:      'moooocow',
            privacy:       'cat',
            private_key:   'cowwwwmoo',
            localized_key: true,
          },
          {
            name:          'admin',
            ensure:        'present',
            engine_id:     'moo',
            roles:         [],
            auth:          '',
            password:      nil,
            privacy:       '',
            private_key:   nil,
            localized_key: nil,
          }
        ]
      end
    end
    context 'get filter used without matches' do
      it 'still processes' do
        allow(Cisco::SnmpUser).to receive(:users).and_return('test'  => snmpuser,
                                                             'admin' => snmpuser)
        expect(provider.get(context, ['dog'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        allow(Cisco::SnmpUser).to receive(:users).and_return('test'  => snmpuser,
                                                             'admin' => snmpuser)
        expect(snmpuser).to receive(:engine_id).and_return('foo')
        expect(snmpuser).to receive(:groups).and_return(['bar', 'car'])
        expect(snmpuser).to receive(:auth_protocol).and_return(:dog, :dog)
        expect(snmpuser).to receive(:auth_password).and_return('moooocow').twice
        expect(snmpuser).to receive(:priv_protocol).and_return(:cat, :cat)
        expect(snmpuser).to receive(:priv_password).and_return('cowwwwmoo')
        expect(provider.get(context, ['test'])).to eq [
          {
            name:          'test',
            ensure:        'present',
            engine_id:     'foo',
            roles:         ['bar', 'car'],
            auth:          'dog',
            password:      'moooocow',
            privacy:       'cat',
            private_key:   'cowwwwmoo',
            localized_key: true,
          }
        ]
      end
    end
  end

  describe '#update' do
    context 'update is called' do
      let(:should_values) do
        {
          name:          'foo',
          ensure:        'present',
          roles:         ['bar', 'car'],
          auth:          'dog',
          password:      'moooocow',
          privacy:       'cat',
          private_key:   'cowwwwmoo',
          localized_key: true,
        }
      end

      it 'performs an update' do
        expect(context).to receive(:notice).with(%r{\ASetting 'foo'})
        expect(Cisco::SnmpUser).to receive(:new).with('foo',
                                                      ['bar', 'car'],
                                                      :dog,
                                                      'moooocow',
                                                      :cat,
                                                      'cowwwwmoo',
                                                      true,
                                                      '')
        provider.update(context, 'foo', should_values)
      end
    end
  end

  describe '#create' do
    context 'create is called' do
      let(:should_values) do
        {
          name:        'foo',
          ensure:      'present',
          roles:       ['bar', 'car'],
          auth:        'dog',
          password:    'moooocow',
          privacy:     'cat',
          private_key: 'cowwwwmoo',
        }
      end

      it 'performs a creation' do
        expect(context).to receive(:notice).with(%r{\ASetting 'foo'})
        expect(Cisco::SnmpUser).to receive(:new).with('foo',
                                                      ['bar', 'car'],
                                                      :dog,
                                                      'moooocow',
                                                      :cat,
                                                      'cowwwwmoo',
                                                      false,
                                                      '')
        provider.create(context, 'foo', should_values)
      end
    end
  end

  describe '#delete' do
    context 'delete is called' do
      it 'destroys the user' do
        expect(context).to receive(:notice).with(%r{\ADestroying 'foo'})
        expect(Cisco::SnmpUser).to receive(:users).and_return('foo'   => snmpuser,
                                                              'admin' => snmpuser)
        expect(snmpuser).to receive(:destroy).once
        provider.delete(context, 'foo')
      end
    end
    it { expect { provider.delete(context, 'admin') }.to raise_error Puppet::ResourceError, 'The admin account cannot be deactivated on this platform.' }
  end

  describe '#validate_should' do
    it {
      expect {
        provider.validate_should(password: 'blah', privacy: 'privacy', private_key: 'private_key', localized_key: 'localized_key', engine_id: 'engine_id')
      }.to raise_error Puppet::ResourceError, "You must specify the 'auth' property when specifying any of the following properties: [:password, :privacy, :private_key, :localized_key, :engine_id]"
    }
    it {
      expect {
        provider.validate_should(auth: 'cool', password: 'blah', privacy: 'privacy', private_key: 'private_key', localized_key: 'localized_key', engine_id: 'engine_id')
      }.not_to raise_error
    }
    it {
      expect {
        provider.validate_should(auth: 'cool', privacy: 'privacy', private_key: 'private_key', localized_key: 'localized_key', engine_id: 'engine_id')
      }.to raise_error Puppet::ResourceError, "The 'password' property must be set when specifying 'auth'"
    }
    it {
      expect {
        provider.validate_should(auth: 'cool', password: 'blah', privacy: 'privacy', localized_key: 'localized_key', engine_id: 'engine_id')
      }.to raise_error Puppet::ResourceError, "The 'private_key' property must be set when specifying 'privacy'"
    }
    it {
      expect {
        provider.validate_should(auth: 'md5', password: 'blah', engine_id: 'engine_id', roles: ['bar'])
      }.to raise_error Puppet::ResourceError, "The 'engine_id' and 'roles' properties are mutually exclusive"
    }
    it {
      expect {
        provider.validate_should(enforce_privacy: 'enforce_privacy', roles: ['blah'])
      }.to raise_error Puppet::ResourceError, "The 'enforce_privacy' property is not supported by this provider"
    }
  end

  it_behaves_like 'a noop canonicalizer'
end
