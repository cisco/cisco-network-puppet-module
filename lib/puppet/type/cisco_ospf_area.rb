# Manages the Cisco OSPF area configuration resource.
#
# June 2016
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

Puppet::Type.newtype(:cisco_ospf_area) do
  @doc = "Manages an area for an OSPF router.

    cisco_ospf_area {\"<ospf> <vrf> <area>\":
      ..attributes..
    }

    <ospf> is the name of the ospf router instance.
    <vrf> is the name of the ospf vrf.
    <area> is the name of the ospf area instance.

    Example:
    cisco_ospf_area {'myrouter vrf1 1.1.1.1':
      ensure          => 'present',
      authentication  => 'md5',
      default_cost    => 1000,
      filter_list_in  => 'fin',
      filter_list_out => 'fout',
      range           => [['10.3.0.0/16', true, '23'],
                          ['10.3.3.0/24', false, '450']],
      stub_no_summary => true,
    }
  "

  ensurable

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\S+) (\S+) (\S+)$/,
      [
        [:ospf, identity],
        [:vrf, identity],
        [:area, identity],
      ],
    ]
    patterns
  end

  # Overwrites name method. Original method simply returns self[:name],
  # which is no longer valid or complete.
  # Would not have failed, but just return nothing useful.
  def name
    "#{self[:ospf]} #{self[:vrf]} #{self[:area]}"
  end

  newparam(:name) do
    desc 'Name of cisco_ospf_area, not used, but needed for puppet'
  end

  newparam(:area, namevar: true) do
    desc 'Name of the resource instance. Valid values are string.'
    munge do |value|
      value = IPAddr.new(value.to_i, Socket::AF_INET) unless
        value[/\./]
      value
    end
  end # param area

  newparam(:vrf, namevar: true) do
    desc "Name of the vrf instance. Valid values are string. The
          name 'default' is a valid VRF."
  end # param vrf

  newparam(:ospf, namevar: true) do
    desc 'Name of the ospf instance. Valid values are string.'
  end # param ospf

  ##############
  # Attributes #
  ##############

  newproperty(:authentication) do
    desc 'Enable authentication for the area.'

    newvalues(:clear_text, :md5, :default)
  end # property authentication

  newproperty(:default_cost) do
    desc "default_cost for default summary Link-State Advertisement (LSA).
          Valid values are integer, keyword 'default'."

    munge { |value| value == 'default' ? :default : Integer(value) }
  end # property default_cost

  newproperty(:filter_list_in) do
    desc "This is a route-map for filtering networks sent to this area.
          Valid values are string, keyword 'default'. "

    munge { |value| value == 'default' ? :default : value }
  end # property filter_list_in

  newproperty(:filter_list_out) do
    desc "This is a route-map for filtering networks sent from this area.
          Valid values are string, keyword 'default'. "

    munge { |value| value == 'default' ? :default : value }
  end # property filter_list_out

  newproperty(:range, array_matching: :all) do
    format = '[[summary_address, not_advertise, cost], [sa, na, co]]'
    desc 'An array of [summary_address, not_advertise, cost] pairs. '\
         "Valid values match format #{format}."

    # Override puppet's insync method, which checks whether current value is
    # equal to value specified in manifest.  Make sure puppet considers
    # 2 arrays with same elements but in different order as equal.
    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end

    # override should_to_s and is_to_s for nested arrays
    # to get clean output in the puppet notice like
    # range changed '[]' to '[["10.3.0.0/16", "not_advertise", "23"],
    # ["10.3.3.0/24", "450"]]
    # instead of
    # range changed [] to '10.3.0.0/16 not_advertise 23 10.3.3.0/24 450'
    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end

    munge do |value|
      begin
        return value = :default if value == 'default'
        fail("Value must match format #{format}") unless value.is_a?(Array)
        value
      end
    end
  end # property range

  newproperty(:stub) do
    desc 'Defines the area as a stub area. This property is not necessary
          when the `stub_no_summary` property is set to true, which also
          defines the area as a stub area.'

    newvalues(:true, :false, :default)
  end # property stub

  newproperty(:stub_no_summary) do
    desc 'Stub areas flood summary LSAs. This property disables summary
          flooding into the area. This property can be used in place of
          the `stub` property or in conjunction with it.'

    newvalues(:true, :false, :default)
  end # property stub_no_summary

  validate do
    # validate that stub cannot be false when
    # stub_no_summary is true only if both
    # properties are given in the manifest
    return if
      self[:stub_no_summary].nil? || self[:stub].nil?
    fail ArgumentError,
         'stub MUST be true when stub_no_summary is true' if
      self[:stub_no_summary] == :true && self[:stub] != :true
  end
end
