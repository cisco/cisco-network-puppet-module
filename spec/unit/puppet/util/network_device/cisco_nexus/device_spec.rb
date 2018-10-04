require 'spec_helper'
require 'puppet/util/network_device/cisco_nexus/device'

RSpec.describe Puppet::Util::NetworkDevice::Cisco_nexus do
  describe Puppet::Util::NetworkDevice::Cisco_nexus::Device do
    let(:device) { described_class.new(device_config) }
    let(:device_config) { { 'address' => 'www.example.com', 'user' => 'admin', 'password' => 'password' } }
    let(:cisco_platform) do
      {
        system_image: 'foo_img',
        image_version: '7.0.1-bar',
        packages: {},
        hardware_type: 'NX-91',
        cpu:           'bar',
        memory:        {
          total: '111k',
          used:  '83k',
        },
        board: 'foo/bar',
        last_reset: '1111',
        reset_reason: 'foo',
        chassis: {
          desc: 'doo',
          pid: 'NX-91-NXXZ',
          vid: 'NXXZ',
        },
        slot_1: {
          desc: 'Ethernet One',
          pid: 'NX-JKSSS',
        },
        power_supplies: {
          power_supply_one: {
            desc: 'PS',
            pid: '150w',
          },
        },
        fans: {
          fan_one: {
            desc: 'fan one',
            pid: '30w',
          },
        },
        virtual_services: {
          application: {
            name: 'foo',
          },
        },
        uptime: '0 days, 20 hours, 27 minutes, 56 seconds',
      }
    end
    let(:facts) do
      { 'operatingsystem' => 'nexus',
        'cisco_node_utils' => '1.10.0',
        'cisco' =>
         { 'images' => { 'system_image' => 'foo_img', 'full_version' => '7.0.1-bar', 'packages' => {} },
           'hardware' =>
           { 'type' => 'NX-91', 'cpu' => 'bar', 'memory' => { total: '111k', used: '83k' },
             'board' => 'foo/bar',
             'last_reset' => '1111',
             'reset_reason' => 'foo',
             'uptime' => '0 days, 20 hours, 27 minutes, 56 seconds' },
           'inventory' => {
             'chassis' => {
               desc: 'doo', pid: 'NX-91-NXXZ', vid: 'NXXZ'
             },
             :desc => 'Ethernet One',
             :pid => 'NX-JKSSS',
             :power_supply_one => {
               desc: 'PS', pid: '150w'
             }, :fan_one => { desc: 'fan one', pid: '30w' }
           },
           'virtual_service' => { application: { name: 'foo' } },
           'feature_compatible_module_iflist' => { 'fabricpath' => { fabricpath: {} } } },
        'hostname' => 'bar',
        'operatingsystemrelease' => '7.0.1-bar' }
    end

    describe '#initialize' do
      context 'when initialized' do
        it 'has access to @config' do
          expect(device.config).to eq(device_config)
        end

        it 'calls Cisco::Environment.add_env' do
          expect(Cisco::Environment).to receive(:add_env).with('default', host: 'www.example.com', password: 'password', port: nil, username: nil).once
          device
        end
      end
    end

    describe '#facts' do
      context 'when called' do
        it 'returns the facts' do
          allow(Cisco::Platform).to receive(:system_image).and_return(cisco_platform[:system_image])
          allow(Cisco::Platform).to receive(:image_version).and_return(cisco_platform[:image_version])
          allow(Cisco::Platform).to receive(:packages).and_return(cisco_platform[:packages])
          allow(Cisco::Platform).to receive(:hardware_type).and_return(cisco_platform[:hardware_type])
          allow(Cisco::Platform).to receive(:cpu).and_return(cisco_platform[:cpu])
          allow(Cisco::Platform).to receive(:memory).and_return(cisco_platform[:memory])
          allow(Cisco::Platform).to receive(:board).and_return(cisco_platform[:board])
          allow(Cisco::Platform).to receive(:last_reset).and_return(cisco_platform[:last_reset])
          allow(Cisco::Platform).to receive(:reset_reason).and_return(cisco_platform[:reset_reason])
          allow(Cisco::Platform).to receive(:chassis).and_return(cisco_platform[:chassis])
          allow(Cisco::Platform).to receive(:slots).and_return(cisco_platform[:slot_1])
          allow(Cisco::Platform).to receive(:power_supplies).and_return(cisco_platform[:power_supplies])
          allow(Cisco::Platform).to receive(:fans).and_return(cisco_platform[:fans])
          allow(Cisco::Platform).to receive(:virtual_services).and_return(cisco_platform[:virtual_services])
          allow(Cisco::Platform).to receive(:uptime).and_return(cisco_platform[:uptime])
          allow(Cisco::Feature).to receive(:compatible_interfaces).and_return(fabricpath: {})
          allow(Cisco::NodeUtil).to receive(:node).and_return('foo')
          allow(Cisco::NodeUtil.node).to receive(:host_name).and_return('bar')

          expect(device.facts).to eq(facts)
        end
      end
    end
  end
end
