#
# Manages BGP Address-Family configuration.
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

require 'ipaddr'
begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end

Puppet::Type.newtype(:cisco_bgp_af) do
  @doc = "Manages BGP Address-Family configuration.

  ~~~puppet
  cisco_bgp_af { '<title>':
    ..attributes..
  }
  ~~~

  `<title>` is the title of the bgp_af resource.

  Example:

  $injectmap = [['nyc', 'sfo'], ['sjc', 'sfo', 'copy-attributes']
  $network_list = [['192.168.5.0/24', 'rtmap1'], ['192.168.10.0/24']]
  $redistribute = [['eigrp 1', 'e_rtmap_29'], ['ospf 3',  'o_rtmap']]
  ~~~puppet
    cisco_bgp_af { 'raleigh':
      ensure                                 => present,
      asn                                    => '55',
      vrf                                    => 'default',
      afi                                    => 'ipv4',
      safi                                   => 'unicast',

      additional_paths_install               => 'true',
      additional_paths_receive               => 'true',
      additional_paths_selection             => 'Route_Map',
      additional_paths_send                  => 'true',
      advertise_l2vpn_evpn                   => 'true',
      client_to_client                       => 'true',
      dampen_igp_metric                      => 200,
      dampening_state                        => 'true',
      dampening_half_time                    => 5,
      dampening_max_suppress_time            => 200,
      dampening_reuse_time                   => 10,
      dampening_routemap                     => 'Dampening_Route_Map',
      dampening_suppress_time                => 15,
      default_information_originate          => 'true',
      default_metric                         => 50,
      distance_ebgp                          => 20,
      distance_ibgp                          => 40,
      distance_local                         => 60,
      inject_map                             => $injectmap,
      maximum_paths                          => '7',
      maximum_paths_ibgp                     => '7',
      next_hop_route_map                     => 'Default_Route_Map',
      network                                => $network_list,
      redistribute                           => $redistribute,
      suppress_inactive                      => 'true',
      table_map                              => 'sjc',
      table_map_filter                       => 'true',
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
          [:name, identity]
        ],
      ],
    ]
  end

  ##############
  # Parameters #
  ##############

  ensurable

  # Overwrites the name method which by default returns only
  # self[:name].
  def name
    "#{self[:asn]} #{self[:vrf]} #{self[:afi]} #{self[:safi]}"
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

  newproperty(:additional_paths_install) do
    desc 'install a backup path into the forwarding table and provide prefix ' \
         'independent convergence (PIC) in case of a PE-CE link failure. ' \
         "Valid values are true, false, or 'default'"

    newvalues(:true, :false, :default)
  end # property additional_paths_install

  newproperty(:additional_paths_receive) do
    desc 'Enables the receive capability of additional paths for all' \
      'of the neighbors under this address family for which the ' \
      'capability has not been disabled. ' \
      "Valid values are true, false, or 'default'"

    newvalues(:true, :false, :default)
  end # property additional_paths_receive

  newproperty(:additional_paths_selection) do
    desc 'Configures the capability of selecting additional paths for a prefix. ' \
      'Valid values are a string defining the name of the route-map.'

    validate do |value|
      fail("'additional_paths_selection' value must be a string") unless
        value.is_a? String
    end

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property additional_paths_selection

  newproperty(:additional_paths_send) do
    desc 'Enables the send capability of additional paths for all of the ' \
      'neighbors under this address family for which the capability has ' \
      "not been disabled. Valid values are true, false, or 'default'"

    newvalues(:true, :false, :default)
  end # property additional_paths_send

  newproperty(:advertise_l2vpn_evpn) do
    desc "Advertise EVPN routes. Valid values are true, false, or 'default'"

    newvalues(:true, :false, :default)
  end # property advertise_l2vpn_evpn

  newproperty(:client_to_client) do
    desc 'Configure client-to-client route reflection. Valid values are ' \
         "true, false, or 'default'"

    newvalues(:true, :false, :default)
  end # property client_to_client

  newproperty(:dampen_igp_metric) do
    desc 'Specify dampen value for IGP metric-related changes, in seconds. ' \
          "Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise "'dampen_igp_metric' must be an Integer."
      end # rescue
      value
    end
  end # property dampen_igp_metric

  newproperty(:dampening_state) do
    desc 'Enable/disable route-flap dampening. ' \
          "Valid values are true, false or 'default'."

    newvalues(:true, :false, :default)
  end # property dampening

  newproperty(:dampening_half_time) do
    desc 'Specify decay half-life in minutes for route-flap dampening. ' \
          "Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise "'dampening_half_time' must be an Integer."
      end # rescue
      value
    end
  end # property dampening_half_time

  newproperty(:dampening_max_suppress_time) do
    desc 'Specify max suppress time for route-flap dampening stable route. ' \
          "Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise "'dampening_max_suppress_time' must be an Integer."
      end # rescue
      value
    end
  end # property dampening_max_suppress_time

  newproperty(:dampening_reuse_time) do
    desc 'Specify route reuse time for route-flap dampening. ' \
          "Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise "'dampening_reuse_time' must be an Integer."
      end # rescue
      value
    end
  end # property dampening_reuse_time

  newproperty(:dampening_routemap) do
    desc 'Specify routemap for route-flap dampening. ' \
          'Valid values are a string defining the name of the route-map.'

    validate do |value|
      fail("'dampening_routemap' value must be a string") unless
        value.is_a? String
    end

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property dampening_routemap

  newproperty(:dampening_suppress_time) do
    desc 'Specify route suppress time for route-flap dampening. ' \
          "Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise "'dampening_suppress_time' must be an Integer."
      end # rescue
      value
    end
  end # property dampening_suppress_time

  newproperty(:default_information_originate) do
    desc 'Control distribution of default information. Valid values are, ' \
      "true, false, or 'default'"

    newvalues(:true, :false, :default)
  end # property :default_information_originate

  newproperty(:default_metric) do
    desc "Sets the default metrics for routes redistributed into BGP.
          Valid values are Integer or keyword 'default'"
    munge do |value|
      value == 'default' ? :default : value.to_i
    end
  end # property :default_metric

  newproperty(:distance_ebgp) do
    desc "Sets the administrative distance for BGP.
          Valid values are Integer or keyword 'default'"
    munge do |value|
      value == 'default' ? :default : value.to_i
    end
  end # property :distance_ebgp

  newproperty(:distance_ibgp) do
    desc "Sets the administrative distance for BGP.
          Valid values are Integer or keyword 'default'"
    munge do |value|
      value == 'default' ? :default : value.to_i
    end
  end # property :distance_ibgp

  newproperty(:distance_local) do
    desc "Sets the administrative distance for BGP.
          Valid values are Integer or keyword 'default'"
    munge do |value|
      value == 'default' ? :default : value.to_i
    end
  end # property :distance_local

  newproperty(:inject_map, array_matching: :all) do
    format = "[['routemap string'], ['routemap string], ['copy string]]"
    desc "Routemap which specifies prefixes to inject. Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property inject_map

  newproperty(:maximum_paths) do
    desc 'Configures the maximum number of equal-cost paths for load ' \
          'sharing. Valid values are integers in the range 1 - 64, ' \
          'default value is 1.'

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
    desc 'Configures the maximum number of ibgp equal-cost paths for load ' \
         'sharing. Valid values are integers in the range 1 - 64, default ' \
         'value is 1.'

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

  newproperty(:networks, array_matching: :all) do
    format = "[['network string'], ['routemap string]]"
    desc "Networks to configure. Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        if PuppetX::Cisco::Utils.process_network_mask(value[0]).split('/')[1].nil?
          fail("Must supply network mask for #{value[0]}")
        end
        value
      end
    end
  end # property networks

  newproperty(:next_hop_route_map) do
    desc 'Configure route map for valid nexthops. Valid values are a string ' \
      "defining the name of the route-map'."

    validate do |value|
      fail("'next_hop_route_map' value must be a string") unless
        value.is_a? String
    end

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property next_hop_route_map

  newproperty(:redistribute, array_matching: :all) do
    format = "[['protocol'], ['route-map string]]"
    desc 'A list of redistribute directives. Multiple redistribute entries ' \
         'are allowed. The list must be in the form of a nested array: the ' \
         'first entry of each array defines the source-protocol to ' \
         'redistribute from; the second entry defines a route-map name. ' \
         'A route-map is highly advised but may be optional on some ' \
         'platforms, in which case it may be omitted from the array list.'

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property :redistribute

  newproperty(:suppress_inactive) do
    desc "Advertises only active routes to peersy
          Valid values are true, false, or 'default'"

    newvalues(:true, :false, :default)
  end # property suppress_inactive

  newproperty(:table_map) do
    desc "Apply table-map to filter routes downloaded into URIB
          Valid values are a string"

    validate do |value|
      fail("'table_map' value must be a string") unless
        value.is_a? String
    end

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property table_map

  newproperty(:table_map_filter) do
    desc "Filters routes rejected by the route map and does not download
          them to the RIB. Valid values are true, false, or 'default'"

    newvalues(:true, :false, :default)
  end # property table_map_filter

  #
  # VALIDATIONS
  #
  validate do
    fail("The 'asn' parameter must be set in the manifest.") if self[:asn].nil?
    fail("The 'afi' parameter must be set in the manifest.") if self[:afi].nil?
    fail("The 'safi' parameter must be set in the manifest.") if self[:safi].nil?

    # Don't need to process remaining checks if ensure => absent.
    return if self[:ensure] == :absent

    def route_flap_properties?
      self[:dampening_half_time] || self[:dampening_reuse_time] ||
        self[:dampening_suppress_time] || self[:dampening_max_suppress_time]
    end

    def all_properties?
      self[:dampening_half_time] || self[:dampening_reuse_time] ||
        self[:dampening_suppress_time] || self[:dampening_max_suppress_time] ||
        self[:dampening_routemap]
    end
    properties = [
      :dampening_half_time,
      :dampening_reuse_time,
      :dampening_suppress_time,
      :dampening_max_suppress_time,
      :dampening_routemap,
    ]
    if all_properties? && self[:dampening_state] == :false
      fail(":dampening_state cannot be 'false' when #{properties} are set")
    end
    # If any of these properties are set, then all of them must be.
    if route_flap_properties?
      properties.delete(:dampening_routemap)
      properties.each do |prop|
        if self[prop].nil?
          fail("Must set all or none of the following properties #{properties}")
        end
      end
      if self[:dampening_routemap]
        fail(":dampening_routemap should not be set when #{properties} are set")
      end
    end
  end
end
