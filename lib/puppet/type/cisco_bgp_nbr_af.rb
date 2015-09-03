# Manages BGP Neighbor Address-Family configuration.
#
# August 2015
#
# Copyright (c) 2015 Cisco and/or its affiliates.
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

require 'ipaddr'

Puppet::Type.newtype(:cisco_bgp_nbr_af) do
  @doc = "Manages BGP Neighbor Address-Family configuration.

  ~~~puppet
  cisco_bgp_nbr_af { '<title>':
    ..attributes..
  }
  ~~~

  `<title>` is the title of the bgp_nbr_af resource.

  Example:

  ~~~puppet
    cisco_bgp_nbr_af { 'raleigh':
      ensure                                 => present,
      asn                                    => '1'
      vrf                                    => 'default',
      nbr                                    => '10.1.1.1',
      afi                                    => 'ipv4',
      safi                                   => 'unicast',
      advertise_map_exist                    => ['adv_map', 'my_exist'],
      advertise_map_non_exist                => ['foo_map', 'my_non_exist'],
      allowas_in                             => true,
      allowas_in_max                         => 5,
      as_override                            => true,
      cap_add_paths_receive                  => true,
      cap_add_paths_send                     => true,
      cap_add_paths_send_disable             => true,
      default_originate                      => true,
      default_originate_route_map            => 'my_def_map',
      disable_peer_as_check                  => true,
      filter_list_in                         => 'flin',
      filter_list_out                        => 'flout',
      max_prefix_limit                       => 100,
      max_prefix_threshold                   => 50,
      max_prefix_interval                    => 30,
      next_hop_self                          => 'true',
      next_hop_third_party                   => false,
      route_reflector_client                 => true,
      send_community                         => 'extended',
      soft_reconfiguration_in                => true,
      soft_reconfiguration_in_always         => true,
      soo                                    => '3:3',
      suppress_inactive                      => true,
      unsuppress_map                         => 'unsup_map',
      weight                                 => 30,
    }
  ~~~

  Example Title Patterns:

  ~~~puppet
    cisco_bgp { 'new_york':
      ensure                                 => present,
      asn                                    => '1'
      vrf                                    => 'red',
      nbr                                    => '10.1.1.1',
      afi                                    => 'ipv4',
      safi                                   => 'unicast',
  ~~~

  ~~~puppet
    cisco_bgp { '1':
      ensure                                 => present,
      vrf                                    => 'red',
      nbr                                    => '10.1.1.1',
      afi                                    => 'ipv4',
      safi                                   => 'unicast',
  ~~~

  ~~~puppet
    cisco_bgp { '1 red':
      ensure                                 => present,
      nbr                                    => '10.1.1.1',
      afi                                    => 'ipv4',
      safi                                   => 'unicast',
  ~~~

  ~~~puppet
    cisco_bgp { '1 red 10.1.1.1':
      ensure                                 => present,
      afi                                    => 'ipv4',
      safi                                   => 'unicast',
  ~~~

  ~~~puppet
    cisco_bgp { '1 red 10.1.1.1 ipv4':
      ensure                                 => present,
      safi                                   => 'unicast',
  ~~~

  ~~~puppet
    cisco_bgp { '1 red 10.1.1.1 ipv4 unicast':
      ensure                                 => present,
  ~~~

  "

  ###################
  # Resource Naming #
  ###################
  # Parse out the title to fill in the attributes in these patterns. These
  # attributes can be overwritten later.

  def self.title_patterns
    identity = lambda { |x| x }
    [
      [
        /^(\d+|\d+\.\d+)$/,
        [
          [:asn, identity]
        ]
      ],
      [
        /^(\d+|\d+\.\d+) (\S+)$/,
        [
          [:asn, identity],
          [:vrf, identity]
        ]
      ],
      [
        /^(\d+|\d+\.\d+) (\S+) (\S+)$/,
        [
          [:asn, identity],
          [:vrf, identity],
          [:nbr, identity]
        ]
      ],
      [
        /^(\d+|\d+\.\d+) (\S+) (\S+) (\S+)$/,
        [
          [:asn, identity],
          [:vrf, identity],
          [:nbr, identity],
          [:afi, identity]
        ]
      ],
      [
        /^(\d+|\d+\.\d+) (\S+) (\S+) (\S+) (\S+)$/,
        [
          [:asn, identity],
          [:vrf, identity],
          [:nbr, identity],
          [:afi, identity],
          [:safi, identity]
        ]
      ],
      [
        /^(\S+)$/,
        [
          [:name, identity]
        ]
      ],
    ]
  end

  ##############
  # Parameters #
  ##############

  ensurable

  # Only needed to satisfy name parameter.
  newparam(:name) do
  end

  newparam(:asn, :namevar => true) do
    desc "BGP autonomous system number.  Valid values are String, Integer in
          ASPLAIN or ASDOT notation"
    validate do |value|
      unless /^(\d+|\d+\.\d+)$/.match(value.to_s)
        fail("BGP asn #{value} must be specified in ASPLAIN or ASDOT notation")
      end
    end

    # Convert BGP ASN ASDOT+ to ASPLAIN
    def dot_to_big(dot_str)
      fail ArgumentError unless dot_str.is_a? String
      return dot_str unless /\d+\.\d+/.match(dot_str)
      mask = 0b1111111111111111
      high = dot_str.to_i
      low = 0
      low_match = dot_str.match(/\.(\d+)/)
      low = low_match[1].to_i if low_match
      high_bits = (mask & high) << 16
      low_bits = mask & low
      high_bits + low_bits
    end
    munge do |value|
      value = :default if value == 'default'
      value = dot_to_big(String(value)) unless value == :default
      value
    end
  end

  newparam(:vrf, :namevar => true) do
    desc 'BGP vrf name. Valid values are string. ' \
         "The name 'default' is a valid VRF."

    defaultto('default')
    newvalues(/^\S+$/)
  end

  newparam(:nbr, :namevar => true) do
    desc 'BGP Neighbor ID. Valid values are string.'
  end

  newparam(:afi, :namevar => true) do
    desc 'BGP Address-family AFI (ipv4|ipv6). Valid values are string.'
  end

  newparam(:safi, :namevar => true) do
    desc 'BGP Address-family SAFI (unicast|multicast). Valid values are string.'
  end

  ##############
  # Properties #
  ##############

  validate do
    fail("The 'asn' parameter must be set in the manifest.") if self[:asn].nil?
    fail("The 'vrf' parameter must be set in the manifest.") if self[:vrf].nil?
    fail("The 'nbr' parameter must be set in the manifest.") if self[:nbr].nil?
    fail("The 'afi' parameter must be set in the manifest.") if self[:afi].nil?
    fail("The 'safi' parameter must be set in the manifest.") if self[:safi].nil?
  end

  newproperty(:advertise_map_exist, :array_matching => :all) do
    desc 'advertise_map_exist state. Valid values are an array specifying' \
         " both the advertise-map name and the exist-map name, or 'default'."
    munge do |value|
      value = :default if value == 'default'
      value
    end
  end

  newproperty(:advertise_map_non_exist, :array_matching => :all) do
    desc 'advertise_map_non_exist state. Valid values are an array specifying' \
         " both the advertise-map name and the non_exist-map name, or 'default'."
    munge do |value|
      value = :default if value == 'default'
      value
    end
  end

  newproperty(:allowas_in) do
    desc "allowas_in state. Valid values are true, false, or 'default'."
    newvalues(:true, :false, :default)
  end

  newproperty(:allowas_in_max) do
    desc 'allowas_in_max occurrences state. Valid values are an integer or ' \
         "'default'."
    munge do |value|
      value = :default if value == 'default'
      value
    end
  end

  newproperty(:as_override) do
    desc 'as_override state. ' \
         "Valid values are true, false or 'default'"
    newvalues(:true, :false, :default)
  end

  newproperty(:cap_add_paths_receive) do
    desc 'cap_add_paths_receive state. ' \
         "Valid values are true, false or 'default'"
    newvalues(:true, :false, :default)
  end

  newproperty(:cap_add_paths_receive_disable) do
    desc 'cap_add_paths_receive_disable state. ' \
         "Valid values are true, false or 'default'"
    newvalues(:true, :false, :default)
  end

  newproperty(:cap_add_paths_send) do
    desc 'cap_add_paths_send state. ' \
         "Valid values are true, false or 'default'"
    newvalues(:true, :false, :default)
  end

  newproperty(:cap_add_paths_send_disable) do
    desc 'cap_add_paths_send_disable state. ' \
         "Valid values are true, false or 'default'"
    newvalues(:true, :false, :default)
  end

  newproperty(:default_originate) do
    desc 'default_originate state.' \
         "Valid values are True, False or 'default'"
    newvalues(:true, :false, :default)
  end

  newproperty(:disable_peer_as_check) do
    desc 'disable_peer_as_check state. ' \
         "Valid values are true, false or 'default'"
    newvalues(:true, :false, :default)
  end

  newproperty(:default_originate_route_map) do
    desc 'default_originate_route_map state. Valid values are a string ' \
         "defining a route-map name or 'default'"
    munge do |value|
      value = :default if value == 'default'
      value
    end
  end

  newproperty(:filter_list_in) do
    desc 'filter-list in state. Valid values are a string defining the name ' \
         "of the filter-list or 'default'."
    munge do |value|
      value = :default if value == 'default'
      value
    end
  end

  newproperty(:filter_list_out) do
    desc 'filter-list out state. Valid values are a string defining the name ' \
         "of the filter-list or 'default'."
    munge do |value|
      value = :default if value == 'default'
      value
    end
  end

  newproperty(:max_prefix_interval) do
    desc "max_prefix_interval state. Valid values are an integer or 'default'."
    munge do |value|
      value = :default if value == 'default'
      value
    end
  end

  newproperty(:max_prefix_limit) do
    desc "max_prefix_limit state. Valid values are an integer or 'default'."
    munge do |value|
      value = :default if value == 'default'
      value
    end
  end

  newproperty(:max_prefix_threshold) do
    desc "max_prefix_threshold state. Valid values are an integer or 'default'."
    munge do |value|
      value = :default if value == 'default'
      value
    end
  end

  newproperty(:max_prefix_warning) do
    desc "max_prefix_warning state. Valid values are true, false or 'default'."
    newvalues(:true, :false, :default)
  end

  newproperty(:next_hop_self) do
    desc "next_hop_self state. Valid values are true, false or 'default'."
    newvalues(:true, :false, :default)
  end

  newproperty(:next_hop_third_party) do
    desc 'next_hop_third_party state. ' \
         "Valid values are true, false or 'default'."
    newvalues(:true, :false, :default)
  end

  newproperty(:route_reflector_client) do
    desc 'route_reflector_client state. ' \
         "Valid values are true, false or 'default'."
    newvalues(:true, :false, :default)
  end

  newproperty(:send_community) do
    desc 'send_community attribute. ' \
         "Valid values are 'none', 'both', 'extended', 'standard' or 'default'."

    newvalues(
      :none,
      :both,
      :extended,
      :standard,
      :default)
  end

  newproperty(:soft_reconfiguration_in) do
    desc 'soft_reconfiguration_in state. ' \
         "Valid values are true, false or 'default'."
    newvalues(:true, :false, :default)
  end

  newproperty(:soft_reconfiguration_in_always) do
    desc 'soft_reconfiguration_in_always state. ' \
         "Valid values are true, false or 'default'."
    newvalues(:true, :false, :default)
  end

  newproperty(:soo) do
    desc 'soo state. Valid values are a string ' \
         "defining a VPN extcommunity or 'default'"
    munge do |value|
      value = :default if value == 'default'
      value
    end
  end

  newproperty(:suppress_inactive) do
    desc 'suppress_inactive state. ' \
         "Valid values are true, false or 'default'."
    newvalues(:true, :false, :default)
  end

  newproperty(:unsuppress_map) do
    desc 'unsuppress_map state. Valid values are a string ' \
         "defining a route-map name or 'default'"
    munge do |value|
      value = :default if value == 'default'
      value
    end
  end

  newproperty(:weight) do
    desc "weight state. Valid values are an integer or 'default'."
    munge do |value|
      value = :default if value == 'default'
      value
    end
  end
end
