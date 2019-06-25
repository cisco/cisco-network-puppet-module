#
# Cisco image_supports_trm puppet manifest function.
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

Puppet::Functions.create_function(:image_supports_trm) do
  require 'puppet/util'
  require 'puppet/util/network_device'
  def image_supports_trm
    if Puppet::Util::NetworkDevice.current.nil?
      data = Facter.value('os')['release']['full']
    else
      data = Puppet::Util::NetworkDevice.current.facts['cisco']['images']['full_version']
    end
    return '' if data.nil?

    pat = /I[2-6]/
    image = data
    image[pat].nil? ? true : false
  end
end
