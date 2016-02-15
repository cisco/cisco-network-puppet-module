#
# Cisco prop_supported puppet manifest function.
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

module Puppet
  module Parser
    # Function prop_supported.
    # Input: Property name
    # Output: Boolean. True if current platform can support the property
    module Functions
      newfunction(:prop_supported, type: :rvalue) do |args|
        # Use catch-all arrays for common properties
        evpn = [:route_target_both_auto_evpn,
                :route_target_import_evpn,
                :route_target_export_evpn,
               ]
        rt = [:route_target_both_auto,
              :route_target_import,
              :route_target_export,
             ]

        plat = function_platform_get([])
        case args[0].to_sym
        when *evpn,
             *rt,
             :route_distinguisher
          return true if plat[/n7k/] && function_find_linecard(['N7K-F3'])
          return true if plat[/n9k/]
        end
        false
      end
    end
  end
end
