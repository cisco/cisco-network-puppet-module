# The NXAPI provider for cisco vpc_domain.
#
# December, 2015
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

require 'cisco_node_utils' if Puppet.features.cisco_node_utils?
begin
  require 'puppet_x/cisco/autogen'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                     'puppet_x', 'cisco', 'autogen.rb'))
end

Puppet::Type.type(:cisco_vpc_domain).provide(:nxapi) do
  desc 'The new NXAPI provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  VPC_NON_BOOL_PROPS = [
    :auto_recovery_reload_delay,
    :delay_restore,
    :delay_restore_interface_vlan,
    :dual_active_exclude_interface_vlan_bridge_domain,
    :peer_keepalive_dest,
    :peer_keepalive_hold_timeout,
    :peer_keepalive_interval,
    :peer_keepalive_interval_timeout,
    :peer_keepalive_precedence,
    :peer_keepalive_src,
    :peer_keepalive_udp_port,
    :peer_keepalive_vrf,
    :peer_gateway_exclude_bridge_domain,
    :peer_gateway_exclude_vlan,
    :role_priority,
    :system_mac,
    :system_priority,
  ]
  VPC_BOOL_PROPS = [
    :auto_recovery,
    :graceful_consistency_check,
    :layer3_peer_routing,
    :peer_gateway,
    :self_isolation,
    :shutdown,
  ]
  VPC_PROPS = VPC_NON_BOOL_PROPS + VPC_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@vpc_domain',
                                            VPC_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@vpc_domain',
                                            VPC_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @vpc_domain = Cisco::Vpc.domains[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of cisco_vpc_domain.'
  end

  def self.properties_get(domain_id, v)
    current_state = {
      domain: domain_id,
      name:   domain_id,
      ensure: :present,
    }

    # Call node_utils getter for each property
    VPC_PROPS.each do |prop|
      current_state[prop] = v.send(prop)
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    domains = []
    Cisco::Vpc.domains.each do |domain_id, obj|
      domains << properties_get(domain_id, obj)
    end
    domains
  end

  def self.prefetch(resources)
    domains = instances

    resources.keys.each do |id|
      provider = domains.find { |domain| domain.instance_name == id }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def exists?
    (@property_hash[:ensure] == :present)
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def instance_name
    domain
  end

  def properties_set(new_vpc_domain=false)
    VPC_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_vpc_domain
      unless @property_flush[prop].nil?
        @vpc_domain.send("#{prop}=", @property_flush[prop]) if
          @vpc_domain.respond_to?("#{prop}=")
      end
    end
    peer_keepalive_custom_set
  end

  def peer_keepalive_any?
    @property_flush[:peer_keepalive_dest] ||
      @property_flush[:peer_keepalive_hold_timeout] ||
      @property_flush[:peer_keepalive_interval] ||
      @property_flush[:peer_keepalive_interval_timeout] ||
      @property_flush[:peer_keepalive_precedence] ||
      @property_flush[:peer_keepalive_src] ||
      @property_flush[:peer_keepalive_udp_port] ||
      @property_flush[:peer_keepalive_vrf]
  end

  # rubocop:disable Metrics/MethodLength
  def peer_keepalive_custom_set
    return unless peer_keepalive_any?
    if @property_flush[:peer_keepalive_dest]
      pka_dest = @property_flush[:peer_keepalive_dest]
    else
      pka_dest = @vpc_domain.peer_keepalive_dest
    end
    if @property_flush[:peer_keepalive_hold_timeout]
      pka_hold_timeout = @property_flush[:peer_keepalive_hold_timeout]
    else
      pka_hold_timeout = @vpc_domain.peer_keepalive_hold_timeout
    end
    if @property_flush[:peer_keepalive_interval]
      pka_interval = @property_flush[:peer_keepalive_interval]
    else
      pka_interval = @vpc_domain.peer_keepalive_interval
    end
    if @property_flush[:peer_keepalive_interval_timeout]
      pka_timeout = @property_flush[:peer_keepalive_interval_timeout]
    else
      pka_timeout = @vpc_domain.peer_keepalive_interval_timeout
    end
    if @property_flush[:peer_keepalive_precedence]
      pka_prec = @property_flush[:peer_keepalive_precedence]
    else
      pka_prec = @vpc_domain.peer_keepalive_precedence
    end
    if @property_flush[:peer_keepalive_src]
      pka_src = @property_flush[:peer_keepalive_src]
    else
      pka_src = @vpc_domain.peer_keepalive_src
    end
    if @property_flush[:peer_keepalive_udp_port]
      pka_udp_port = @property_flush[:peer_keepalive_udp_port]
    else
      pka_udp_port = @vpc_domain.peer_keepalive_udp_port
    end
    if @property_flush[:peer_keepalive_vrf]
      pka_vrf = @property_flush[:peer_keepalive_vrf]
    else
      pka_vrf = @vpc_domain.peer_keepalive_vrf
    end
    @vpc_domain.peer_keepalive_set(pka_dest, pka_src, pka_udp_port, pka_vrf,
                                   pka_interval, pka_timeout, pka_prec,
                                   pka_hold_timeout)
  end
  # rubocop:enable Metrics/MethodLength

  def flush
    if @property_flush[:ensure] == :absent
      @vpc_domain.destroy
      @vpc_domain = nil
    else
      # Create/Update
      if @vpc_domain.nil?
        new_vpc_domain = true
        @vpc_domain = Cisco::Vpc.new(@resource[:domain])
      end
      properties_set(new_vpc_domain)
    end
    puts_config
  end

  def puts_config
    if @vpc_domain.nil?
      info "Vpc_domain=#{@resource[:domain]} is absent."
      return
    end

    # Dump all current properties for this vpc_domain
    current = sprintf("\n%30s: %s", 'vpc_domain', instance_name)
    VPC_PROPS.each do |prop|
      current.concat(sprintf("\n%30s: %s", prop, @vpc_domain.send(prop)))
    end
    debug current
  end # puts_config
end   # Puppet::Type
