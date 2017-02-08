# October, 2013
#
# Copyright (c) 2013-2016 Cisco and/or its affiliates.
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

Puppet::Type.type(:cisco_command_config).provide(:cisco) do
  confine feature: :cisco_node_utils
  defaultfor operatingsystem: [:ios_xr, :nexus]

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
    running_config_str = @node.get(command: 'show running-config all')

    # Sanitize configs and create config hashes.
    running_hash  = Cisco::ConfigParser::Configuration.new(running_config_str)
    manifest_hash = Cisco::ConfigParser::Configuration.new(@resource[:command])

    # Compare full manifest config to running-config.
    strip_pattern = Regexp.new('^ *| *$|\s')
    existing_str = manifest_hash.compare_with(running_hash).gsub(strip_pattern, '')
    debug "Existing:\n>#{existing_str.inspect}<"

    manifest_config_str =
      Cisco::ConfigParser::Configuration.config_hash_to_str(
        manifest_hash.configuration).gsub(strip_pattern, '')
    debug "Manifest:\n>#{manifest_config_str.inspect}<"

    if existing_str.include?(manifest_config_str)
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
    output = @node.set(values: cmds)
    debug "Output from node:\n#{output}" unless output.nil?

  rescue Cisco::CliError => e
    # Tell the user what succeeded, then fail with the actual failure.
    unless e.successful_input.empty?
      info "Successfully updated:\n#{e.successful_input.join("\n")}"
    end
    raise
  end # command=

  def test_get
    # This method is for beaker use only. It allows beaker to retrieve any
    # configuration it needs from the device using puppet resource. Callers
    # must pass a filter string to test_get.
    # Example usage:
    #  puppet resource cisco_command_config 'cc' test_get='incl feature'
    cmd = 'show running-config all'
    cmd << " | #{@resource[:test_get]}" if @resource[:test_get]

    output = @node.get(command: cmd)
    debug "@node.get output:\n#{output}"
    "\n" + output unless output.nil?
  end

  def test_get=(noop)
    # This is a dummy "setter" for test_get(), which is a get-only property.
    # This dummy method is necessary to keep Puppet from raising an error or
    # displaying noise.
  end

  def test_set
    # This is a dummy "getter" for test_set=(), which is a set-only property.
    # This dummy method is necessary to keep Puppet from raising an error or
    # displaying noise.
  end

  def test_set=(cmds)
    # This method is for beaker use only. It allows beaker to set simple raw
    # configuration using puppet resource.
    # Example usage:
    #  puppet resource cisco_command_config 'cc' test_set='no feature foo'
    return if cmds.empty?
    output = @node.set(values: cmds)
    debug "@node.set output:\n#{output}" unless output.nil?
  end
end # Puppet::Type
