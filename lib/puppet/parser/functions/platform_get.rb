#
# Cisco platform_get puppet manifest function.
#
# January, 2016
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

module Puppet
  module Parser
    # Function platform_get.  Returns platform string.
    module Functions
      newfunction(:platform_get, type: :rvalue) do |_args|
        data = lookupvar('cisco')
        return '' if data.nil?
        pi = data['hardware']['type']
        # The following kind of string info is returned for Nexus.
        # - Nexus9000 C9396PX Chassis
        # - Nexus7000 C7010 (10 Slot) Chassis
        # - Nexus 6001 Chassis
        # - NX-OSv Chassis
        case pi
        when /Nexus\s?3\d\d\d/
          cisco_hardware = 'n3k'
        when /Nexus\s?5\d\d\d/
          cisco_hardware = 'n5k'
        when /Nexus\s?6\d\d\d/
          cisco_hardware = 'n6k'
        when /Nexus\s?7\d\d\d/
          cisco_hardware = 'n7k'
        when /Nexus\s?8\d\d\d/
          cisco_hardware = 'n8k'
        when /NX-OSv8K/
          cisco_hardware = 'n8k'
        when /Nexus\s?9\d\d\d/
          cisco_hardware = 'n9k'
        when /NX-OSv Chassis/
          cisco_hardware = 'n9k'
        else
          fail Puppet::ParseError, "Unrecognized platform type: #{pi}\n#{__FILE__}"
        end
        cisco_hardware
      end
    end
  end
end
