#
# Manages BGP Address-Family configuration.
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
require 'cisco_node_utils' if Puppet.features.cisco_node_utils?

Puppet::Type.newtype(:cisco_bgp_af) do
  @doc = "Manages BGP Address-Family configuration.

  ~~~puppet
  cisco_bgp_af { '<title>':
    ..attributes..
  }
  ~~~

  `<title>` is the title of the bgp_af resource.

  Example:

  ~~~puppet
    cisco_bgp_af { 'raleigh':
      ensure                                 => present,
      asn                                    => '55',
      vrf                                    => 'default',
      afi                                    => 'ipv4',
      safi                                   => 'unicast',

      advertise_l2vpn_evpn                   => 'true',
      client_to_client                       => 'true',
      default_information_originate          => 'true',
      maximum_paths                          => '7',
      maximum_paths_ibgp                     => '7',
      next_hop_route_map                     => 'Default_Route_Map',
    }
  ~~~

  Example Title Patterns:

  ~~~puppet
    cisco_bgp_af { 'new_york':
      ensure                                 => present,
      asn                                    => '1',
      vrf                                    => 'red',
      afi                                    => 'ipv4',
      safi                                   => 'unicast',
  ~~~

  ~~~puppet
    cisco_bgp_af { '1':
      ensure                                 => present,
      vrf                                    => 'red',
      afi                                    => 'ipv4',
      safi                                   => 'unicast',
  ~~~

  ~~~puppet
    cisco_bgp_af { '1 red':
      ensure                                 => present,
      afi                                    => 'ipv4',
      safi                                   => 'unicast',
  ~~~

    cisco_bgp_af { '1 red ipv4':
      ensure                                 => present,
      safi                                   => 'unicast',
  ~~~

  ~~~puppet
    cisco_bgp_af { '1 red ipv4 unicast':
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
          [:asn, identity],
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
          [:afi, identity],
        ],
      ],
      [
        /^(\d+|\d+\.\d+) (\S+) (\S+) (\S+)$/,
        [
          [:asn, identity],
          [:vrf, identity],
          [:afi, identity],
          [:safi, identity],
        ],
      ],
      [
        /^(\S+)$/,
        [
          [:name, identity],
        ],
      ],
    ]
  end
  # rubocop:enable Metrics/MethodLength

  ##############
  # Parameters #
  ##############

  ensurable

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

    munge { |value| Cisco::RouterBgp.process_asnum(value) }
  end

  newparam(:vrf, namevar: true) do
    desc 'BGP vrf name. Valid values are string. ' \
      "The name 'default' is a valid VRF."

    defaultto('default')
    newvalues(/^\S+$/)
  end

  newparam(:afi, namevar: true) do
    desc 'BGP Address-family AFI (ipv4|ipv6). Valid values are string.'
    newvalues(:ipv4, :ipv6)
  end

  newparam(:safi, namevar: true) do
    desc 'BGP Address-family SAFI (unicast|multicast). Valid values are string.'
    newvalues(:unicast, :multicast)
  end

  ##############
  # Properties #
  ##############

  validate do
    fail("The 'asn' parameter must be set in the manifest.") if self[:asn].nil?
    fail("The 'afi' parameter must be set in the manifest.") if self[:afi].nil?
    fail("The 'safi' parameter must be set in the manifest.") if self[:safi].nil?
  end

  newproperty(:advertise_l2vpn_evpn) do
    desc "advertise EVPN routes. Valid values are true, false, or 'default'"

    newvalues(:true, :false, :default)
  end # property advertise_l2vpn_evpn

  newproperty(:client_to_client) do
    desc "client_to_client. Valid values are true, false, or 'default'"

    newvalues(:true, :false, :default)
  end # property client_to_client

  newproperty(:default_information_originate) do
    desc ':default_information_originate. Valid values are true, ' \
      "false, or 'default'"

    newvalues(:true, :false, :default)
  end # property :default_information_originate

  newproperty(:maximum_paths) do
    desc "Configures the maximum number of equal-cost paths for load sharing.
          Valid values are integers in the range 1 - 64, default value is 1."
    munge do |value|
      value = :default if value == 'default'
      unless value == :default
        value = value.to_i
        fail 'maximum_paths value should be in the range 1 - 64' unless
          value.between?(1, 64)
      end
      value
    end
  end # property :maximum_paths

  newproperty(:maximum_paths_ibgp) do
    desc "Configures the maximum number of ibgp equal-cost paths for load sharing.
          Valid values are integers in the range 1 - 64, default value is 1."
    munge do |value|
      value = :default if value == 'default'
      unless value == :default
        value = value.to_i
        fail 'maximum_paths_ibgp value should be in the range of 1 - 64' unless
          value.between?(1, 64)
      end
      value
    end
  end # property :maximum_paths_ibgp

  newproperty(:next_hop_route_map) do
    desc ':next_hop_route_map in state. Valid values are a string ' \
      "defining the name of the route-map'."

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property next_hop_route_map
end
