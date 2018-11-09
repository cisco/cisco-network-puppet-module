# Manages the Cisco Spanning-tree Global configuration resource.
#
# June 2018
#
# Copyright (c) 2013-2018 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_stp_global) do
  @doc = "
    Manages the Cisco Spanning-tree Global configuration resource.
    cisco_stp_global {'default':
      ..attributes..
    }
    'default' is only acceptable name for this global config object.

    Range based parameters (for ex. see bd_designated_priority below)
    are nested array of arrays. These are basically range to value pairs.
    So for bd_designated_priority, the bridge domain range 2 to 42 will be set
    to 40960 and 83to 92 and 1000 to 2300 will be set to 53248

    Example:
    cisco_stp_global { 'default':
      bd_designated_priority       => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
      bd_forward_time              => [['2-42', '26'], ['83-92,1000-2300', '20']],
      bd_hello_time                => [['2-42', '6'], ['83-92,1000-2300', '9']],
      bd_max_age                   => [['2-42', '26'], ['83-92,1000-2300', '20']],
      bd_priority                  => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
      bd_root_priority             => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
      bpdufilter                   => true,
      bpduguard                    => true,
      bridge_assurance             => false,
      domain                       => 100,
      fcoe                         => false,
      loopguard                    => true,
      mode                         => 'mst',
      mst_designated_priority      => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
      mst_forward_time             => 25,
      mst_hello_time               => 5,
      mst_inst_vlan_map            => [['2', '6-47'], ['92', '120-400']],
      mst_max_age                  => 35,
      mst_max_hops                 => 200,
      mst_name                     => 'nexus',
      mst_priority                 => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
      mst_revision                 => 34,
      mst_root_priority            => [['2-42', '40960'], ['83-92,1000-2300', '53248']],
      pathcost                     => 'long',
      vlan_designated_priority     => [['1-42', '40960'], ['83-92,1000-2300', '53248']],
      vlan_forward_time            => [['1-42', '19'], ['83-92,1000-2300', '13']],
      vlan_hello_time              => [['1-42', '10'], ['83-92,1000-2300', '6']],
      vlan_max_age                 => [['1-42', '21'], ['83-92,1000-2300', '13']],
      vlan_priority                => [['1-42', '40960'], ['83-92,1000-2300', '53248']],
      vlan_root_priority           => [['1-42', '40960'], ['83-92,1000-2300', '53248']],
    }
  "

  apply_to_all

  ###################
  # Resource Naming #
  ###################

  newparam(:name, namevar: :true) do
    desc 'ID of the stp global config. Valid values are default.'

    validate do |inst_name|
      fail "only acceptable name is 'default'" if inst_name != 'default'
    end
  end # param id

  ##############
  # Attributes #
  ##############

  newproperty(:bd_designated_priority, array_matching: :all) do
    format = '[[bd_inst_list, designated_priority], [bdil, dp]]'
    desc 'An array of [bd_inst_list, designated_priority] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default'
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property bd_designated_priority

  newproperty(:bd_forward_time, array_matching: :all) do
    format = '[[bd_inst_list, forward_time], [bdil, ft]]'
    desc 'An array of [bd_inst_list, forward_time] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default' || elem[1].to_i == 15
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property bd_forward_time

  newproperty(:bd_hello_time, array_matching: :all) do
    format = '[[bd_inst_list, hello_time], [bdil, ht]]'
    desc 'An array of [bd_inst_list, hello_time] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default' || elem[1].to_i == 2
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property bd_hello_time

  newproperty(:bd_max_age, array_matching: :all) do
    format = '[[bd_inst_list, max_age], [bdil, ma]]'
    desc 'An array of [bd_inst_list, max_age] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default' || elem[1].to_i == 20
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property bd_max_age

  newproperty(:bd_priority, array_matching: :all) do
    format = '[[bd_inst_list, priority], [bdil, pri]]'
    desc 'An array of [bd_inst_list, priority] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default' || elem[1].to_i == 32_768
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property bd_priority

  newproperty(:bd_root_priority, array_matching: :all) do
    format = '[[bd_inst_list, root_priority], [bdil, pri]]'
    desc 'An array of [bd_inst_list, root_priority] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default'
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property bd_root_priority

  newproperty(:bpdufilter) do
    desc 'Edge port (portfast) bpdu filter'

    newvalues(:true, :false, :default)
  end # property bpdufilter

  newproperty(:bpduguard) do
    desc 'Edge port (portfast) bpdu guard'

    newvalues(:true, :false, :default)
  end # property bpduguard

  newproperty(:bridge_assurance) do
    desc 'Bridge Assurance on all network ports'

    newvalues(:true, :false, :default)
  end # property bridge_assurance

  newproperty(:domain) do
    desc 'Spanning Tree domain'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'Domain must be a valid integer, or default.'
      end
      value
    end
  end # property domain

  newproperty(:fcoe) do
    desc 'STP for FCoE VLAN'

    newvalues(:true, :false, :default)
  end # property fcoe

  newproperty(:loopguard) do
    desc 'Enable loopguard by default on all ports'

    newvalues(:true, :false, :default)
  end # property loopguard

  newproperty(:mode) do
    desc 'Operating mode'

    newvalues(:mst, :'rapid-pvst', :default)
  end # property mode

  newproperty(:mst_designated_priority, array_matching: :all) do
    format = '[[mst_inst_list, designated_priority], [mil, pri]]'
    desc 'An array of [mst_inst_list, designated_priority] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default'
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property mst_designated_priority

  newproperty(:mst_forward_time) do
    desc 'Forward delay for the spanning tree'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'mst forward_time must be a valid integer, or default.'
      end
      value
    end
  end # property mst_forward_time

  newproperty(:mst_hello_time) do
    desc 'Hello interval for the spanning tree'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'mst hello_time must be a valid integer, or default.'
      end
      value
    end
  end # property mst_hello_time

  newproperty(:mst_inst_vlan_map, array_matching: :all) do
    format = '[[mst_inst, vlan_range], [mi, vr]]'
    desc 'An array of [mst_inst, vlan_range] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[0] == '0' || elem[1] == 'default'
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property mst_inst_vlan_map

  newproperty(:mst_max_age) do
    desc 'Max age interval for the spanning tree'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'mst max_age must be a valid integer, or default.'
      end
      value
    end
  end # property mst_max_age

  newproperty(:mst_max_hops) do
    desc 'Max hops value for the spanning tree'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'mst max_hops must be a valid integer, or default.'
      end
      value
    end
  end # property mst_max_hops

  newproperty(:mst_name) do
    desc "Configuration name. Valid values are string, keyword
         'default'. "

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property mst_name

  newproperty(:mst_priority, array_matching: :all) do
    format = '[[mst_inst_list, priority], [mil, pri]]'
    desc 'An array of [mst_inst_list, priority] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default' || elem[1].to_i == 32_768
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property mst_priority

  newproperty(:mst_revision) do
    desc 'Configuration revision number'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'mst revision must be a valid integer, or default.'
      end
      value
    end
  end # property mst_revision

  newproperty(:mst_root_priority, array_matching: :all) do
    format = '[[mst_inst_list, root_priority], [mil, pri]]'
    desc 'An array of [mst_inst_list, root_priority] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default'
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property mst_root_priority

  newproperty(:pathcost) do
    desc 'Method to calculate default port path cost'

    newvalues(:long, :short, :default)
  end # property pathcost

  newproperty(:vlan_designated_priority, array_matching: :all) do
    format = '[[vlan_inst_list, designated_priority], [vil, pri]]'
    desc 'An array of [vlan_inst_list, designated_priority] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default'
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property vlan_designated_priority

  newproperty(:vlan_forward_time, array_matching: :all) do
    format = '[[vlan_inst_list, forward_time], [vil, ft]]'
    desc 'An array of [vlan_inst_list, forward_time] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default' || elem[1].to_i == 15
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property vlan_forward_time

  newproperty(:vlan_hello_time, array_matching: :all) do
    format = '[[vlan_inst_list, hello_time], [vil, ht]]'
    desc 'An array of [vlan_inst_list, hello_time] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default' || elem[1].to_i == 2
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property vlan_hello_time

  newproperty(:vlan_max_age, array_matching: :all) do
    format = '[[vlan_inst_list, max_age], [vil, ma]]'
    desc 'An array of [vlan_inst_list, max_age] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default' || elem[1].to_i == 20
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property vlan_max_age

  newproperty(:vlan_priority, array_matching: :all) do
    format = '[[vlan_inst_list, priority], [vil, pri]]'
    desc 'An array of [vlan_inst_list, priority] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default' || elem[1].to_i == 32_768
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    def should_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property vlan_priority

  newproperty(:vlan_root_priority, array_matching: :all) do
    format = '[[vlan_inst_list, root_priority], [vil, pri]]'
    desc 'An array of [vlan_inst_list, root_priority] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      slist = []
      should.each do |elem|
        slist << elem unless elem[1] == 'default'
      end
      (is.size == slist.size && is.sort == slist.sort)
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property vlan_root_priority
end # Puppet::Type.newtype
