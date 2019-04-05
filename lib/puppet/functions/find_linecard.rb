#
# Cisco find_linecard puppet manifest function.
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

Puppet::Functions.create_function(:find_linecard) do
  require 'puppet/util'
  require 'puppet/util/network_device'
  def find_linecard(linecard)
    if Puppet::Util::NetworkDevice.current.nil?
      data = Facter.value('cisco')
    else
      data = Puppet::Util::NetworkDevice.current.facts['cisco']
    end
    return '' if data.nil?

    pat = Regexp.new(linecard)
    inv = data['inventory']
    match = inv.keys.select { |slot| inv[slot]['pid'].match(pat) }
    match.empty? ? '' : match[0][/(\d+)/]
  end
end
