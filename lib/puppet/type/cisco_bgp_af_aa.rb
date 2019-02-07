# Manages the Cisco Bgp_af_aa configuration resource.
#
# June 2018
#
# Copyright (c) 2017-2018 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_bgp_af_aa) do
  @doc = "Manages a cisco BGP Address family aggregate address

    cisco_bgp_af_aa { '<title>':
      ..attributes..
    }

    `<title>` is the title of the bgp_af_aa resource

Example:

    cisco_bgp_af_aa{ '55.77 default ipv4 multicast 1.1.1.1/32':
      ensure  => 'present',
      as_set   => 'true',
      summary_only   => 'false',
      advertise_map   => 'adm',
      attribute_map   => 'atm',
      suppress_map   => 'sum',
    }
  "

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    [
      [
        /^(\d+|\d+\.\d+) (\S+) (\S+) (\S+) (\S+)$/,
        [
          [:asn, identity],
          [:vrf, identity],
          [:afi, identity],
          [:safi, identity],
          [:aa, identity],
        ],
      ]
    ]
  end

  ##############
  # Parameters #
  ##############

  apply_to_all
  ensurable

  # Overwrites the name method which by default returns only
  # self[:name].
  def name
    "#{self[:asn]} #{self[:vrf]} #{self[:afi]} #{self[:safi]} #{self[:aa]}"
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

  newparam(:aa, namevar: true) do
    desc 'BGP aggregate address prefix. Valid values are String.'
    munge do |value|
      begin
        value = PuppetX::Cisco::Utils.process_network_mask(value) unless value.nil?
        value
      rescue
        raise 'aggregate address must be in valid address/length format'
      end
    end
  end

  ##############
  # Attributes #
  ##############

  newproperty(:as_set) do
    desc "Generates autonomous system set path information. Valid values are true, false or 'default'"

    newvalues(:true, :false, :default)
  end # property as_set

  newproperty(:summary_only) do
    desc "Filters all more-specific routes from updates.  Valid values are true, false or 'default'"

    newvalues(:true, :false, :default)
  end # property summary_only

  newproperty(:advertise_map) do
    desc "Name of the route map used to select the routes to create AS_SET origin communities. Valid values are String or 'default'"

    munge { |value| value == 'default' ? :default : value }
  end # property advertise_map

  newproperty(:attribute_map) do
    desc "Name of the route map used to set the attribute of the aggregate route. Valid values are String or 'default'"

    munge { |value| value == 'default' ? :default : value }
  end # property attribute_map

  newproperty(:suppress_map) do
    desc "Name of the route map used to select the routes to be suppressed. Valid values are String or 'default'"

    munge { |value| value == 'default' ? :default : value }
  end # property suppress_map
end
