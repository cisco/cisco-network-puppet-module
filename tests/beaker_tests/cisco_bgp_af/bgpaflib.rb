#
# BgpAFLib Module Library:
# ----------------------
# bgpaflib.rb
#
# Utility module library for cisco_bgp_af puppet provider beaker
# test cases. All cisco_bgp_af provider test cases require the
# BgpAfLib module.
#
# Copyright (c) 2015 Cisco and/or its affiliates.
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

require File.expand_path('../../lib/utilitylib.rb', __FILE__)

# Full command string for puppet resource with AF
def puppet_resource_cmd(af)
  get_namespace_cmd(agent,
                    BgpAFLib.resource_cmd(af),
                    options)
end

# Utility module library for cisco_bgp_af puppet provider beaker tests.
module BgpAFLib
  # puppet resource command for address-families
  def self.resource_cmd(af)
    UtilityLib::PUPPET_BINPATH + \
      "resource cisco_bgp_af '#{af.values.join(' ')}'"
  end

  # Search pattern for show command testing
  def self.af_pattern(af)
    asn, vrf, afi, safi = *af.values

    if vrf[/default/]
      [/router bgp #{asn}/,
       /address-family #{afi} #{safi}/]
    else
      [/router bgp #{asn}/, /vrf #{vrf}/,
       /address-family #{afi} #{safi}/]
    end
  end

  # Auto generation of ID properties for manifests
  def self.manifest_id_props(af)
    manifest_str = ''
    af.each do |key, v|
      next if v.to_s.empty?
      manifest_str += "#{key} => '#{v}',\n"
    end
    manifest_str
  end
end
