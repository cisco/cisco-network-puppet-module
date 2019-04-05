#
# Cisco platform_get puppet manifest function.
#
#
# Copyright (c) 2018 Cisco and/or its affiliates.
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

Puppet::Functions.create_function(:platform_get) do
  require 'puppet/util'
  require 'puppet/util/network_device'
  def platform_get
    if Puppet::Util::NetworkDevice.current.nil?
      data = Facter.value('cisco')
    else
      data = Puppet::Util::NetworkDevice.current.facts['cisco']
    end
    return '' if data.nil?
    pi = data['hardware']['type']
    # The following kind of string info is returned for Nexus.
    # - Nexus9000 C9396PX Chassis
    # - Nexus7000 C7010 (10 Slot) Chassis
    # - Nexus 6001 Chassis
    # - NX-OSv Chassis
    case pi
    when /Nexus\s?3\d\d\d/
      if call_function('platform_fretta')
        cisco_hardware = 'n3k-f'
      else
        cisco_hardware = 'n3k'
      end
    when /Nexus\s?5\d\d\d/
      cisco_hardware = 'n5k'
    when /Nexus\s?6\d\d\d/
      cisco_hardware = 'n6k'
    when /Nexus\s?7\d\d\d/
      cisco_hardware = 'n7k'
    when /Nexus\s?9\d+\s\S+-EX/
      cisco_hardware = 'n9k-ex'
    when /(Nexus\s?9\d\d\d|NX-OSv Chassis)/
      if call_function('platform_fretta')
        cisco_hardware = 'n9k-f'
      else
        cisco_hardware = 'n9k'
      end
    else
      fail Puppet::ParseError, "Unrecognized platform type: #{pi}\n#{__FILE__}"
    end
    cisco_hardware
  end
end
