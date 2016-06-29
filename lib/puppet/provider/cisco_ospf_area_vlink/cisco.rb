# June, 2016
#
# Copyright (c) 2016 Cisco and/or its affiliates.
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
Puppet::Type.type(:cisco_ospf_area_vlink).provide(:cisco) do
  desc 'The Cisco OSPF area virtual link provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  OSPF_AREA_VLINK_NON_BOOL_PROPS = [
    :auth_key_chain,
    :authentication,
    :authentication_key_encryption_type,
    :authentication_key_password,
    :dead_interval,
    :hello_interval,
    :message_digest_algorithm_type,
    :message_digest_encryption_type,
    :message_digest_key_id,
    :message_digest_password,
    :retransmit_interval,
    :transmit_delay,
  ]

  OSPF_AREA_VLINK_ALL_PROPS = OSPF_AREA_VLINK_NON_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@nu',
                                            OSPF_AREA_VLINK_NON_BOOL_PROPS)

  def initialize(value={})
    super(value)
    ospf = @property_hash[:ospf]
    vrf = @property_hash[:vrf]
    area = @property_hash[:area]
    vlink = @property_hash[:vlink]
    @nu = Cisco::RouterOspfAreaVirtualLink.virtual_links[ospf][vrf][area][vlink] unless
      ospf.nil? || vrf.nil? || area.nil? || vlink.nil?
    @property_flush = {}
  end

  def self.properties_get(ospf, vrf, area, vlink, nu_obj)
    debug "Checking vlink instance, #{ospf} #{vrf} #{area} #{vlink}"
    current_state = {
      name:   "#{ospf} #{vrf} #{area} #{vlink}",
      ospf:   ospf,
      vrf:    vrf,
      area:   area,
      vlink:  vlink,
      ensure: :present,
    }

    # Call node_utils getter for each property
    (OSPF_AREA_VLINK_NON_BOOL_PROPS).each do |prop|
      current_state[prop] = nu_obj.send(prop)
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    vlink_instances = []
    Cisco::RouterOspfAreaVirtualLink.virtual_links.each do |ospf, vrfs|
      vrfs.each do |vrf, areas|
        areas.each do |area, vlinks|
          vlinks.each do |vlink, nu_obj|
            vlink_instances << properties_get(ospf, vrf, area, vlink, nu_obj)
          end
        end
      end
    end
    vlink_instances
  end # self.instances

  def self.prefetch(resources)
    vlink_instances = instances
    resources.keys.each do |id|
      provider = vlink_instances.find do |vli|
        vli.ospf.to_s == resources[id][:ospf].to_s &&
        vli.vrf.to_s == resources[id][:vrf].to_s &&
        vli.area.to_s == resources[id][:area].to_s &&
        vli.vlink.to_s == resources[id][:vlink].to_s
      end
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def properties_set(new_vlink=false)
    OSPF_AREA_VLINK_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      send("#{prop}=", @resource[prop]) if new_vlink
      unless @property_flush[prop].nil?
        @nu.send("#{prop}=", @property_flush[prop]) if
          @nu.respond_to?("#{prop}=")
      end
    end
    # custom setters which require one-shot multi-param setters
    authentication_key_set
    message_digest_key_set
  end

  def authentication_key_set
    pw = @property_flush[:authentication_key_password] ? @property_flush[:authentication_key_password] : @nu.authentication_key_password
    enctype = @property_flush[:authentication_key_encryption_type] ? @property_flush[:authentication_key_encryption_type] : @nu.authentication_key_encryption_type
    @nu.authentication_key_set(enctype, pw)
  end

  def message_digest_key_set
    key = @property_flush[:message_digest_key_id] ? @property_flush[:message_digest_key_id] : @nu.message_digest_key_id
    pw = @property_flush[:message_digest_password] ? @property_flush[:message_digest_password] : @nu.message_digest_password
    algtype = @property_flush[:message_digest_algorithm_type] ? @property_flush[:message_digest_algorithm_type] : @nu.message_digest_algorithm_type
    enctype = @property_flush[:message_digest_encryption_type] ? @property_flush[:message_digest_encryption_type] : @nu.message_digest_encryption_type
    @nu.message_digest_key_set(key, algtype.to_s, enctype, pw)
  end

  def flush
    if @property_flush[:ensure] == :absent
      @nu.destroy
      @nu = nil
    else
      # Create/Update
      new_vlink = false
      if @nu.nil?
        new_vlink = true
        @nu = Cisco::RouterOspfAreaVirtualLink.new(@resource[:ospf],
                                                   @resource[:vrf],
                                                   @resource[:area],
                                                   @resource[:vlink])
      end
      properties_set(new_vlink)
    end
  end
end
