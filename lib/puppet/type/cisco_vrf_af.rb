# Manage a Cisco VRF Address-Family.
#
# January 2016, Chris Van Heuveln
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

Puppet::Type.newtype(:cisco_vrf_af) do
  @doc = "Manage a Cisco VRF Address-Family.
  ~~~puppet
  cisco_vrf_af {'<title>':
    ..attributes..
  }
  ~~~

  <title> is the title of the vrf_af resource.

  Example:
  ~~~puppet
    cisco_vrf_af {'red ipv4 unicast':
      ensure                       => present,
      #afi                         => 'ipv4',
      #safi                        => 'unicast',
      route_target_both_auto       => 'true',
      route_target_both_auto_evpn  => 'false',
      route_target_export          => ['1.2.3.4:55', '8:9'],
      route_target_export_evpn     => ['1:1', '2:2', '3:3'],
      route_target_import          => ['5:6'],
      route_target_import_evpn     => ['7:7'],
    }
  ~~~

  Example Title Patterns:

  ~~~puppet
    cisco_vrf_af { 'red ipv4 unicast':
      ensure => present,
  ~~~

  ~~~puppet
    cisco_vrf_af { 'red':
      ensure => present,
      afi    => 'ipv4',
      safi   => 'unicast',
  ~~~

  ~~~puppet
    cisco_vrf_af { 'red ipv4':
      ensure => present,
      safi   => 'unicast',
  ~~~

  "

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    [
      [ # 'red ipv4 unicast'
        /^(\S+)\s+(\S+)\s+(\S+)$/,
        [
          [:vrf, identity],
          [:afi, identity],
          [:safi, identity],
        ],
      ],
      [ # 'red ipv4'
        /^(\S+)\s+(\S+)$/,
        [
          [:vrf, identity],
          [:afi, identity],
        ],
      ],
      [ # 'red'
        /^(\S+)$/,
        [
          [:vrf, identity]
        ],
      ],
    ]
  end

  # Overwrites the name method which by default returns only
  # self[:name].
  def name
    "#{self[:vrf]} #{self[:afi]} #{self[:safi]}"
  end

  # Only needed to satisfy name parameter.
  newparam(:name) do
  end

  newparam(:vrf, namevar: :true) do
    desc "Name of the VRF. Valid value is a string of non-whitespace
          characters. It is not case-sensitive."
    munge do |value|
      value.downcase.strip
    end
  end

  newparam(:afi, namevar: true) do
    desc "VRF Address-family AFI. Valid values are 'ipv4 or 'ipv6'."
    newvalues(:ipv4, :ipv6)
  end

  newparam(:safi, namevar: true) do
    desc "VRF Address-family SAFI. Valid values are 'unicast' or 'multicast'."\
         "Note: 'multicast' is not supported on some platforms."
    newvalues(:unicast, :multicast)
  end

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:route_target_both_auto) do
    desc "Enable/Disable route-target 'auto' for both import and export "\
         "target communities. Valid values are true, false, or 'default'."

    newvalues(:true, :false, :default)
  end # property route_target_both_auto

  newproperty(:route_target_both_auto_evpn) do
    desc "(EVPN only) Enable/Disable route-target 'auto' for both import and "\
         'export target EVPN communities. Valid values are true, false, or '\
         "'default'."

    newvalues(:true, :false, :default)
  end # property route_target_both_auto_evpn

  newproperty(:route_target_import, array_matching: :all) do
    desc 'Set the route-target import extended communities. Valid values are '\
         'an Array, a space-separated String of extended communities, or the '\
         "keyword 'default'."

    match_error = 'must be specified in AS:nn or IPv4:nn notation'
    validate do |community|
      community.split.each do |value|
        fail "Confederation peer value '#{value}' #{match_error}" unless
          /^(?:\d+\.\d+\.\d+\.)?\d+:\d+$/.match(value) ||
          value == 'default' || value == :default
      end
    end

    munge do |community|
      community == 'default' ? :default : community.split
    end

    def insync?(is)
      (is.size == should.flatten.size && is.sort == should.flatten.sort)
    end
  end # route_target_import

  newproperty(:route_target_import_evpn, array_matching: :all) do
    desc '(EVPN only) Set the route-target import extended communities. '\
         'Valid values are an Array, a space-separated String of extended '\
         "communities, or the keyword 'default'."

    match_error = 'must be specified in AS:nn or IPv4:nn notation'
    validate do |community|
      community.split.each do |value|
        fail "Confederation peer value '#{value}' #{match_error}" unless
          /^(?:\d+\.\d+\.\d+\.)?\d+:\d+$/.match(value) ||
          value == 'default' || value == :default
      end
    end

    munge do |community|
      community == 'default' ? :default : community.split
    end

    def insync?(is)
      (is.size == should.flatten.size && is.sort == should.flatten.sort)
    end
  end # route_target_import_evpn

  newproperty(:route_target_export, array_matching: :all) do
    desc 'Set the route-target export extended communities. Valid values are '\
         'an Array, a space-separated String of extended communities, or the '\
         "keyword 'default'."

    match_error = 'must be specified in AS:nn or IPv4:nn notation'
    validate do |community|
      community.split.each do |value|
        fail "Confederation peer value '#{value}' #{match_error}" unless
          /^(?:\d+\.\d+\.\d+\.)?\d+:\d+$/.match(value) ||
          value == 'default' || value == :default
      end
    end

    munge do |community|
      community == 'default' ? :default : community.split
    end

    def insync?(is)
      (is.size == should.flatten.size && is.sort == should.flatten.sort)
    end
  end # route_target_export

  newproperty(:route_target_export_evpn, array_matching: :all) do
    desc '(EVPN only) Set the route-target export extended communities. '\
         'Valid values are an Array, a space-separated String of extended '\
         "communities, or the keyword 'default'."

    match_error = 'must be specified in AS:nn or IPv4:nn notation'
    validate do |community|
      community.split.each do |value|
        fail "Confederation peer value '#{value}' #{match_error}" unless
          /^(?:\d+\.\d+\.\d+\.)?\d+:\d+$/.match(value) ||
          value == 'default' || value == :default
      end
    end

    munge do |community|
      community == 'default' ? :default : community.split
    end

    def insync?(is)
      (is.size == should.flatten.size && is.sort == should.flatten.sort)
    end
  end # route_target_export_evpn
end # Puppet::Type.newtype
