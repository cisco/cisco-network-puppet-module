#
# Cisco find_linecard puppet manifest function.
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
    # Function find_linecard.
    # Searches facter[cisco][inventory][Slot #][pid] for matching product ID.
    #
    # Input : String, Linecard name, eg. 'N7K-F3'
    # Output: Slot number of first match found
    #
    module Functions
      newfunction(:find_linecard, type: :rvalue) do |args|
        data = lookupvar('cisco')
        return '' if data.nil?

        pat = Regexp.new(args[0])
        inv = data['inventory']
        match = inv.keys.select { |slot| inv[slot]['pid'].match(pat) }
        match.empty? ? '' : match[0][/(\d+)/]
      end
    end
  end
end
