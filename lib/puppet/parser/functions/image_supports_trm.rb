#
# Cisco image_supports_trm puppet manifest function.
#
# February 2018, Rahul J Shenoy
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

module Puppet
  module Parser
    # Function platform_fretta.
    # Searches facter os.release.full and returns true if the
    # version matches the fretta image version.
    #
    module Functions
      newfunction(:image_supports_trm, type: :rvalue) do |_args|
        data = lookupvar('os')
        return '' if data.nil?

        pat = /I[2-6]/
        image = data['release']['full']
        image[pat].nil? ? true : false
      end
    end
  end
end
