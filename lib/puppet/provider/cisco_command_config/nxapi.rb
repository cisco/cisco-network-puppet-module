# The nxapi provider.
#
# October, 2013
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

require 'cisco_node_utils' if Puppet.features.cisco_node_utils?

Puppet::Type.type(:cisco_command_config).provide(:nxapi) do
  confine feature: :cisco_node_utils
  defaultfor operatingsystem: :nexus

  def initialize(value={})
    super(value)
    @node = Cisco::Node.instance
    debug 'Created provider instance of cisco_command_config.'
  end

  def self.instances
    []
  end

  def self.prefetch(resources)
    resources
  end

  def command
    running_config_str = @node.show('show running-config all')

    # Sanitize configs and create config hashes.
    running_hash  = Cisco::ConfigParser::Configuration.new(running_config_str)
    manifest_hash = Cisco::ConfigParser::Configuration.new(@resource[:command])

    # Compare full manifest config to running-config.
    existing_str = manifest_hash.compare_with(running_hash)
    debug "Existing:\n>#{existing_str}<"
    manifest_config_str =
      Cisco::ConfigParser::Configuration.config_hash_to_str(
        manifest_hash.configuration)
    debug "Manifest:\n>#{manifest_config_str}<"

    if existing_str.gsub(/^ *| *$/, '').include?(manifest_config_str)
      debug 'Current running-config already satisfies manifest'
      @property_hash[:command] = @resource[:command]
    else
      debug 'Some or all of the manifest config differs from running-config'
      # Detect the minimum set of changes that need to be applied
      existing_hash = Cisco::ConfigParser::Configuration.new(existing_str)
      min_config_hash =
        Cisco::ConfigParser::Configuration.build_min_config_hash(
          existing_hash.configuration,
          manifest_hash.configuration)
      @resource[:command] =
        Cisco::ConfigParser::Configuration.config_hash_to_str(min_config_hash)
      debug "Minimum changeset to satisfy manifest:\n>#{@resource[:command]}<"
    end
    @property_hash[:command]
  end # command

  def command=(cmds)
    return if cmds.empty?
    output = @node.config(cmds)
    debug "Output from node:\n#{output}" unless output.nil?

  rescue Cisco::CliError => e
    # Tell the user what succeeded, then fail with the actual failure.
    info "Successfully updated:\n#{e.previous.join("\n")}" unless e.previous.empty?
    raise
  end # command=
end # Puppet::Type
