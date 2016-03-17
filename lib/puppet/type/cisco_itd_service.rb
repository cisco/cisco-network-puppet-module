# Manages a Cisco ItdService.
#
# March 2016
#
# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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
Puppet::Type.newtype(:cisco_itd_service) do
  @doc = "Manages a Cisco ItdService.

  Any resource dependency should be run before the interface resource.

  cisco_itd_service {\"<name>\":
    ..attributes..
  }

  <name> is the complete name of the service.

  Example:
    cisco_itd_service {\"my_service\":
     ensure                        => present,
     access_list                   => \"my_access1\",
     device_group                  => \"my_group\",
     exclude_access_list           => \"my_access2\",
     failaction                    => true,
     ingress_interface             => [['vlan 2', '1.1.1.1'], ['ethernet 1/1', '2.2.2.2']],
     load_bal_buckets              => 256,
     load_bal_enable               => true,
     load_bal_mask_pos             => 5,
     load_bal_method_bundle_hash   => \"ip-l4port\",
     load_bal_method_bundle_select => \"src\",
     load_bal_method_end_port      => 100,
     load_bal_method_proto         => \"tcp\",
     load_bal_method_start_port    => 50,
     nat_destination               => false,
     peer_local                    => \"ser\",
     peer_vdc                      => ['vdc1', 'ser'],
     shutdown                      => true,
     virtual_ip                    => ['ip 1.1.1.1 2.2.2.2', 'ip 2.2.2.2 255.0.0.0 udp 1000 device-group myGroup1'],
     vrf                           => \"myvrf\",
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
      /^(\S+)$/,
      [
        [:itdser, identity]
      ],
    ]
    patterns
  end

  newparam(:itdser, namevar: :true) do
    desc "Name of the itd service. Valid value is a string of
          non-whitespace characters. It is case-sensitive"
    munge(&:strip)
  end # param name

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:access_list) do
    desc "ITD access-list name. Valid values are string, keyword
         'default'. "

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property access_list

  newproperty(:device_group) do
    desc "ITD device-group name. Valid values are string, keyword
         'default'. "

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property device_group

  newproperty(:exclude_access_list) do
    desc "ITD exclude-access-list name. Valid values are string, keyword
         'default'. "

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property exclude_access_list

  newproperty(:failaction) do
    desc 'ITD failaction'

    newvalues(:true, :false, :default)
  end # property failaction

  newproperty(:ingress_interface, array_matching: :all) do
    format = '[[interface_name, next_hop], [intf, nh]]'
    desc 'An array of [interface_name, next_hop] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
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
  end # property ingress_interface

  newproperty(:load_bal_buckets) do
    desc 'ITD load balance buckets for traffic distribution'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value) unless value == :default
      rescue
        raise 'load_bal_buckets must be a valid integer, or default.'
      end
      value
    end
  end # property load_bal_buckets

  newproperty(:load_bal_enable) do
    desc 'ITD load balance enable'

    newvalues(:true, :false, :default)
  end # property failaction

  newproperty(:load_bal_mask_pos) do
    desc 'ITD load balance mask position'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value)
      rescue
        raise 'load_bal_mask_pos must be a valid integer, or default.'
      end
      value
    end
  end # property load_bal_mask_pos

  newproperty(:load_bal_method_bundle_hash) do
    desc 'ITD load balance bundle hash'

    newvalues(:default, :ip, :'ip-l4port')
  end # property load_bal_method_bundle_hash

  newproperty(:load_bal_method_bundle_select) do
    desc 'ITD load balance bundle select'

    newvalues(:default, :src, :dst)
  end # property load_bal_method_bundle_select

  newproperty(:load_bal_method_end_port) do
    desc 'ITD load balance protocol port end range'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value)
      rescue
        raise 'load_bal_method_end_port must be a valid integer, or default.'
      end
      value
    end
  end # property load_bal_method_end_port

  newproperty(:load_bal_method_proto) do
    desc 'ITD load balance bundle select'

    newvalues(:default, :tcp, :udp)
  end # property load_bal_method_proto

  newproperty(:load_bal_method_start_port) do
    desc 'ITD load balance protocol port start range'

    munge do |value|
      value = :default if value == 'default'
      begin
        value = Integer(value)
      rescue
        raise 'load_bal_method_start_port must be a valid integer, or default.'
      end
      value
    end
  end # property load_bal_method_start_port

  newproperty(:nat_destination) do
    desc 'ITD Destination NAT'

    newvalues(:true, :false, :default)
  end # property nat_destination

  newproperty(:peer_local) do
    desc "ITD Peer involved in sandwich mode. Valid values are string,
         ' keyword default'. "

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property peer_local

  newproperty(:peer_vdc, array_matching: :all) do
    format = '[vdc_name, service_name]'
    desc 'An array of [vdc_name, service_name]'\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
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
        value
      end
    end
  end # property peer_vdc

  newproperty(:shutdown) do
    desc 'ITD service shutdown'

    newvalues(:true, :false, :default)
  end # property shutdown

  newproperty(:virtual_ip, array_matching: :all) do
    format = '[virt_ip_str1, virt_ip_str2]'
    desc 'An array of strings'\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
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
        value
      end
    end
  end # property virtual_ip

  newproperty(:vrf) do
    desc "ITD service vrf. Valid values are string, keyword
         'default'. "

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property vrf
end
