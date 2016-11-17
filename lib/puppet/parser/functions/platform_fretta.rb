#
# Cisco platform_fretta puppet manifest function.
#
# November 2016, Michael G Wiebe
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
    # Function platform_fretta.
    # Searches facter os.release.full and returns true if the
    # version matches the fretta image version.
    #
    module Functions
      newfunction(:platform_fretta, type: :rvalue) do |_args|
        data = lookupvar('os')
        return '' if data.nil?

        pat = '7.0\(3\)F'
        data['release']['full'].match(pat) ? true : false
      end
    end
  end
end
