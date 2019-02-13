require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::NtpAuthKey')
require 'puppet/provider/ntp_auth_key/cisco_nexus'

RSpec.describe Puppet::Provider::NtpAuthKey::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:ntp_auth_key) { instance_double('Cisco::NtpAuthKey', 'ntp_auth_key') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::NtpAuthKey).to receive(:ntpkeys).and_return({})
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        expect(provider.get(context)).to eq []
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        expect(Cisco::NtpAuthKey).to receive(:ntpkeys).and_return('1' => ntp_auth_key)
        expect(ntp_auth_key).to receive(:algorithm).and_return('md5')
        expect(ntp_auth_key).to receive(:mode).and_return('7')
        expect(ntp_auth_key).to receive(:password).and_return('foo')
        expect(provider.get(context)).to eq [
          {
            name:      '1',
            ensure:    'present',
            algorithm: 'md5',
            mode:      7,
            password:  'foo',
          }
        ]
      end
    end
    context 'multiple returns' do
      it 'still processes' do
        expect(Cisco::NtpAuthKey).to receive(:ntpkeys).and_return('1' => ntp_auth_key,
                                                                  '2' => ntp_auth_key)
        expect(ntp_auth_key).to receive(:algorithm).and_return('md5', 'md5')
        expect(ntp_auth_key).to receive(:mode).and_return('7', '0')
        expect(ntp_auth_key).to receive(:password).and_return('foo', 'bar')
        expect(provider.get(context)).to eq [
          {
            name:      '1',
            ensure:    'present',
            algorithm: 'md5',
            mode:      7,
            password:  'foo',
          },
          {
            name:      '2',
            ensure:    'present',
            algorithm: 'md5',
            mode:      0,
            password:  'bar',
          }
        ]
      end
    end
    context 'get filter used without matches' do
      it 'still processes' do
        expect(Cisco::NtpAuthKey).to receive(:ntpkeys).and_return('1' => ntp_auth_key,
                                                                  '2' => ntp_auth_key)
        expect(provider.get(context, ['3'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        expect(Cisco::NtpAuthKey).to receive(:ntpkeys).and_return('1' => ntp_auth_key,
                                                                  '2' => ntp_auth_key)
        expect(ntp_auth_key).to receive(:name).and_return('1')
        expect(ntp_auth_key).to receive(:algorithm).and_return('md5')
        expect(ntp_auth_key).to receive(:mode).and_return('7')
        expect(ntp_auth_key).to receive(:password).and_return('foo')
        expect(provider.get(context, ['1'])).to eq [
          {
            name:      '1',
            ensure:    'present',
            algorithm: 'md5',
            mode:      7,
            password:  'foo',
          }
        ]
      end
    end
  end

  describe '#update' do
    context 'update is called with all values' do
      let(:should_values) do
        {
          name:      '1',
          ensure:    'present',
          algorithm: 'md5',
          mode:      7,
          password:  'foo',
        }
      end

      it 'performs an update' do
        expect(context).to receive(:notice).with(%r{\ASetting '1'})
        expect(Cisco::NtpAuthKey).to receive(:new).with('name'      => '1',
                                                        'algorithm' => 'md5',
                                                        'mode'      => 7,
                                                        'password'  => 'foo')

        provider.update(context, '1', should_values)
      end
    end
    context 'update is called only name' do
      let(:should_values) do
        {
          name:   '1',
          ensure: 'present',
        }
      end

      it 'performs an update' do
        expect(context).to receive(:notice).with(%r{\ASetting '1'})
        expect(Cisco::NtpAuthKey).to receive(:new).with('name' => '1')

        provider.update(context, '1', should_values)
      end
    end
  end

  describe '#create' do
    context 'create is called with all values' do
      let(:should_values) do
        {
          name:      '1',
          ensure:    'present',
          algorithm: 'md5',
          mode:      7,
          password:  'foo',
        }
      end

      it 'performs a create' do
        expect(context).to receive(:notice).with(%r{\ASetting '1'})
        expect(Cisco::NtpAuthKey).to receive(:new).with('name'      => '1',
                                                        'algorithm' => 'md5',
                                                        'mode'      => 7,
                                                        'password'  => 'foo')

        provider.create(context, '1', should_values)
      end
    end
    context 'create is called only name' do
      let(:should_values) do
        {
          name:   '1',
          ensure: 'present',
        }
      end

      it 'performs a create' do
        expect(context).to receive(:notice).with(%r{\ASetting '1'})
        expect(Cisco::NtpAuthKey).to receive(:new).with('name' => '1')

        provider.create(context, '1', should_values)
      end
    end
  end

  describe '#delete' do
    context 'delete is called' do
      let(:ntp_auth_key2) { instance_double('Cisco::NtpAuthKey', 'ntp_auth_key2') }

      it 'destroys the auth_key' do
        expect(context).to receive(:notice).with(%r{\ADestroying '1'})
        expect(Cisco::NtpAuthKey).to receive(:ntpkeys).and_return('1' => ntp_auth_key,
                                                                  '2' => ntp_auth_key2)
        expect(ntp_auth_key).to receive(:destroy).once
        expect(ntp_auth_key2).to receive(:destroy).never

        provider.delete(context, '1')
      end
    end
  end

  validate_should_data = [
    {
      desc:   '`name` is a string',
      issue:  'raise an error',
      expect: it { expect { provider.validate_should(name: 'foo') }.to raise_error Puppet::ResourceError, 'Invalid name, must be 1-65535' }
    },
    {
      desc:   '`name` is exceeds 65535',
      issue:  'raise an error',
      expect: it { expect { provider.validate_should(name: '65536') }.to raise_error Puppet::ResourceError, 'Invalid name, must be 1-65535' }
    },
    {
      desc:   '`name` is 0',
      issue:  'raise an error',
      expect: it { expect { provider.validate_should(name: '0') }.to raise_error Puppet::ResourceError, 'Invalid name, must be 1-65535' }
    },
    {
      desc:   '`name` does not exceed 65535',
      issue:  'not raise an error',
      expect: it { expect { provider.validate_should(name: '65535') }.not_to raise_error }
    },
    {
      desc:   '`password` exceeds 15 characters',
      issue:  'raise an error',
      expect: it { expect { provider.validate_should(name: '1', password: 'superlongpassword') }.to raise_error Puppet::ResourceError, 'Invalid password length, max length is 15' }
    },
    {
      desc:   '`mode` is not valid',
      issue:  'raise an error',
      expect: it { expect { provider.validate_should(name: '1', mode: 1) }.to raise_error Puppet::ResourceError, 'Invalid mode, supported modes are 0 and 7' }
    },
    {
      desc:   '`should` is valid',
      issue:  'not raise an error',
      expect: it { expect { provider.validate_should(name: '1', mode: 0, password: 'foo') }.not_to raise_error }
    },
  ]

  describe '#validate_should' do
    validate_should_data.each do |test|
      context "#{test[:desc]}" do
        it "#{test[:issue]}" do
          test[:expect]
        end
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
