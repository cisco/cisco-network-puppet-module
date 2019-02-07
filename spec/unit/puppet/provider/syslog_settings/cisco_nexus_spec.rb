require 'spec_helper'
require 'support/shared_examples'
require 'cisco_node_utils'

ensure_module_defined('Puppet::Provider::SyslogSettings')
require 'puppet/provider/syslog_settings/cisco_nexus'

RSpec.describe Puppet::Provider::SyslogSettings::CiscoNexus do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Nexus::Device', 'device') }
  let(:syslog_settings) { instance_double('Cisco::SyslogSettings', 'syslog_settings') }

  let(:changes) do
    {
      'default' =>
                   {
                     is:     {
                       name:                   'default',
                       console:                2,
                       monitor:                5,
                       source_interface:       ['mgmt0'],
                       time_stamp_units:       'milliseconds',
                       logfile_name:           'testlogfile',
                       logfile_severity_level: 3,
                       logfile_size:           4098,
                     },
                     should: should_values
                   }
    }
  end

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:facts).and_return('operatingsystem' => 'nexus')
  end

  describe '#set' do
    context 'should is different' do
      let(:should_values) do
        {
          name:                   'default',
          console:                3,
          monitor:                6,
          source_interface:       ['mgmt0'],
          time_stamp_units:       'seconds',
          logfile_name:           'testlogfile',
          logfile_severity_level: 3,
          logfile_size:           4098,
        }
      end

      it 'performs an update' do
        allow(Cisco::SyslogSettings).to receive(:syslogsettings).and_return('default' => syslog_settings)
        expect(context).to receive(:notice).with(%r{Setting 'default'})

        provider.set(context, changes)
      end
    end

    context 'should is unset' do
      let(:should_values) do
        {
          name:                   'default',
          console:                'unset',
          monitor:                'unset',
          source_interface:       ['unset'],
          time_stamp_units:       'seconds',
          logfile_name:           'unset',
          logfile_severity_level: 'unset',
          logfile_size:           'unset',
        }
      end

      it 'performs an update' do
        allow(Cisco::SyslogSettings).to receive(:syslogsettings).and_return('default' => syslog_settings)
        expect(context).to receive(:notice).with(%r{Setting 'default'})

        provider.set(context, changes)
      end
    end

    context 'should is unset and -1' do
      let(:should_values) do
        {
          name:                   'default',
          console:                -1,
          monitor:                -1,
          source_interface:       ['unset'],
          time_stamp_units:       'seconds',
          logfile_name:           'unset',
          logfile_severity_level: -1,
          logfile_size:           -1,
        }
      end

      it 'performs an update' do
        allow(Cisco::SyslogSettings).to receive(:syslogsettings).and_return('default' => syslog_settings)
        expect(context).to receive(:notice).with(%r{Setting 'default'})

        provider.set(context, changes)
      end
    end

    context 'should is the same' do
      let(:should_values) do
        {
          name:                   'default',
          console:                2,
          monitor:                5,
          source_interface:       ['mgmt0'],
          time_stamp_units:       'milliseconds',
          logfile_name:           'testlogfile',
          logfile_severity_level: 3,
          logfile_size:           4098,
        }
      end

      it 'does not update' do
        expect(context).not_to receive(:notice).with(anything)

        provider.set(context, changes)
      end
    end
  end

  describe '#get' do
    context 'syslog_settings is not empty' do
      it 'returns the results' do
        allow(Cisco::SyslogSettings).to receive(:syslogsettings).and_return('default' => syslog_settings)
        allow(syslog_settings).to receive(:console).and_return('2')
        allow(syslog_settings).to receive(:monitor).and_return('5')
        allow(syslog_settings).to receive(:source_interface).and_return('mgmt0')
        allow(syslog_settings).to receive(:time_stamp_units).and_return('seconds')
        allow(syslog_settings).to receive(:logfile_name).and_return('testlogfile')
        allow(syslog_settings).to receive(:logfile_severity_level).and_return('3')
        allow(syslog_settings).to receive(:logfile_size).and_return('4098')

        expect(provider.get(context)).to eq [
          {
            name:                   'default',
            console:                2,
            monitor:                5,
            source_interface:       ['mgmt0'],
            time_stamp_units:       'seconds',
            logfile_name:           'testlogfile',
            logfile_severity_level: 3,
            logfile_size:           4098,
          }
        ]
      end
    end
  end

  describe '#update' do
    context 'syslog_settings is not empty' do
      let(:should_values) do
        {
          name:                   'default',
          console:                2,
          monitor:                5,
          source_interface:       ['mgmt0'],
          time_stamp_units:       'milliseconds',
          logfile_name:           'testlogfile',
          logfile_severity_level: 3,
          logfile_size:           4098,
        }
      end

      it 'performs the update' do
        allow(Cisco::SyslogSettings).to receive(:syslogsettings).and_return('default' => syslog_settings)
        expect(context).to receive(:notice).with(%r{Setting 'default'})
        expect(syslog_settings).to receive(:source_interface=).with('mgmt0')
        expect(syslog_settings).to receive(:console=).with(2)
        expect(syslog_settings).to receive(:monitor=).with(5)
        expect(syslog_settings).to receive(:time_stamp_units=).with('milliseconds')
        expect(syslog_settings).to receive(:logfile_name=).with('testlogfile', 3, 'size 4098')
        provider.update(context, 'default', should_values)
      end
    end
  end

  describe '#validate_should' do
    let(:should_values) do
      {
        name:                   'default',
        console:                2,
        monitor:                5,
        source_interface:       ['mgmt0'],
        time_stamp_units:       'milliseconds',
        logfile_name:           'testlogfile',
        logfile_severity_level: 3,
        logfile_size:           4098,
      }
    end

    it { expect { provider.validate_should(name: 'foo') }.to raise_error Puppet::ResourceError, "This provider only supports a namevar of 'default'." }
    it { expect { provider.validate_should(name: 'default') }.not_to raise_error }
    it { expect { provider.validate_should(should_values) }.not_to raise_error }
    it { expect { provider.validate_should(name: 'default', enable: true) }.to raise_error Puppet::ResourceError, %r{This provider does not support the 'enable' property. } }
    it { expect { provider.validate_should(name: 'default', vrf: 'foo') }.to raise_error Puppet::ResourceError, %r{This provider does not support the 'vrf' property. } }
  end

  describe '#validate_syslog_logfile' do
    it {
      expect {
        provider.validate_syslog_logfile(logfile_name: 'foo')
      }.to raise_error Puppet::ResourceError, %r{This provider requires that a logfile_name and logfile_severity_level are both specified in order }
    }
    it {
      expect {
        provider.validate_syslog_logfile(logfile_severity_level: 7)
      }.to raise_error Puppet::ResourceError, %r{This provider requires that a logfile_name and logfile_severity_level are both specified in order }
    }
    it {
      expect {
        provider.validate_syslog_logfile(logfile_name: 'unset')
      }.not_to raise_error
    }
    it {
      expect {
        provider.validate_syslog_logfile(logfile_severity_level: 'unset', logfile_name: 'foo')
      }.to raise_error Puppet::ResourceError, %r{This provider requires that a logfile_name is unset in order to unset logfile_severity_level}
    }
    it { expect { provider.validate_syslog_logfile(logfile_severity_level: 7, logfile_name: 'foo') }.not_to raise_error Puppet::ResourceError }
    it {
      expect {
        provider.validate_syslog_logfile(logfile_severity_level: 7, logfile_name: 'unset')
      }.to raise_error Puppet::ResourceError, %r{This provider does not support setting the logfile_severity_level when logfile_name is unset}
    }
    it {
      expect {
        provider.validate_syslog_logfile(logfile_size: 4098)
      }.to raise_error Puppet::ResourceError, %r{This provider requires that a logfile_name and logfile_severity_level are both specified in order }
    }
    it {
      expect {
        provider.validate_syslog_logfile(logfile_size: 4098, logfile_severity_level: 7)
      }.to raise_error Puppet::ResourceError, %r{This provider requires that a logfile_name and logfile_severity_level are both specified in order }
    }
    it {
      expect {
        provider.validate_syslog_logfile(logfile_size: 4098, logfile_name: 'foo')
      }.to raise_error Puppet::ResourceError, %r{This provider requires that a logfile_name and logfile_severity_level are both specified in order }
    }
    it {
      expect {
        provider.validate_syslog_logfile(logfile_size: 4098, logfile_severity_level: 7, logfile_name: 'foo')
      }.not_to raise_error Puppet::ResourceError
    }
  end

  describe '#tidy_up_syslog_logfile' do
    before(:each) do
      allow(Cisco::SyslogSettings).to receive(:syslogsettings).and_return('default' => syslog_settings)
    end
    context 'logfilename not supplied' do
      let(:should_values) do
        {
          name:                   'default',
          logfile_severity_level: 10,
          logfile_size:           4096,
        }
      end

      it 'uses logfilename from system settings' do
        allow(syslog_settings).to receive(:logfile_name).and_return('foo')
        allow(syslog_settings).to receive(:logfile_severity_level).and_return(7)
        expect(syslog_settings).to receive(:logfile_name=).with('foo', 10, 'size 4096')
        provider.tidy_up_syslog_logfile(should_values)
      end
    end
    context 'logfile_severity_level not supplied' do
      let(:should_values) do
        {
          name:         'default',
          logfile_name: 'bar',
          logfile_size: 4096,
        }
      end

      it 'uses logfilename from system settings' do
        allow(syslog_settings).to receive(:logfile_name).and_return('foo')
        allow(syslog_settings).to receive(:logfile_severity_level).and_return(7)
        expect(syslog_settings).to receive(:logfile_name=).with('bar', 7, 'size 4096')
        provider.tidy_up_syslog_logfile(should_values)
      end
    end
    context 'logfile_size not supplied' do
      let(:should_values) do
        {
          name:                   'default',
          logfile_name:           'bar',
          logfile_severity_level: 10,
        }
      end

      it 'uses logfilename from system settings' do
        allow(syslog_settings).to receive(:logfile_name).and_return('foo')
        allow(syslog_settings).to receive(:logfile_severity_level).and_return(7)
        expect(syslog_settings).to receive(:logfile_name=).with('bar', 10, '')
        provider.tidy_up_syslog_logfile(should_values)
      end
    end
    context 'logfile_size set to -1' do
      let(:should_values) do
        {
          name:                   'default',
          logfile_name:           'bar',
          logfile_severity_level: 10,
          logfile_size:           -1,
        }
      end

      it 'uses logfilename from system settings' do
        allow(syslog_settings).to receive(:logfile_name).and_return('foo')
        allow(syslog_settings).to receive(:logfile_severity_level).and_return(7)
        expect(syslog_settings).to receive(:logfile_name=).with('bar', 10, '')
        provider.tidy_up_syslog_logfile(should_values)
      end
    end
    context 'logfile_name set to unset' do
      let(:should_values) do
        {
          name:                   'default',
          logfile_name:           'unset',
          logfile_severity_level: 10,
          logfile_size:           -1,
        }
      end

      it 'uses logfilename from system settings' do
        allow(syslog_settings).to receive(:logfile_name).and_return('foo')
        allow(syslog_settings).to receive(:logfile_severity_level).and_return(7)
        expect(syslog_settings).to receive(:logfile_name=).with(nil, nil, '')
        provider.tidy_up_syslog_logfile(should_values)
      end
    end
  end

  canonicalize_data = [
    {
      desc:      '`resources` contains -1 values',
      resources: [{
        name:                   'default',
        console:                -1,
        monitor:                -1,
        source_interface:       ['unset'],
        time_stamp_units:       'seconds',
        logfile_name:           'unset',
        logfile_severity_level: -1,
        logfile_size:           -1,
      }],
      results:   [{
        name:                   'default',
        console:                'unset',
        monitor:                'unset',
        source_interface:       ['unset'],
        time_stamp_units:       'seconds',
        logfile_name:           'unset',
        logfile_severity_level: 'unset',
        logfile_size:           'unset',
      }],
    },
    {
      desc:      '`resources` contains unset values',
      resources: [{
        name:                   'default',
        console:                'unset',
        monitor:                'unset',
        source_interface:       ['unset'],
        time_stamp_units:       'seconds',
        logfile_name:           'unset',
        logfile_severity_level: 'unset',
        logfile_size:           'unset',
      }],
      results:   [{
        name:                   'default',
        console:                'unset',
        monitor:                'unset',
        source_interface:       ['unset'],
        time_stamp_units:       'seconds',
        logfile_name:           'unset',
        logfile_severity_level: 'unset',
        logfile_size:           'unset',
      }],
    },
    {
      desc:      '`resources` contains regular values',
      resources: [{
        name:                   'default',
        console:                2,
        monitor:                5,
        source_interface:       ['mgmt0'],
        time_stamp_units:       'milliseconds',
        logfile_name:           'testlogfile',
        logfile_severity_level: 3,
        logfile_size:           4098,
      }],
      results:   [{
        name:                   'default',
        console:                2,
        monitor:                5,
        source_interface:       ['mgmt0'],
        time_stamp_units:       'milliseconds',
        logfile_name:           'testlogfile',
        logfile_severity_level: 3,
        logfile_size:           4098,
      }],
    },
  ]

  describe '#canonicalize' do
    canonicalize_data.each do |test|
      context "#{test[:desc]}" do
        it 'returns canonicalized value' do
          expect(provider.canonicalize(context, test[:resources])).to eq(test[:results])
        end
      end
    end
  end
end
