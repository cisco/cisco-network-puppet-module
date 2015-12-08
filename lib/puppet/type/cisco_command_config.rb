# Manages the Cisco network element that it connects to.
#
# September, 2013
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
#
# The `cisco_command_config` type allows raw configurations to be managed
# by puppet. It serves as a stopgap until specialized types are created.
#
# It has the following limitations:
# * The input message buffer is limited to 500KB
# * Order is important. Some dependent commands may fail if their associated
#   `feature` configuration is not enabled first
# * Indentation counts! It implies sub-mode configuration. Use the switch's
#   running-config as a guide and do not indent configurations that are not
#   normally indented. Do not use tabs to indent.
# * Inline comments must be prefixed by ! or #
# * Negating a submode will also remove configuratons under that submode,
#   without having to specify every submode config statement:
#   `no router ospf RED` removes all configuration under router ospf RED
# * Syntax does not auto-complete: use `Ethernet1/1`, not `Eth1/1`
# * If a CLI command is rejected during configuration, the resource will abort
#   at that point and will not continue to issue any remaining CLI. For this
#   reason it is recommended to limit the scope of each instance of this
#   resource.

Puppet::Type.newtype(:cisco_command_config) do
  @doc = "Allows execution of configuration commands.

  cisco_command_config {\"<name>\":
    ..attributes..
  }

  <name> is the name of the cisco_command_config instance.

  Example
    cisco_command_config {\"feature-config\":
      command => \"
                  feature interface-vlan\"
    }

    cisco_command_config {\"feature-intf-portchannel2\":
      command => \"
                  interface Vlan20
                    no ip redirects
                    ip address 17.159.249.1/24
                    ip dhcp relay address 17.158.158.16
                    ip dhcp relay address 17.158.156.10
                    ip dhcp relay address 17.158.4.32
                    no shutdown\"
      require => cisco_command_config [\"feature-config\"],
    }

  <require> is optional.
  "

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches the instance name.
    patterns << [
      /^(\S+)$/,
      [
        [:name, identity]
      ],
    ]
    patterns
  end

  newparam(:name) do
  end

  ############################
  # Configuration Attributes #
  ############################

  newproperty(:command) do
    desc "Configuration command(s) to be applied to the network
          element. Valid values are string."

    munge do |value|
      # split off into validate function
      fail('Unrecognized input format.') unless value.class == String
      value << "\n"
      value.gsub!(/^\s*$\n/, '')
      indent_level = value.match(/\A\s*/)
      value.gsub!(/^(#{indent_level})/, '') # remove extra indentation
    end # validate
  end # property command
end # Puppet::Type.newtype
