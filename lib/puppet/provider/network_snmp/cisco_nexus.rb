# Copyright (c) 2018 Cisco and/or its affiliates.
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
# Implementation for the network_snmp type using the Resource API.
class Puppet::Provider::NetworkSnmp::CiscoNexus
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, _names=nil)
    require 'cisco_node_utils'

    @network_snmp = Cisco::SnmpServer.new

    current_state = {
      name:     'default',
      enable:   @network_snmp.protocol? ? true : false,
      contact:  @network_snmp.contact.empty? ? 'unset' : @network_snmp.contact,
      location: @network_snmp.location.empty? ? 'unset' : @network_snmp.location,
    }

    [current_state]
  end

  def set(context, changes)
    changes.each do |name, change|
      should = change[:should]
      context.updating(name) do
        update(context, name, should)
      end
    end
  end

  def create(_context, name, should)
    raise Puppet::ResourceError, "Can't create new SNMP server settings '#{name}' with #{should.inspect}"
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    @network_snmp = Cisco::SnmpServer.new
    if should[:contact]
      @network_snmp.contact = should[:contact] == 'unset' ? '' : should[:contact]
    end
    if should[:location]
      @network_snmp.location = should[:location] == 'unset' ? '' : should[:location]
    end
    @network_snmp.protocol = should[:enable] unless should[:enable].nil?
  end

  def delete(_context, name)
    raise Puppet::ResourceError, "Can't delete SNMP server settings '#{name}'"
  end
end
