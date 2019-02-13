require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::RadiusServerGroup')
require 'puppet/provider/radius_server_group/cisco_nexus'

RSpec.describe Puppet::Provider::RadiusServerGroup::CiscoNexus do
  let(:provider) { described_class.new }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:radius_server_group_instance) { instance_double('Cisco::RadiusServerGroup', 'radius_server_group_instance') }
  let(:radius_server_group_instance2) { instance_double('Cisco::RadiusServerGroup', 'radius_server_group_instance2') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
    allow(Cisco::RadiusServerGroup).to receive(:new).and_return(radius_server_group_instance)
  end

  describe '#get' do
    it 'processes resources with multiple servers' do
      expect(Cisco::RadiusServerGroup).to receive(:radius_server_groups).and_return('a' => radius_server_group_instance)
      expect(radius_server_group_instance).to receive(:name).and_return('test_radius')
      expect(radius_server_group_instance).to receive(:servers).and_return(['1.1.1.1', '2.2.2.2']).twice

      expect(provider.get(context)).to eq [
        {
          ensure:  'present',
          name:    'test_radius',
          servers: ['1.1.1.1', '2.2.2.2'],
        },
      ]
    end

    it 'processes resources with no servers' do
      expect(Cisco::RadiusServerGroup).to receive(:radius_server_groups).and_return('a' => radius_server_group_instance)
      expect(radius_server_group_instance).to receive(:name).and_return('test_radius')
      expect(radius_server_group_instance).to receive(:servers).and_return([]).once
      expect(provider.get(context)).to eq [
        {
          ensure:  'present',
          name:    'test_radius',
          servers: ['unset'],
        },
      ]
    end

    context 'get filter used without matches' do
      it 'still processes' do
        expect(Cisco::RadiusServerGroup).to receive(:radius_server_groups).and_return('a' => radius_server_group_instance,
                                                                                      'b' => radius_server_group_instance2)
        expect(provider.get(context, ['c'])).to eq []
      end
    end
    context 'get filter used with matches' do
      it 'still processes' do
        expect(Cisco::RadiusServerGroup).to receive(:radius_server_groups).and_return('a' => radius_server_group_instance,
                                                                                      'b' => radius_server_group_instance2,
                                                                                     )
        expect(radius_server_group_instance).not_to receive(:name)
        expect(radius_server_group_instance).not_to receive(:servers)
        expect(radius_server_group_instance2).to receive(:name).and_return('test_radius_b')
        expect(radius_server_group_instance2).to receive(:servers).and_return(['1.2.3.4', '4.3.2.1']).twice
        expect(provider.get(context, ['b'])).to eq [
          {
            ensure:  'present',
            name:    'test_radius_b',
            servers: ['1.2.3.4', '4.3.2.1'],
          }
        ]
      end
    end
  end

  describe '#create' do
    it 'creates the resource' do
      expect(context).to receive(:notice).with(%r{\ACreating 'test_radius'}).once
      expect(radius_server_group_instance).to receive(:servers=).with(['1.1.1.1', '2.2.2.2'])

      provider.create(context, 'test_radius', name:    'test_radius',
                                              ensure:  'present',
                                              servers: ['1.1.1.1', '2.2.2.2'])
    end

    it 'creates the resource with unset servers' do
      expect(context).to receive(:notice).with(%r{\ACreating 'test_radius'}).once
      expect(radius_server_group_instance).to receive(:servers=).with([])

      provider.create(context, 'test_radius', name:    'test_radius',
                                              ensure:  'present',
                                              servers: ['unset'])
    end
  end

  describe '#update' do
    it 'updates the resource' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'test_radius'}).once
      expect(radius_server_group_instance).to receive(:servers=).with(['1.1.1.1', '2.2.2.2'])

      provider.update(context, 'test_radius', name:    'test_radius',
                                              ensure:  'present',
                                              servers: ['1.1.1.1', '2.2.2.2'])
    end

    it 'updates the resource with unset servers' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'test_radius'}).once
      expect(radius_server_group_instance).to receive(:servers=).with([])

      provider.update(context, 'test_radius', name:    'test_radius',
                                              ensure:  'present',
                                              servers: ['unset'])
    end
  end

  describe '#delete' do
    it 'updates the resource' do
      expect(context).to receive(:notice).with(%r{\ADeleting 'test_radius'}).once
      expect(radius_server_group_instance).to receive(:destroy)

      provider.delete(context, 'test_radius')
    end
  end

  munge_data = [
    {
      desc:   '`servers` is unset',
      value:  ['unset'],
      return: [],
    },
    {
      desc:   '`servers` is not unset',
      value:  ['1.1.1.1', '2.2.2.2'],
      return: ['1.1.1.1', '2.2.2.2'],
    }
  ]

  describe '#munge' do
    munge_data.each do |test|
      context "#{test[:desc]}" do
        it 'returns munged value' do
          expect(provider.munge(test[:value])).to eq(test[:return])
        end
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
