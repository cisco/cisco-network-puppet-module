# The NXAPI provider for cisco_portchannel_global
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

Puppet::Type.type(:cisco_portchannel_global).provide(:nxapi) do
  desc 'The new NXAPI provider.'

  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  mk_resource_methods

  PC_GLOBAL_NON_BOOL_PROPS = [
    :bundle_hash,
    :bundle_select,
    :hash_distribution,
    :hash_poly,
    :load_defer,
    :rotate,
  ]
  PC_GLOBAL_BOOL_PROPS = [
    :asymmetric,
    :concatenation,
    :resilient,
    :symmetry,
  ]
  PC_GLOBAL_ALL_PROPS = PC_GLOBAL_NON_BOOL_PROPS + PC_GLOBAL_BOOL_PROPS

  PuppetX::Cisco::AutoGen.mk_puppet_methods(:non_bool, self, '@pc_global',
                                            PC_GLOBAL_NON_BOOL_PROPS)
  PuppetX::Cisco::AutoGen.mk_puppet_methods(:bool, self, '@pc_global',
                                            PC_GLOBAL_BOOL_PROPS)

  def initialize(value={})
    super(value)
    @pc_global = Cisco::PortChannelGlobal.globals[@property_hash[:name]]
    @property_flush = {}
    debug 'Created provider instance of cisco_portchannel_global'
  end

  def self.properties_get(global_id, v)
    debug "Checking instance, global #{global_id}"
    current_state = {
      name: global_id
    }

    # Call node_utils getter for each property
    PC_GLOBAL_NON_BOOL_PROPS.each do |prop|
      current_state[prop] = v.send(prop)
    end

    PC_GLOBAL_BOOL_PROPS.each do |prop|
      val = v.send(prop)
      if val.nil?
        current_state[prop] = nil
      else
        current_state[prop] = val ? :true : :false
      end
    end
    new(current_state)
  end # self.properties_get

  def self.instances
    globals = []
    Cisco::PortChannelGlobal.globals.each do |global_id, v|
      globals << properties_get(global_id, v)
    end
    globals
  end

  def self.prefetch(resources)
    globals = instances

    resources.keys.each do |id|
      provider = globals.find { |global| global.instance_name == id }
      resources[id].provider = provider unless provider.nil?
    end
  end # self.prefetch

  def instance_name
    name
  end

  def properties_set
    PC_GLOBAL_ALL_PROPS.each do |prop|
      next unless @resource[prop]
      unless @property_flush[prop].nil?
        @pc_global.send("#{prop}=", @property_flush[prop]) if
          @pc_global.respond_to?("#{prop}=")
      end
    end
    # custom setters which require one-shot multi-param setters
    port_channel_load_balance_sym_concat_rot_set
    port_channel_load_balance_hash_poly_set
    port_channel_load_balance_asym_rot_set
  end

  # for n9k/n3k:
  # port-channel load-balance src-dst ip rotate 4 concatenation symmetric
  # all the above properties will be set all at once so make sure
  # all the needed resources are present
  def port_channel_load_balance_sym_concat_rot_all?
    @resource[:bundle_hash] &&
      @resource[:bundle_select] &&
      @resource[:concatenation] &&
      @resource[:symmetry] &&
      @resource[:rotate]
  end

  def port_channel_load_balance_sym_concat_rot_set
    return unless port_channel_load_balance_sym_concat_rot_all?
    if @property_flush[:bundle_hash]
      bh = @property_flush[:bundle_hash]
    else
      bh = @pc_global.bundle_hash
    end
    if @property_flush[:bundle_select]
      bs = @property_flush[:bundle_select]
    else
      bs = @pc_global.bundle_select
    end
    # if the boolean values are same as before, puppet server will not send
    # concatenation, but we need it, otherwise, it will be set to false in the
    # config so send the previous value even if the config is same as before
    if @property_flush[:concatenation].nil?
      cc = @pc_global.concatenation
    elsif @property_flush[:concatenation] != @pc_global.concatenation
      cc = @property_flush[:concatenation]
    else
      cc = @pc_global.concatenation
    end
    # if the boolean values are same as before, puppet server will not send
    # symmetry, but we need it, otherwise, it will be set to false in the
    # config so send the previous value even if the config is same as before
    if @property_flush[:symmetry].nil?
      sy = @pc_global.symmetry
    elsif @property_flush[:symmetry] != @pc_global.symmetry
      sy = @property_flush[:symmetry]
    else
      sy = @pc_global.symmetry
    end
    if @property_flush[:rotate]
      ro = @property_flush[:rotate]
    else
      ro = @pc_global.rotate
    end
    if ro > 0 && cc == false
      fail 'concatenation MUST be true when rotate is non-zero'
    end
    if bs.to_s != 'src-dst' && sy == true
      fail 'Symmetric can be true only for src-dst bundle-select'
    end
    @pc_global.send(:port_channel_load_balance=,
                    bs.to_s, bh.to_s, nil, nil, sy, cc, ro)
  end

  # for n6k/n5k:
  # port-channel load-balance ethernet source-dest-ip CRC10c
  # all the above properties will be set all at once so make sure
  # all the needed resources are present
  def port_channel_load_balance_hash_poly_all?
    @resource[:bundle_hash] &&
      @resource[:bundle_select] &&
      @resource[:hash_poly]
  end

  def port_channel_load_balance_hash_poly_set
    return unless port_channel_load_balance_hash_poly_all?
    if @property_flush[:bundle_hash]
      bh = @property_flush[:bundle_hash]
    else
      bh = @pc_global.bundle_hash
    end
    if @property_flush[:bundle_select]
      bs = @property_flush[:bundle_select]
    else
      bs = @pc_global.bundle_select
    end
    if @property_flush[:hash_poly]
      hp = @property_flush[:hash_poly]
    else
      hp = @pc_global.hash_poly
    end
    @pc_global.send(:port_channel_load_balance=,
                    bs.to_s, bh.to_s, hp.to_s, nil, nil, nil, nil)
  end

  # for n6k/n5k:
  # port-channel load-balance src-dst ip rotate 4 asymmetric
  # all the above properties will be set all at once so make sure
  # all the needed resources are present
  def port_channel_load_balance_asym_rot_all?
    @resource[:bundle_hash] &&
      @resource[:bundle_select] &&
      @resource[:asymmetric] &&
      @resource[:rotate]
  end

  def port_channel_load_balance_asym_rot_set
    return unless port_channel_load_balance_asym_rot_all?
    if @property_flush[:bundle_hash]
      bh = @property_flush[:bundle_hash]
    else
      bh = @pc_global.bundle_hash
    end
    if @property_flush[:bundle_select]
      bs = @property_flush[:bundle_select]
    else
      bs = @pc_global.bundle_select
    end
    # if the boolean values are same as before, puppet server will not send
    # asymmetric, but we need it, otherwise, it will be set to false in the
    # config so send the previous value even if the config is same as before
    if @property_flush[:asymmetric].nil?
      as = @pc_global.asymmetric
    elsif @property_flush[:asymmetric] != @pc_global.asymmetric
      as = @property_flush[:asymmetric]
    else
      as = @pc_global.asymmetric
    end
    if @property_flush[:rotate]
      ro = @property_flush[:rotate]
    else
      ro = @pc_global.rotate
    end
    @pc_global.send(:port_channel_load_balance=,
                    bs.to_s, bh.to_s, nil, as, nil, nil, ro)
  end

  def flush
    properties_set
    puts_config
  end

  def puts_config
    # Dump all current properties for this global
    current = sprintf("\n%30s: %s", 'name', instance_name)
    PC_GLOBAL_ALL_PROPS.each do |prop|
      current.concat(sprintf("\n%30s: %s", prop, @pc_global.send(prop)))
    end
    debug current
  end # puts_config
end   # Puppet::Type
