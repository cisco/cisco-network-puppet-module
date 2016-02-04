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
begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end

Puppet::Type.newtype(:cisco_bgp_neighbor_af) do
  @doc = "Manages BGP Neighbor Address-Family configuration.

  ~~~puppet
  cisco_bgp_neighbor_af { '<title>':
    ..attributes..
  }
  ~~~

  `<title>` is the title of the bgp_neighbor_af resource.

  Example:

  ~~~puppet
    cisco_bgp_neighbor_af { 'raleigh':
      ensure                                 => present,
      asn                                    => '1'
      vrf                                    => 'default',
      neighbor                               => '10.1.1.1',
      afi                                    => 'ipv4',
      safi                                   => 'unicast',
      additional_paths_receive               => 'disable',
      additional_paths_send                  => 'enable',
      advertise_map_exist                    => ['adv_map', 'my_exist'],
      advertise_map_non_exist                => ['foo_map', 'my_non_exist'],
      allowas_in                             => true,
      allowas_in_max                         => 5,
      as_override                            => true,
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
      prefix_list_in                         => 'pfx_in',
      prefix_list_out                        => 'pfx_out',
      route_map_in                           => 'rm_in',
      route_map_out                          => 'rm_out',
      route_reflector_client                 => true,
      send_community                         => 'extended',
      soft_reconfiguration_in                => 'always',
      soo                                    => '3:3',
      suppress_inactive                      => true,
      unsuppress_map                         => 'unsup_map',
      weight                                 => 30,
    }
  ~~~

  Example Title Patterns:

  ~~~puppet
    cisco_bgp_neighbor_af { 'new_york':
      ensure                                 => present,
      asn                                    => '1'
      vrf                                    => 'red',
      neighbor                               => '10.1.1.1',
      afi                                    => 'ipv4',
      safi                                   => 'unicast',
  ~~~

  ~~~puppet
    cisco_bgp_neighbor_af { '1':
      ensure                                 => present,
      vrf                                    => 'red',
      neighbor                               => '10.1.1.1',
      afi                                    => 'ipv4',
      safi                                   => 'unicast',
  ~~~

  ~~~puppet
    cisco_bgp_neighbor_af { '1 red':
      ensure                                 => present,
      neighbor                               => '10.1.1.1',
      afi                                    => 'ipv4',
      safi                                   => 'unicast',
  ~~~

  ~~~puppet
    cisco_bgp_neighbor_af { '1 red 10.1.1.1':
      ensure                                 => present,
      afi                                    => 'ipv4',
      safi                                   => 'unicast',
  ~~~

  ~~~puppet
    cisco_bgp_neighbor_af { '1 red 10.1.1.1 ipv4':
      ensure                                 => present,
      safi                                   => 'unicast',
  ~~~

  ~~~puppet
    cisco_bgp_neighbor_af { '1 red 10.1.1.1 ipv4 unicast':
      ensure                                 => present,
  ~~~

  "

  ###################
  # Resource Naming #
  ###################
  # Parse out the title to fill in the attributes in these patterns. These
  # attributes can be overwritten later.

  # rubocop:disable Metrics/MethodLength
  def self.title_patterns
    identity = ->(x) { x }
    [
      [
        /^(\d+|\d+\.\d+)$/,
        [
          [:asn, identity]
        ],
      ],
      [
        /^(\d+|\d+\.\d+) (\S+)$/,
        [
          [:asn, identity],
          [:vrf, identity],
        ],
      ],
      [
        /^(\d+|\d+\.\d+) (\S+) (\S+)$/,
        [
          [:asn, identity],
          [:vrf, identity],
          [:neighbor, identity],
        ],
      ],
      [
        /^(\d+|\d+\.\d+) (\S+) (\S+) (\S+)$/,
        [
          [:asn, identity],
          [:vrf, identity],
          [:neighbor, identity],
          [:afi, identity],
        ],
      ],
      [
        /^(\d+|\d+\.\d+) (\S+) (\S+) (\S+) (\S+)$/,
        [
          [:asn, identity],
          [:vrf, identity],
          [:neighbor, identity],
          [:afi, identity],
          [:safi, identity],
        ],
      ],
      [
        /^(\S+)$/,
        [
          [:name, identity]
        ],
      ],
    ]
  end
  # rubocop:enable Metrics/MethodLength

  ##############
  # Parameters #
  ##############

  ensurable

  # Overwrites the name method which by default returns only
  # self[:name].
  def name
    "#{self[:asn]} #{self[:vrf]} #{self[:neighbor]} #{self[:afi]} " \
    "#{self[:safi]}"
  end

  # Only needed to satisfy name parameter.
  newparam(:name) do
  end

  newparam(:asn, namevar: true) do
    desc "BGP autonomous system number.  Valid values are String, Integer in
          ASPLAIN or ASDOT notation"
    validate do |value|
      unless /^(\d+|\d+\.\d+)$/.match(value.to_s)
        fail("BGP asn #{value} must be specified in ASPLAIN or ASDOT notation")
      end
    end
    munge(&:to_s)
  end

  newparam(:vrf, namevar: true) do
    desc 'BGP vrf name. Valid values are string. ' \
         "The name 'default' is a valid VRF."

    defaultto('default')
    newvalues(/^\S+$/)
  end

  newparam(:neighbor, namevar: true) do
    desc 'BGP Neighbor ID. Valid value is an ipv4 or ipv6 formatted string.'

    munge do |value|
      begin
        value = PuppetX::Cisco::Utils.process_network_mask(value.to_s)
        value
      rescue
        raise "'neighbor' must be a valid ipv4 or ipv6 address (mask optional)"
      end
    end
  end

  newparam(:afi, namevar: true) do
    desc 'BGP Address-family AFI (ipv4|ipv6). Valid values are string.'
    newvalues(:ipv4, :ipv6, :l2vpn)
  end

  newparam(:safi, namevar: true) do
    desc 'BGP Address-family SAFI (unicast|multicast). Valid values are string.'
    newvalues(:unicast, :multicast, :evpn)
  end

  ##############
  # Properties #
  ##############

  newproperty(:advertise_map_exist, array_matching: :all) do
    desc 'advertise_map_exist state. Valid values are an array specifying' \
         " both the advertise-map name and the exist-map name, or 'default'."
    munge do |value|
      value = :default if value == 'default'
      value
    end
  end

  newproperty(:advertise_map_non_exist, array_matching: :all) do
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
      value = Integer(value) unless value == :default
      value
    end
  end

  newproperty(:as_override) do
    desc 'as_override state. ' \
         "Valid values are true, false or 'default'"
    newvalues(:true, :false, :default)
  end

  newproperty(:additional_paths_receive) do
    desc 'additional_paths_receive state. ' \
         "Valid values are 'enable' for basic command enablement; 'disable' " \
         "for disabling the command at the neighbor_af level; and 'inherit' " \
         'to remove the command at this level (the command value is ' \
         'inherited from a higher bgp layer)'
    munge(&:to_sym)
    newvalues(:enable, :disable, :inherit)
  end

  newproperty(:additional_paths_send) do
    desc 'additional_paths_send state. ' \
         "Valid values are 'enable' for basic command enablement; 'disable' " \
         "for disabling the command at the neighbor_af level; and 'inherit' " \
         'to remove the command at this level (the command value is ' \
         'inherited from a higher bgp layer)'
    munge(&:to_sym)
    newvalues(:enable, :disable, :inherit)
  end

  newproperty(:default_originate) do
    desc 'default_originate state.' \
         "Valid values are True, False or 'default'"
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

  newproperty(:disable_peer_as_check) do
    desc 'disable_peer_as_check state. ' \
         "Valid values are true, false or 'default'"
    newvalues(:true, :false, :default)
  end

  newproperty(:filter_list_in) do
    desc 'filter-list in state. Valid values are a string defining the name ' \
         "of the filter-list or 'default'."
    munge do |value|
      # Integers are valid filter-list names
      (value == 'default') ? :default : value.to_s
    end
  end

  newproperty(:filter_list_out) do
    desc 'filter-list out state. Valid values are a string defining the name ' \
         "of the filter-list or 'default'."
    munge do |value|
      # Integers are valid filter-list names
      (value == 'default') ? :default : value.to_s
    end
  end

  newproperty(:max_prefix_interval) do
    desc "max_prefix_interval state. Valid values are an integer or 'default'."
    munge do |value|
      value = :default if value == 'default'
      value = Integer(value) unless value == :default
      value
    end
  end

  newproperty(:max_prefix_limit) do
    desc "max_prefix_limit state. Valid values are an integer or 'default'."
    munge do |value|
      value = :default if value == 'default'
      value = Integer(value) unless value == :default
      value
    end
  end

  newproperty(:max_prefix_threshold) do
    desc "max_prefix_threshold state. Valid values are an integer or 'default'."
    munge do |value|
      value = :default if value == 'default'
      value = Integer(value) unless value == :default
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

  newproperty(:prefix_list_in) do
    desc 'prefix-list in state. Valid values are a string defining the name ' \
         "of the prefix-list or 'default'."
    munge do |value|
      # Integers are valid prefix-list names
      (value == 'default') ? :default : value.to_s
    end
  end

  newproperty(:prefix_list_out) do
    desc 'prefix-list out state. Valid values are a string defining the name ' \
         "of the filter-list or 'default'."
    munge do |value|
      # Integers are valid prefix-list names
      (value == 'default') ? :default : value.to_s
    end
  end

  newproperty(:route_map_in) do
    desc 'route-map in state. Valid values are a string defining the name ' \
         "of the route-map or 'default'."
    munge do |value|
      # Integers are valid route-map names
      (value == 'default') ? :default : value.to_s
    end
  end

  newproperty(:route_map_out) do
    desc 'route-map out state. Valid values are a string defining the name ' \
         "of the route-map or 'default'."
    munge do |value|
      # Integers are valid route-map names
      (value == 'default') ? :default : value.to_s
    end
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
         "Valid values are 'enable' for basic command enablement; 'always' " \
         "to add the 'always' keyword to the basic command; and 'inherit' " \
         'to remove the command at this level (the command value is ' \
         'inherited from a higher bgp layer)'
    munge(&:to_sym)
    newvalues(:enable, :always, :inherit)
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
      value = Integer(value) unless value == :default
      value
    end
  end

  validate do
    fail("The 'asn' parameter must be set in the manifest.") if self[:asn].nil?
    fail("The 'vrf' parameter must be set in the manifest.") if self[:vrf].nil?
    fail("The 'neighbor' parameter must be set in the manifest.") if
      self[:neighbor].nil?
    fail("The 'afi' parameter must be set in the manifest.") if self[:afi].nil?
    fail("The 'safi' parameter must be set in the manifest.") if self[:safi].nil?
  end
end
