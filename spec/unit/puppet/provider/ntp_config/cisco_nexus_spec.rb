require 'spec_helper'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::NtpConfig')
require 'puppet/provider/ntp_config/cisco_nexus'

RSpec.describe Puppet::Provider::NtpConfig::CiscoNexus do
  let(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:ntp_config) { instance_double('Cisco::NtpConfig', 'ntp_config') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::NtpConfig).to receive(:new).with('default').and_return(ntp_config)
  end

  describe '#set(context, changes)' do
    let(:changes) do
      {
        'default' =>
                     {
                       is:     {
                         name:             'default',
                         authenticate:     false,
                         trusted_key:      ['unset'],
                         source_interface: 'unset',
                       },
                       should: should_values
                     }
      }
    end

    context 'there are changes' do
      let(:should_values) do
        {
          name:             'default',
          authenticate:     false,
          trusted_key:      ['5', '10'],
          source_interface: 'ethernet1/1',
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
          name:             'default',
          authenticate:     false,
          trusted_key:      ['unset'],
          source_interface: 'unset',
        }
      end

      it 'will not call update' do
        expect(provider).to receive(:update).with(context, 'default', changes['default'][:should]).never

        provider.set(context, changes)
      end
    end
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        expect(ntp_config).to receive(:authenticate)
        expect(ntp_config).to receive(:source_interface)
        expect(ntp_config).to receive(:trusted_key)

        expect(provider.get(context)).to eq [
          {
            name:             'default',
            authenticate:     false,
            trusted_key:      ['unset'],
            source_interface: 'unset',
          }
        ]
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        expect(ntp_config).to receive(:authenticate).and_return(true)
        expect(ntp_config).to receive(:source_interface).and_return(7).twice
        expect(ntp_config).to receive(:trusted_key).and_return([5, 10, 11]).twice

        expect(provider.get(context)).to eq [
          {
            name:             'default',
            authenticate:     true,
            trusted_key:      [5, 10, 11],
            source_interface: 7,
          }
        ]
      end
    end
  end

  describe '#update' do
    context 'update is called' do
      let(:should_values) do
        {
          name:             'default',
          authenticate:     true,
          trusted_key:      [5, 10, 11],
          source_interface: 7,
        }
      end

      it 'performs an update' do
        expect(ntp_config).to receive(:trusted_key).twice
        expect(ntp_config).to receive(:authenticate=).with(true)
        expect(ntp_config).to receive(:source_interface=).with(7)
        expect(ntp_config).to receive(:trusted_key_set).with(true, '5')
        expect(ntp_config).to receive(:trusted_key_set).with(true, '10')
        expect(ntp_config).to receive(:trusted_key_set).with(true, '11')
        expect(context).to receive(:notice).with(%r{\AUpdating 'default'})
        provider.update(context, 'default', should_values)
      end
    end
  end

  describe '#handle_trusted_keys' do
    context 'nothing to remove' do
      it 'only adds keys' do
        expect(ntp_config).to receive(:trusted_key).twice
        expect(ntp_config).to receive(:trusted_key_set).with(true, '5')
        expect(ntp_config).to receive(:trusted_key_set).with(true, '10')
        expect(ntp_config).to receive(:trusted_key_set).with(true, '11')
        expect(ntp_config).to receive(:trusted_key_set).with(false, anything).never
        provider.handle_trusted_keys([5, 10, 11])
      end
    end
    context 'stuff to remove' do
      it 'only adds the keys' do
        expect(ntp_config).to receive(:trusted_key).and_return([2, 3]).twice
        expect(ntp_config).to receive(:trusted_key).once
        expect(ntp_config).to receive(:trusted_key_set).with(true, '5').once
        expect(ntp_config).to receive(:trusted_key_set).with(true, '10').once
        expect(ntp_config).to receive(:trusted_key_set).with(true, '11').once
        expect(ntp_config).to receive(:trusted_key_set).with(false, '2').once
        expect(ntp_config).to receive(:trusted_key_set).with(false, '3').once
        provider.handle_trusted_keys([5, 10, 11])
      end
      it 'only adds new keys' do
        expect(ntp_config).to receive(:trusted_key).and_return([2, 3, 4]).twice
        expect(ntp_config).to receive(:trusted_key).and_return([2, 3]).twice
        expect(ntp_config).to receive(:trusted_key_set).with(true, '2').never
        expect(ntp_config).to receive(:trusted_key_set).with(true, '3').never
        expect(ntp_config).to receive(:trusted_key_set).with(true, '5').once
        expect(ntp_config).to receive(:trusted_key_set).with(true, '10').once
        expect(ntp_config).to receive(:trusted_key_set).with(true, '11').once
        expect(ntp_config).to receive(:trusted_key_set).with(false, '2').never
        expect(ntp_config).to receive(:trusted_key_set).with(false, '3').never
        expect(ntp_config).to receive(:trusted_key_set).with(false, '4').once
        provider.handle_trusted_keys([2, 3, 5, 10, 11])
      end
    end
    context 'unset is passed' do
      it 'deletes the old keys' do
        expect(ntp_config).to receive(:trusted_key).and_return([2, 3]).twice
        expect(ntp_config).to receive(:trusted_key_set).with(false, '2').once
        expect(ntp_config).to receive(:trusted_key_set).with(false, '3').once
        expect(ntp_config).to receive(:trusted_key_set).with(true, anything).never
        provider.handle_trusted_keys(['unset'])
      end
      it 'does not add when key source is empty' do
        expect(ntp_config).to receive(:trusted_key).once
        expect(ntp_config).to receive(:trusted_key_set).with(false, anything).never
        expect(ntp_config).to receive(:trusted_key_set).with(true, anything).never
        provider.handle_trusted_keys(['unset'])
      end
    end
  end

  describe '#validate_should' do
    context '`name` is not `default`' do
      it { expect { provider.validate_should(name: 'foo') }.to raise_error Puppet::ResourceError, 'Invalid name, `name` must be `default`' }
    end

    context '`name` is `default`' do
      it { expect { provider.validate_should(name: 'default') }.not_to raise_error }
    end

    context '`source interface` contains spaces' do
      it {
        expect { provider.validate_should(name: 'default', source_interface: 'space foo') }.to raise_error Puppet::ResourceError,
                                                                                                           'Invalid source interface, `source_interface` must not contain any spaces'
      }
    end

    context '`source interface` contains uppercase characters' do
      it {
        expect { provider.validate_should(name: 'default', source_interface: 'spaceFoo') }.to raise_error Puppet::ResourceError,
                                                                                                          'Invalid source interface, `source_interface` must not contain any uppercase characters'
      }
    end

    context '`should` is valid' do
      it { expect { provider.validate_should(name: 'default', trusted_key: [1, 2], source_interface: '7') }.not_to raise_error }
    end
  end

  canonicalize_data = [
    {
      desc:      '`resources` with ints already sorted',
      resources: [{
        name:        'default',
        trusted_key: [1, 2, 3, 4],
      }],
      results:   [{
        name:        'default',
        trusted_key: ['1', '2', '3', '4'],
      }],
    },
    {
      desc:      '`resources` with strings already sorted',
      resources: [{
        name:        'default',
        trusted_key: ['1', '2', '3', '4'],
      }],
      results:   [{
        name:        'default',
        trusted_key: ['1', '2', '3', '4'],
      }],
    },
    {
      desc:      '`resources` with ints requires sorting',
      resources: [{
        name:        'default',
        trusted_key: [10, 9, 1, 2, 3, 4],
      }],
      results:   [{
        name:        'default',
        trusted_key: ['1', '2', '3', '4', '9', '10'],
      }],
    },
    {
      desc:      '`resources` with strings requires sorting',
      resources: [{
        name:        'default',
        trusted_key: ['10', '9', '1', '2', '4', '3'],
      }],
      results:   [{
        name:        'default',
        trusted_key: ['1', '2', '3', '4', '9', '10'],
      }],
    },
    {
      desc:      '`resources` does not contain `trusted_key`',
      resources: [{
        name: 'default',
      }],
      results:   [{
        name: 'default',
      }],
    },
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
