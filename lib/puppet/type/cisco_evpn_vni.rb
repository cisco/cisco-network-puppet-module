#
# December 2015
#
# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_evpn_vni) do
  @doc = %(Manages a Cisco Evpn Vni.

  cisco_evpn_vni {'<vni>':
    ..attributes..
  }

  <vni> is the id of the vni.

  Example:
    $both =   ['1.2.3.4:55', '2:2', '55:33', 'auto']
    $export = ['1.2.3.4:55', '2:2', '55:33', 'auto']
    $import = ['1.2.3.4:55', '2:2', '55:33', 'auto']

    cisco_evpn_vni {'4096':
      ensure                    => present,
      route_distinguisher       => 'auto',
      route_target_both         => $both,
      route_target_export       => $export,
      route_target_import       => $import,
    }
  )

  ##############
  # Parameters #
  ##############
  newparam(:vni, namevar: true) do
    desc 'ID of the Evpn Vni. Valid values are integer.'
  end

  ##############
  # Attributes #
  ##############

  ensurable

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

  newproperty(:route_target_both, array_matching: :all) do
    desc "Sets the route-target both extended communities. Valid
         values are an Array or space-separated String of extended
         communities, or the keyword 'default'."

    match_error = 'must be specified in auto AS:nn or IPv4:nn notation'

    validate do |community|
      community.split.each do |value|
        fail "Confederation peer value '#{value}' #{match_error}" unless
          /^(?:\d+\.\d+\.\d+\.)?\d+:\d+$/.match(value) || value == 'auto' ||
          value == 'default' || value == :default
      end
    end

    munge do |community|
      community == 'default' ? :default : community.split
    end

    def insync?(is)
      (is.size == should.flatten.size && is.sort == should.flatten.sort)
    end
  end # route_target_both

  newproperty(:route_target_export, array_matching: :all) do
    desc "Sets the route-target export extended communities. Valid
         values are an Array or space-separated String of extended
         communities, or the keyword 'default'."

    match_error = 'must be specified in auto AS:nn or IPv4:nn notation'

    validate do |community|
      community.split.each do |value|
        fail "Confederation peer value '#{value}' #{match_error}" unless
          /^(?:\d+\.\d+\.\d+\.)?\d+:\d+$/.match(value) || value == 'auto' ||
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

  newproperty(:route_target_import, array_matching: :all) do
    desc "Sets the route-target import extended communities. Valid
         values are an Array or space-separated String of extended
         communities, or the keyword 'default'."

    match_error = 'must be specified in auto AS:nn or IPv4:nn notation'

    validate do |community|
      community.split.each do |value|
        fail "Confederation peer value '#{value}' #{match_error}" unless
          /^(?:\d+\.\d+\.\d+\.)?\d+:\d+$/.match(value) || value == 'auto' ||
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
end # Puppet::Type.newtype
