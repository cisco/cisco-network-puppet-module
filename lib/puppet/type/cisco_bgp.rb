# Manages BGP global and vrf configuration.
#
# July 2015
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_bgp) do
  @doc = "Manages BGP global and vrf configuration.

  ~~~puppet
  cisco_bgp { '<bgp-title>':
    ..attributes..
  }
  ~~~

  `<bgp-title>` is the title of the bgp resource.

  Example:
  ~~~puppet
    cisco_bgp { 'raleigh':
      ensure                                 => present,
      asn                                    => '39317'
      vrf                                    => 'green',
      route_distinguisher                    => 'auto'
      router_id                              => '10.0.0.1',
      cluster_id                             => '55',
      confederation_id                       => '77.6',
      confederation_peers                    => '77.6 88 99.4 200'
      disable_policy_batching                => true,
      disable_policy_batching_ipv4           => 'xx',
      disable_policy_batching_ipv6           => 'yy',
      enforce_first_as                       => true,
      event_history_cli                      => 'true',
      event_history_detail                   => 'small',
      event_history_events                   => 'large',
      event_history_periodic                 => 'disable',
      fast_external_fallover                 => true,
      flush_routes                           => false,
      isolate                                => false,
      maxas_limit                            => '50',
      shutdown                               => false,

      supress_fib_pending                    => true,
      log_neighbor_changes                   => true,

      # Best Path Properties
      bestpath_always_compare_med            => true,
      bestpath_aspath_multipath_relax        => false,
      bestpath_compare_routerid              => true,
      bestpath_cost_community_ignore         => true,
      bestpath_med_confed                    => false,
      bestpath_med_missing_as_worst          => true,
      bestpath_med_non_deterministic         => true,
      timer_bestpath_limit                   => 250,
      timer_bestpath_limit_always            => false,

      # Graceful Restart Properties
      graceful_restart                       => true,
      graceful_restart_timers_restart        => 130,
      graceful_restart_timers_stalepath_time => 310,
      graceful_restart_helper                => true,

      # Timer Properties
      timer_bgp_keepalive                    => 30,
      timer_bgp_holdtime                     => 90,
    }
  ~~~

  Example Title Patterns:

  ~~~puppet
    cisco_bgp { 'new_york':
      ensure                                 => present,
      asn                                    => '39317'
      vrf                                    => 'green',
  ~~~

  ~~~puppet
    cisco_bgp { '55':
      ensure                                 => present,
      vrf                                    => 'blue',
  ~~~

  ~~~puppet
    cisco_bgp { '55 blue':
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
    "#{self[:asn]} #{self[:vrf]}"
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
  end # param asn

  newparam(:vrf, namevar: true) do
    desc "Name of the resource instance. Valid values are string. The
          name 'default' is a valid VRF."

    defaultto('default')
    newvalues(/^\S+$/)
  end # param vrf

  ##############
  # Properties #
  ##############

  newproperty(:route_distinguisher) do
    desc "VPN Route Distinguisher (RD). The RD is combined with the IPv4
          or IPv6 prefix learned by the PE router to create a globally
          unique address. Valid values are a String in one of the
          route-distinguisher formats (ASN2:NN, ASN4:NN, or IPV4:NN);
          the keyword 'auto', or the keyword 'default'."

    validate do |rd|
      fail "Route Distinguisher '#{value}' #{match_error}" unless
        /^(?:\d+\.\d+\.\d+\.)?\d+:\d+$/.match(rd) || rd == 'auto' ||
        rd == 'default' || rd == :default
    end

    munge do |rd|
      rd = :default if rd == 'default'
      rd
    end
  end # property router_distinguisher

  newproperty(:router_id) do
    desc "Router Identifier (ID) of the BGP router instance. Valid
          values are String, keyword 'default'."

    validate do |id|
      begin
        IPAddr.new(id) unless id == :default || id.empty? || id == 'default'
      rescue
        raise 'Router ID is not a valid IP address.'
      end
    end

    munge do |id|
      id = :default if id == 'default'
      id
    end
  end # property router_id

  newproperty(:cluster_id) do
    desc "Route Reflector Cluster-ID. Valid values are String,
      keyword 'default'."

    validate do |id|
      begin
        if /^\d+\.\d+\.\d+\.\d+$/.match(id)
          IPAddr.new(id) unless id == :default || id.empty? || id == 'default'
        else
          Integer(id) unless id == :default || id.empty? || id == 'default'
        end
      rescue
        raise 'Cluster-ID is not a valid IP address or Integer'
      end
    end

    munge do |id|
      id = :default if id == 'default'
      id
    end
  end # property cluster_id

  newproperty(:confederation_id) do
    desc "Routing domain confederation AS. Valid values are String,
      keyword 'default'."

    validate do |id|
      begin
        if /^(\d+|\d+\.\d+)$/.match(id)
          String(id) unless id == :default || id.empty? || id == 'default'
        end
      rescue
        raise 'Cluster-ID is not a valid IP address or Integer'
      end
    end

    munge do |id|
      id = :default if id == 'default'
      id
    end
  end # property confederation_id

  newproperty(:confederation_peers) do
    desc "AS confederation parameters. Valid values are String,
          keyword 'default'."

    match_error = 'must be specified in ASPLAIN or ASDOT notation'
    validate do |peers|
      list = peers.split(' ')
      list.each do |value|
        fail "Confederation peer value '#{value}' #{match_error}" unless
          /^(\d+|\d+\.\d+)$/.match(value) ||
          peers == 'default' || peers == :default
      end
    end

    munge do |peers|
      peers = :default if peers == 'default'
      peers
    end
  end # property confederation_peers

  newproperty(:shutdown) do
    desc 'Administratively shutdown the BGP protocol'

    newvalues(:true, :false, :default)
  end # property shutdown

  newproperty(:disable_policy_batching) do
    desc 'Enable/Disable the batching evaluation of prefix' \
         'advertisements to all peers'

    newvalues(:true, :false, :default)
  end # property disable_policy_batching

  newproperty(:disable_policy_batching_ipv4) do
    desc "Enable/Disable the batching evaluation of prefix
          advertisements to all peers. Valid values are String"

    validate do |value|
      fail("'disable_policy_batching_ipv4' value must be String") unless
        value.is_a? String
    end

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property disable_policy_batching_ipv4

  newproperty(:disable_policy_batching_ipv6) do
    desc "Enable/Disable the batching evaluation of prefix
          advertisements to all peers. Valid values are String"

    validate do |value|
      fail("'disable_policy_batching_ipv6' value must be String") unless
        value.is_a? String
    end

    munge do |value|
      value = :default if value == 'default'
      value
    end
  end # property disable_policy_batching_ipv6

  newproperty(:enforce_first_as) do
    desc 'Enable/Disable enforces the neighbor autonomous system ' \
         'to be the first AS number listed in the AS_path attribute for eBGP'

    newvalues(:true, :false, :default)
  end # property enforce_first_as

  newproperty(:event_history_cli) do
    desc "event_history_cli state. Valid values are True, False, size_small,
          size_medium, size_large, size_disable or 'default'"

    munge do |value|
      value = 'size_small' if value == 'true'
      value.to_sym
    end

    newvalues(:true, :false, :default,
              :size_small, :size_medium, :size_large, :size_disable)
  end # property event_history_cli

  newproperty(:event_history_detail) do
    desc "event_history_detail state. Valid values are True, False, size_small,
          size_medium, size_large, size_disable or 'default'"

    munge do |value|
      value = 'size_disable' if value == 'true'
      value.to_sym
    end

    newvalues(:true, :false, :default,
              :size_small, :size_medium, :size_large, :size_disable)
  end # property event_history_detail

  newproperty(:event_history_events) do
    desc "event_history_events state. Valid values are True, False, size_small,
          size_medium, size_large, size_disable or 'default'"

    munge do |value|
      value = 'size_small' if value == 'true'
      value.to_sym
    end

    newvalues(:true, :false, :default,
              :size_small, :size_medium, :size_large, :size_disable)
  end # property event_history_events

  newproperty(:event_history_periodic) do
    desc "event_history_periodic state. Valid values are True, False, size_small,
          size_medium, size_large, size_disable or 'default'"

    munge do |value|
      value = 'size_small' if value == 'true'
      value.to_sym
    end

    newvalues(:true, :false, :default,
              :size_small, :size_medium, :size_large, :size_disable)
  end # property event_history_periodic

  newproperty(:fast_external_fallover) do
    desc 'Enable/Disable immediately reset the session if the link ' \
         'to a directly connected BGP peer goes down'

    newvalues(:true, :false, :default)
  end # property fast_external_fallover

  newproperty(:flush_routes) do
    desc 'Enable/Disable flush routes in RIB upon controlled restart'

    newvalues(:true, :false, :default)
  end # property flush_routes

  newproperty(:isolate) do
    desc 'Enable/Disable isolate this router from BGP perspective'

    newvalues(:true, :false, :default)
  end # property isolate

  newproperty(:maxas_limit) do
    desc "Specify Maximum number of AS numbers allowed in the AS-path attribute.
          Valid values are integers between 1 and 2000, or keyword 'default' to
          disable this property"
    munge do |value|
      value = :default if value == 'default'
      unless value == :default
        value = value.to_i
        fail 'maxas_limit value should be between 1 and 512' unless
          value.between?(1, 512)
      end
      value
    end
  end

  newproperty(:neighbor_down_fib_accelerate) do
    desc 'Enable/Disable handle BGP neighbor down event, due to various reasons'

    newvalues(:true, :false, :default)
  end # property neighbor_down_fib_accelerate

  newproperty(:suppress_fib_pending) do
    desc "Enable/Disable advertise only routes that are programmed
          in hardware to peers"

    newvalues(:true, :false, :default)
  end # property supress_fib_pending

  newproperty(:log_neighbor_changes) do
    desc 'Enable/Disable message logging for neighbor up/down event'

    newvalues(:true, :false, :default)
  end # property log_neighbor_changes

  newproperty(:bestpath_always_compare_med) do
    desc "Enable/Disable Multi Exit Discriminator (MED) comparison on
          paths from different autonomous systems"

    newvalues(:true, :false, :default)
  end # bestpath_always_compare_med

  newproperty(:bestpath_aspath_multipath_relax) do
    desc "Enable/Disable load sharing across the providers with different
          (but equal-length) AS paths"

    newvalues(:true, :false, :default)
  end # bestpath_aspath_multipath_relax

  newproperty(:bestpath_compare_routerid) do
    desc 'Enable/Disable comparison of router IDs for identical eBGP paths.'

    newvalues(:true, :false, :default)
  end # property bestpath_compare_routerid

  newproperty(:bestpath_cost_community_ignore) do
    desc "Enable/Disable capability to ignore the cost community for BGP
          best-path calculations."

    newvalues(:true, :false, :default)
  end # property bestpath_cost_community_ignore

  newproperty(:bestpath_med_confed) do
    desc "Enable/Disable enforcement of bestpath to do a MED comparison only between
          paths originated within a confederation."

    newvalues(:true, :false, :default)
  end # property bestpath_med_confed

  newproperty(:bestpath_med_missing_as_worst) do
    desc 'Enable/Disable assigns the value of infinity to received routes that do not' \
         'carry the MED attribute, making these routes the least desirable.'

    newvalues(:true, :false, :default)
  end # property bestpath_med_missing_as_worst

  newproperty(:bestpath_med_non_deterministic) do
    desc "Enable/Disable deterministic selection of the best MED path from among
          the paths from the same autonomous system."

    newvalues(:true, :false, :default)
  end # property bestpath_med_non_deterministic

  newproperty(:timer_bestpath_limit) do
    desc "Specify timeout for the first best path after a restart, in seconds.
          Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'timer_bestpath_limit must be an Integer.'
      end # rescue
      value
    end
  end # property timer_bestpath_limit

  newproperty(:timer_bestpath_limit_always) do
    desc 'Enable/Disable update-delay-always option'

    newvalues(:true, :false, :default)
  end # property timer_bestpath_limit_always

  newproperty(:graceful_restart) do
    desc 'Enable/Disable'

    newvalues(:true, :false, :default)
  end # property graceful_restart

  newproperty(:graceful_restart_helper) do
    desc 'Enable/Disable'

    newvalues(:true, :false, :default)
  end # property graceful_restart_helper

  newproperty(:graceful_restart_timers_restart) do
    desc "Set maximum time for a restart sent to the BGP peer.
          Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'graceful_restart_timers_restart must be an Integer.'
      end # rescue
      value
    end
  end # property graceful_restart_timers_restart

  newproperty(:graceful_restart_timers_stalepath_time) do
    desc "Set maximum time that BGP keeps the stale routes from the
          restarting BGP peer. Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'graceful_restart_timers_stalepath_time must be an Integer.'
      end # rescue
      value
    end
  end # property graceful_restart_timers_stalepath_time

  newproperty(:timer_bgp_keepalive) do
    desc "Set bgp keepalive timer. Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'timer_bgp_keepalive must be an Integer.'
      end # rescue
      value
    end
  end # property timer_bgp_keepalive

  newproperty(:timer_bgp_holdtime) do
    desc "Set bgp hold timer. Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'timer_bgp_hold must be an Integer.'
      end # rescue
      value
    end
  end # property timer_bgp_holdtime

  # Make sure the asn parameter is set.
  validate do
    fail("The 'asn' parameter must be set in the manifest.") if self[:asn].nil?
  end
end
