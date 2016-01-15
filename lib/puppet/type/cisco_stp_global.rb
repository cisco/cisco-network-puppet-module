# Manages the Cisco Spanning-tree Global configuration resource.
#
# Jan 2016
#
# Copyright (c) 2013-2015 Cisco and/or its affiliates.
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
    Example:
    cisco_portchannel_global { 'default':
      bpdufilter        => true,
      bpduguard         => true,
      bridge_assurance  => false,
      domain            => 100,
      fcoe              => false,
      loopguard         => true,
      mode              => 'mst',
      mst_forward_time  => 25,
      mst_hello_time    => 5,
      mst_max_age       => 35,
      mst_max_hops      => 200,
      mst_name          => 'nexus',
      mst_revision      => 34,
      pathcost          => 'long',
    }
  "
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
    desc 'Domain'

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

  newproperty(:pathcost) do
    desc 'Method to calculate default port path cost'

    newvalues(:long, :short, :default)
  end # property pathcost
end # Puppet::Type.newtype
