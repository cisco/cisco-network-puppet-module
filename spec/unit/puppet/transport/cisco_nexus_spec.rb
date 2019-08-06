require 'puppet/transport/cisco_nexus'
require 'puppet/resource_api'

describe Puppet::Transport::CiscoNexus do
  let(:device) { described_class.new(context, device_config) }
  let(:pass) { Puppet::Pops::Types::PSensitiveType::Sensitive.new('password') }
  let(:device_config) { { host: 'www.example.com', user: 'admin', password: pass } }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:cisco_platform) do
    {
      system_image:        'bootflash:///nxos.7.0.3.I7.4.bin',
      image_version:       '7.0(3)I7(4)',
      packages:            {},
      hardware_type:       'Nexus9000 C9372PX chassis',
      cpu:                 'Intel(R) Core(TM) i3- CPU @ 2.50GHz',
      memory:              {
        total: '16400992K',
        used:  '5648144K',
      },
      board:               'SAL1911BCTX',
      last_reset:          '1556118503',
      reset_reason:        'Kernel Reboot',
      chassis:             {
        desc: 'Nexus9000 C9372PX chassis',
        pid:  'N9K-C9372PX',
        vid:  'V02',
      },
      slot_1:              {
        desc: '48x1/10G SFP+ 6x40G Ethernet Module',
        pid:  'N9K-C9372PX',
      },
      power_supplies:      {
        power_supply_one: {
          desc: 'Nexus9000 C9372PX chassis Power Supply',
          pid:  'N9K-PAC-650W-B',
        },
      },
      fans:                {
        fan_one: {
          desc: 'Nexus9000 C9372PX chassis Fan Module',
          pid:  'NXA-FAN-30CFM-F',
        },
      },
      interface_count:     70,
      interface_threshold: 10,
      virtual_services:    {
        application: {
          name: 'GuestShell',
        },
      },
      uptime:              '40 days, 21 hours, 30 minutes, 40 seconds',
    }
  end
  let(:facts) do
    { 'operatingsystem'        => 'nexus',
      'cisco_node_utils'       => '2.1.0',
      'cisco'                  => {
        'images'                           => {
          'system_image' => 'bootflash:///nxos.7.0.3.I7.4.bin',
          'full_version' => '7.0(3)I7(4)',
          'packages'     => {}
        },
        'hardware'                         => {
          'type'         => 'Nexus9000 C9372PX chassis',
          'cpu'          => 'Intel(R) Core(TM) i3- CPU @ 2.50GHz',
          'memory'       => { total: '16400992K', used: '5648144K' },
          'board'        => 'SAL1911BCTX',
          'last_reset'   => '1556118503',
          'reset_reason' => 'Kernel Reboot',
          'uptime'       => '40 days, 21 hours, 30 minutes, 40 seconds'
        },
        'interface_count'                  => 70,
        'interface_threshold'              => 10,
        'inventory'                        => {
          'chassis'         => { desc: 'Nexus9000 C9372PX chassis', pid: 'N9K-C9372PX', vid: 'V02' },
          :desc             => '48x1/10G SFP+ 6x40G Ethernet Module',
          :pid              => 'N9K-C9372PX',
          :power_supply_one => { desc: 'Nexus9000 C9372PX chassis Power Supply', pid: 'N9K-PAC-650W-B' },
          :fan_one          => { desc: 'Nexus9000 C9372PX chassis Fan Module', pid: 'NXA-FAN-30CFM-F' }
        },
        'virtual_service'                  => { application: { name: 'GuestShell' } },
        'feature_compatible_module_iflist' => { 'fabricpath' => { fabricpath: {} } }
      },
      'hostname'               => 'cisco-c9372',
      'operatingsystemrelease' => '7.0(3)I7(4)' }
  end

  describe '#initialize' do
    context 'when initialized' do
      it 'calls Cisco::Environment.add_env' do
        expect(Cisco::Environment).to receive(:add_env).with('default', host: 'www.example.com', password: 'password', port: nil, username: 'admin', verify_mode: nil, transport: nil).once
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
        allow(Cisco::Interface).to receive(:interface_count).and_return(cisco_platform[:interface_count])
        allow(Cisco::Platform).to receive(:virtual_services).and_return(cisco_platform[:virtual_services])
        allow(Cisco::Platform).to receive(:uptime).and_return(cisco_platform[:uptime])
        allow(Cisco::Feature).to receive(:compatible_interfaces).and_return(fabricpath: {})
        allow(Cisco::NodeUtil).to receive(:node).and_return('foo')
        allow(Cisco::NodeUtil.node).to receive(:host_name).and_return('cisco-c9372')
        stub_const('CiscoNodeUtils::VERSION', '2.1.0')

        expect(device.facts(context)).to eq(facts)
      end
    end
  end
end
