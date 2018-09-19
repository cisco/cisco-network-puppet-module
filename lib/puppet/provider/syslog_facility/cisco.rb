# August, 2018
#
# Copyright (c) 2014-2018 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'cisco_node_utils' if Puppet.features.cisco_node_utils?
begin
  require 'puppet_x/cisco/autogen'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'autogen.rb'))
end

Puppet::Type.type(:syslog_facility).provide(:cisco) do
  desc 'The Cisco provider for syslog_facility.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  SYSLOG_FACILITY_ALL_PROPS = [
    :level
  ]

  def initialize(value={})
    super(value)
    @syslogfacility = Cisco::SyslogFacility.facilities[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of syslog_facility'
  end

  def self.properties_get(facility, v)
    debug "Checking instance, syslog_facility #{facility}"

    current_state = {
      ensure: :present,
      name:   v.facility,
      level:  v.level,
    }

    new(current_state)
  end # self.properties_get

  def self.instances
    facilities = []
    Cisco::SyslogFacility.facilities.each do |facility, v|
      facilities << properties_get(facility, v)
    end

    facilities
  end

  def self.prefetch(resources)
    facilities = instances

    resources.keys.each do |id|
      provider = facilities.find { |facility| facility.name.to_s == id.to_s }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def validate
    fail ArgumentError,
         'Severity level must be integer 0-7.' unless @resource[:level].between?(0, 7)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @syslogfacility.destroy
      @syslogfacility = nil
    else
      validate
      # Create new instance with configured options
      opts = { 'facility' => @resource[:name] }
      SYSLOG_FACILITY_ALL_PROPS.each do |prop|
        next unless @resource[prop]
        opts[prop.to_s] = @resource[prop].to_s
      end

      begin
        @syslogfacility = Cisco::SyslogFacility.new(opts)
      rescue Cisco::CliError => e
        error "Unable to set new values: #{e.message}"
      end
    end
  end
end # Puppet::Type
