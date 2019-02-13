require 'spec_helper'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::SyslogFacility')
require 'puppet/provider/syslog_facility/cisco_nexus'

RSpec.describe Puppet::Provider::SyslogFacility::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:facility) { instance_double('Cisco::SyslogFacility', 'facility') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
  end

  describe '#get' do
    context 'everything is empty' do
      it 'still processes' do
        allow(Cisco::SyslogFacility).to receive(:facilities).and_return({})
        expect(provider.get(context)).to eq []
      end
    end
    context 'everything is not empty' do
      it 'still processes' do
        allow(Cisco::SyslogFacility).to receive(:facilities).and_return('aaa' => facility)
        allow(facility).to receive(:level).and_return(7)
        expect(provider.get(context)).to eq [
          {
            name:   'aaa',
            level:  7,
            ensure: 'present',
          }
        ]
      end
    end
    context 'with multiple facilities' do
      it 'still processes' do
        allow(Cisco::SyslogFacility).to receive(:facilities).and_return('aaa' => facility,
                                                                        'bbb' => facility)
        allow(facility).to receive(:level).and_return(7, 3)
        expect(provider.get(context)).to eq [
          {
            name:   'aaa',
            level:  7,
            ensure: 'present',
          },
          {
            name:   'bbb',
            level:  3,
            ensure: 'present',
          }
        ]
      end
    end
    context 'get filter used without maches' do
      it 'still processes' do
        allow(Cisco::SyslogFacility).to receive(:facilities).and_return('aaa' => facility,
                                                                        'bbb' => facility)
        allow(facility).to receive(:level).and_return(7, 3)
        expect(provider.get(context, ['ccc'])).to eq []
      end
    end
    context 'get filter used with maches' do
      it 'still processes' do
        allow(Cisco::SyslogFacility).to receive(:facilities).and_return('aaa' => facility,
                                                                        'bbb' => facility)
        allow(facility).to receive(:level).and_return(3)
        expect(provider.get(context, ['bbb'])).to eq [
          {
            ensure: 'present',
            name:   'bbb',
            level:  3,
          }
        ]
      end
    end
  end

  describe '#update' do
    context 'update is called' do
      let(:should_values) do
        {
          name:   'aaa',
          ensure: 'present',
          level:  7,
        }
      end

      it 'performs the update' do
        expect(context).to receive(:notice).with(%r{\ASetting 'aaa'})
        expect(Cisco::SyslogFacility).to receive(:new).with('facility' => 'aaa',
                                                            'level'    => '7')

        provider.update(context, 'aaa', should_values)
      end
    end
  end

  describe '#create' do
    context 'create is called' do
      let(:should_values) do
        {
          name:   'aaa',
          ensure: 'present',
          level:  7,
        }
      end

      it 'performs the creation' do
        expect(context).to receive(:notice).with(%r{\ASetting 'aaa'})
        expect(Cisco::SyslogFacility).to receive(:new).with('facility' => 'aaa',
                                                            'level'    => '7')

        provider.create(context, 'aaa', should_values)
      end
    end
  end

  describe '#delete' do
    context 'delete is called' do
      it 'destroys the facility' do
        expect(context).to receive(:notice).with(%r{\ADestroying 'aaa'})
        allow(Cisco::SyslogFacility).to receive(:facilities).and_return('aaa' => facility,
                                                                        'bbb' => facility)
        expect(facility).to receive(:destroy).once
        provider.delete(context, 'aaa')
      end
    end
  end

  it_behaves_like 'a noop canonicalizer'
end
