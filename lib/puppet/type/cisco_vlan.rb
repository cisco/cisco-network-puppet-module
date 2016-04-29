# Manages a Cisco VLAN.
#
# April 2013
#
# Copyright (c) 2013-2016 Cisco and/or its affiliates.
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

begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end

Puppet::Type.newtype(:cisco_vlan) do
  @doc = "Manages a Cisco VLAN.

  cisco_vlan {\"<vlan>\":
    ..attributes..
  }

  <vlan> is the id of the vlan.

  Example:
    cisco_vlan {\"200\":
      ensure     => present,
      vlan_name  => 'red',
      mapped_vni => 20000,
      state      => 'active',
      shutdown   => 'true',
      private_vlan_type => 'primary',
      private_vlan_association => ['101-104']
      fabric_control   => 'true',
    }"

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\d+)$/,
      [
        [:vlan, identity]
      ],
    ]
    patterns
  end

  newparam(:vlan, namevar: true) do
    desc 'ID of the Virtual LAN. Valid values are integer.'

    validate do |id|
      range = *(2..4093)
      internal = *(3968..4047)
      valid_ids = range - internal

      if id.to_i == 1
        warning('Cannot make changes to the default VLAN.')
      elsif !valid_ids.include?(id.to_i)
        fail('ID is not in the valid range.')
      end # if
    end
  end # param id

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:vlan_name) do
    desc "The name of the VLAN. Valid values are string, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = String(value) unless value == :default
      rescue
        raise 'Name is not a valid string.'
      end # rescue
      value
    end
  end # property name

  newproperty(:mapped_vni) do
    desc 'The VNI id that is mapped to the VLAN. Valid values are integer.'
    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'mapped_vni must be an integer.'
      end # rescue
      value
    end
  end # property name

  newproperty(:mode) do
    desc 'Mode of the VLAN. Valid values are "CE" (Classical Ethernet) or
          "fabricpath". Default value is CE'

    newvalues(
      :CE,
      :fabricpath,
      :default)
  end # property mode

  newproperty(:state) do
    desc 'State of the VLAN.'

    newvalues(
      :active,
      :suspend,
      :default)
  end # property state

  newproperty(:shutdown) do
    desc 'whether or not the vlan is shutdown'

    newvalues(
      :true,
      :false,
      :default)
  end # property shutdown

  newproperty(:private_vlan_type) do
    desc 'The private vlan type for VLAN. Valid values are string
          primary, isolated, community'

    match_error = 'must be a string. Valid values primary,isolated,community'
    valid_input = %w(primary isolated community)

    validate do |value|
      unless value.kind_of? String
        fail "Private vlan type '#{value}' #{match_error}"
      end

      unless valid_input.include?(value) ||
             value == 'default' || value == :default
        fail "Private vlan type '#{value}' #{match_error}"
      end
    end

    munge do |value|
      begin
        value = :default if value == 'default'
        value = String(value) unless value == :default
      rescue
        raise 'Type is not a valid string.'
      end # rescue
      value
    end
  end # property private_vlan_type

  newproperty(:private_vlan_association, array_matching: :all) do
    desc 'The private association for the primary vlan.'\
         "Valid values match format ['vlans']."

    match_error = "must be of format ['vlans'] with vlans as integer"
    validate do |value|
      fail "Vlan '#{value}' #{match_error}" unless
            /^(\s*\d+\s*[-,\d\s]*\d+\s*)$/.match(value).to_s == value ||
            value == 'default' || value == :default
    end

    munge do |value|
      value == 'default' ? :default : value.to_s.gsub(/\s+/, '')
    end

    def insync?(is)
      return true if should == [:default] && is == [:default]
      return false if should == [:default]
      # For pvlan association we need to massage the should value
      # since the returned is value is a flat array of vlans.
      result = PuppetX::Cisco::PvlanUtils.prepare_list(should[0])

      (is.size == result.size && is.sort == result.sort)
    end
  end # property private_vlan_association

  newproperty(:fabric_control) do
    desc %(Specifies this VLAN as the fabric control VLAN. Only one bridge-domain or VLAN can be configured as fabric-control.
           Valid values are true, false.)

    newvalues(
      :true,
      :false,
      :default)
  end # property fabric_control
end # Puppet::Type.newtype
