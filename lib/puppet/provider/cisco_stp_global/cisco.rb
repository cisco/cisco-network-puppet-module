# The Cisco provider for cisco_stp_global
#
# January, 2016
#
# Copyright (c) 2014-2016 Cisco and/or its affiliates.
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

begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end

Puppet::Type.type(:cisco_stp_global).provide(:cisco) do
  desc 'The new Cisco provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  STP_GLOBAL_NON_BOOL_PROPS = [
    :mode,
    :domain,
    :mst_forward_time,
    :mst_hello_time,
    :mst_max_age,
    :mst_max_hops,
    :mst_name,
    :mst_revision,
    :pathcost,
  ]
  STP_GLOBAL_BOOL_PROPS = [
    :bpdufilter,
    :bpduguard,
    :bridge_assurance,
    :fcoe,
    :loopguard,
  ]
  STP_GLOBAL_ARRAY_FLAT_PROPS = [
    :bd_designated_priority,
    :bd_forward_time,
    :bd_hello_time,
    :bd_max_age,
    :bd_priority,
    :bd_root_priority,
    :mst_designated_priority,
    :mst_inst_vlan_map,
    :mst_priority,
    :mst_root_priority,
    :vlan_designated_priority,
    :vlan_forward_time,
    :vlan_hello_time,
    :vlan_max_age,
    :vlan_priority,
    :vlan_root_priority,
  ]
  STP_GLOBAL_ALL_PROPS = STP_GLOBAL_NON_BOOL_PROPS + STP_GLOBAL_BOOL_PROPS +
                         STP_GLOBAL_ARRAY_FLAT_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            STP_GLOBAL_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@nu',
                                            STP_GLOBAL_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:array_flat, self, '@nu',
                                            STP_GLOBAL_ARRAY_FLAT_PROPS)

  def initialize(value={})
    super(value)
    @nu = Cisco::StpGlobal.globals[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of cisco_stp_global'
  end

  def self.properties_get(global_id, nu_obj)
    debug "Checking instance, global #{global_id}"
    current_state = {
      name: global_id
    }

    # Call node_utils getter for each property
    STP_GLOBAL_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    STP_GLOBAL_BOOL_PROPS.each do |prop|
      val = nu_obj.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end
    STP_GLOBAL_ARRAY_FLAT_PROPS.each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    # nested array properties
    current_state[:bd_designated_priority] = nu_obj.bd_designated_priority
    current_state[:bd_forward_time] = nu_obj.bd_forward_time
    current_state[:bd_hello_time] = nu_obj.bd_hello_time
    current_state[:bd_max_age] = nu_obj.bd_max_age
    current_state[:bd_priority] = nu_obj.bd_priority
    current_state[:bd_root_priority] = nu_obj.bd_root_priority
    current_state[:mst_designated_priority] = nu_obj.mst_designated_priority
    current_state[:mst_inst_vlan_map] = nu_obj.mst_inst_vlan_map
    current_state[:mst_priority] = nu_obj.mst_priority
    current_state[:mst_root_priority] = nu_obj.mst_root_priority
    current_state[:vlan_designated_priority] = nu_obj.vlan_designated_priority
    current_state[:vlan_forward_time] = nu_obj.vlan_forward_time
    current_state[:vlan_hello_time] = nu_obj.vlan_hello_time
    current_state[:vlan_max_age] = nu_obj.vlan_max_age
    current_state[:vlan_priority] = nu_obj.vlan_priority
    current_state[:vlan_root_priority] = nu_obj.vlan_root_priority
    new(current_state)
  end # self.properties_get

  def self.instances
    globals = []
    Cisco::StpGlobal.globals.each do |global_id, nu_obj|
      globals << properties_get(global_id, nu_obj)
    end
    globals
  end

  def self.prefetch(resources)
    globals = instances

    resources.keys.each do |id|
      provider = globals.find { |nu_obj| nu_obj.instance_name == id }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def instance_name
    name
  end

  def properties_set
    STP_GLOBAL_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
  end

  def bd_designated_priority=(should_list)
    should_list = @nu.default_bd_designated_priority if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:bd_designated_priority] = should_list
  end

  def bd_forward_time=(should_list)
    should_list = @nu.default_bd_forward_time if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:bd_forward_time] = should_list
  end

  def bd_hello_time=(should_list)
    should_list = @nu.default_bd_hello_time if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:bd_hello_time] = should_list
  end

  def bd_max_age=(should_list)
    should_list = @nu.default_bd_max_age if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:bd_max_age] = should_list
  end

  def bd_priority=(should_list)
    should_list = @nu.default_bd_priority if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:bd_priority] = should_list
  end

  def bd_root_priority=(should_list)
    should_list = @nu.default_bd_root_priority if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:bd_root_priority] = should_list
  end

  def mst_designated_priority=(should_list)
    should_list = @nu.default_mst_designated_priority if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:mst_designated_priority] = should_list
  end

  def mst_inst_vlan_map=(should_list)
    should_list = @nu.default_mst_inst_vlan_map if should_list[0] == :default
    # check for overlapping arrays in should_list
    # however, in this case, the range is 2nd value unlike
    # other range based params so, reverse the arrays and
    # check the overlap on the ranges
    # do a deep copy of the array first
    llist = []
    should_list.each do |element|
      llist << element.dup
    end
    # swap elements of the new array
    llist.each do |elem|
      tmp = elem[1]
      elem[1] = elem[0]
      elem[0] = tmp
    end
    PuppetX::Cisco::Utils.fail_array_overlap(llist)
    @property_flush[:mst_inst_vlan_map] = should_list
  end

  def mst_priority=(should_list)
    should_list = @nu.default_mst_priority if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:mst_priority] = should_list
  end

  def mst_root_priority=(should_list)
    should_list = @nu.default_mst_root_priority if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:mst_root_priority] = should_list
  end

  def vlan_designated_priority=(should_list)
    should_list = @nu.default_vlan_designated_priority if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:vlan_designated_priority] = should_list
  end

  def vlan_forward_time=(should_list)
    should_list = @nu.default_vlan_forward_time if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:vlan_forward_time] = should_list
  end

  def vlan_hello_time=(should_list)
    should_list = @nu.default_vlan_hello_time if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:vlan_hello_time] = should_list
  end

  def vlan_max_age=(should_list)
    should_list = @nu.default_vlan_max_age if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:vlan_max_age] = should_list
  end

  def vlan_priority=(should_list)
    should_list = @nu.default_vlan_priority if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:vlan_priority] = should_list
  end

  def vlan_root_priority=(should_list)
    should_list = @nu.default_vlan_root_priority if should_list[0] == :default
    # check for overlapping arrays in should_list
    PuppetX::Cisco::Utils.fail_array_overlap(should_list)
    @property_flush[:vlan_root_priority] = should_list
  end

  def flush
    properties_set
  end
end # Puppet::Type
