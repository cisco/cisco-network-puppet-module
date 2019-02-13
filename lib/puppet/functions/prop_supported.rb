#
# Cisco prop_supported puppet manifest function.
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

Puppet::Functions.create_function(:prop_supported) do
  def prop_supported(prop)
    # Use catch-all arrays for common properties
    evpn = [:route_target_both_auto_evpn,
            :route_target_import_evpn,
            :route_target_export_evpn,]
    mvpn = [:route_target_both_auto_mvpn,
            :route_target_import_mvpn,
            :route_target_export_mvpn,]
    rt = [:route_target_both_auto,
          :route_target_import,
          :route_target_export,]

    plat = call_function('platform_get')
    case prop.to_sym
    when :route_distinguisher, *evpn, *rt
      return true if plat[/n7k/] && call_function('find_linecard', 'N7K-F3')
      return true if plat[/n9k/]
    when *mvpn
      return true if plat[/n9k(-ex)?$/]
    end
    false
  end
end
