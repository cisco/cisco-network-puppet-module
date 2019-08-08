# PuppetX::Cisco - Common utility methods used by Cisco Types/Providers
#
# November 2015
#
# Copyright (c) 2015-2018 Cisco and/or its affiliates.
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

module PuppetX
  module Cisco
    # PuppetX::Cisco::Utils: - Common helper methods shared by any Type/Provider
    # rubocop:disable Metrics/ClassLength
    class Utils
      require 'ipaddr'

      TACACS_SERVER_ENC_NONE = 0
      TACACS_SERVER_ENC_CISCO_TYPE_7 = 7
      TACACS_SERVER_ENC_UNKNOWN = 8

      # Helper method to get data from the facts hash
      def self.facts_ref
        require 'puppet/util/network_device'
        if Puppet::Util::NetworkDevice.current.nil?
          # agent-based
          Facter.value('cisco')
        else
          # agentless
          Puppet::Util::NetworkDevice.current.facts['cisco']
        end
      end

      # Helper method to get the interface threshold value
      def self.interface_threshold
        if Gem::Version.new(CiscoNodeUtils::VERSION) <= Gem::Version.new('2.0.2')
          info '## Notice: cisco_node_utils gem does not contain interface lookup enhancements.'
          info '## Notice: Unable to prefetch interfaces independently, using legacy lookup methods instead.'
          info '## Notice: Please upgrade cisco_node_utils to v2.1.0 or newer'
          return 0
        end
        facts_ref['interface_threshold']
      end

      # Helper utility method for ip/prefix format networks.
      # For ip/prefix format '1.1.1.1/24' or '2000:123:38::34/64',
      # we need to mask the address using the prefix length so that they
      # are converted to '1.1.1.0/24' or '2000:123:38::/64'
      def self.process_network_mask(network)
        mask = network.split('/')[1]
        address = IPAddr.new(network).to_s
        network = address + '/' + mask unless mask.nil?
        network
      end

      # Convert boolean symbols to strings
      def self.bool_sym_to_s(val)
        return val unless val == :true || val == :false
        (val == :true)
      end

      # Special handling for boolean properties.
      # This helper method returns true if the property
      # flush contains a TrueClass or FalseClass value.
      def self.flush_boolean?(prop)
        prop.is_a?(TrueClass) || prop.is_a?(FalseClass)
      end

      # normalize_range_array
      #
      # Given a list of ranges, merge any overlapping ranges and normalize the
      # them as a string that can be used directly on the switch.
      #
      # Note: The ranges are converted to ruby ranges for easy merging,
      # then converted back to a cli-syntax ranges.
      #
      # Accepts an array or string:
      #   ["2-5", "9", "4-6"]  -or-  '2-5, 9, 4-6'  -or-  ["2-5, 9, 4-6"]
      # Returns a merged and ordered range:
      #   ["2-6", "9"]
      #
      def self.normalize_range_array(range, type=:array)
        return range if range.nil? || range.empty?

        # This step is puppet only
        return range if range[0] == :default

        # Handle string within an array: ["2-5, 9, 4-6"] to '2-5, 9, 4-6'
        range = range.shift if range.is_a?(Array) && range.length == 1

        # Handle string only: '2-5, 9, 4-6' to ["2-5", "9", "4-6"]
        range = range.split(',') if range.is_a?(String)

        # Convert to ruby-syntax ranges
        range = dash_range_to_ruby_range(range)

        # Sort & Merge
        merged = merge_range(range)

        # Convert back to cli dash-syntax
        ruby_range_to_dash_range(merged, type)
      end

      def self.normalize_range_string(range)
        range = range.to_s
        return normalize_range_array(range, :string) if range[/[-,]/]
        range
      end

      # Convert a cli-dash-syntax range to ruby-range. This is useful for
      # preparing inputs to merge_range().
      #
      # Inputs an array or string of dash-syntax ranges -> returns an array
      # of ruby ranges.
      #
      # Accepts an array or string: ["2-5", "9", "4-6"] or '2-5, 9, 4-6'
      # Returns an array of ranges: [2..5, 9..9, 4..6]
      #
      def self.dash_range_to_ruby_range(range)
        range = range.split(',') if range.is_a?(String)
        # [["45", "7-8"], ["46", "9,10"]]
        range.map! do |rng|
          if rng[/-/]
            # '2-5' -> 2..5
            rng.split('-').inject { |a, e| a.to_i..e.to_i }
          else
            # '9' -> 9..9
            rng.to_i..rng.to_i
          end
        end
        range
      end

      # Convert a ruby-range to cli-dash-syntax.
      #
      # Inputs an array of ruby ranges -> returns an array or string of
      # dash-syntax ranges.
      #
      # when (:array)  [2..6, 9..9]  ->  ['2-6', '9']
      #
      # when (:string)  [2..6, 9..9]  ->  '2-6, 9'
      #
      def self.ruby_range_to_dash_range(range, type=:array)
        range.map! do |r|
          if r.first == r.last
            # 9..9 -> '9'
            r.first.to_s
          else
            # 2..6 -> '2-6'
            r.first.to_s + '-' + r.last.to_s
          end
        end
        return range.join(',') if type == :string
        range
      end

      # Merge overlapping ranges.
      #
      # Inputs an array of ruby ranges:         [2..5, 9..9, 4..6]
      # Returns an array of merged ruby ranges: [2..6, 9..9]
      #
      def self.merge_range(range)
        # sort to lowest range 'first' values:
        #    [2..5, 9..9, 4..6]  ->  [2..5, 4..6, 9..9]
        range = range.sort_by(&:first)

        *merged = range.shift
        range.each do |r|
          lastr = merged[-1]
          if lastr.last >= r.first - 1
            merged[-1] = lastr.first..[r.last, lastr.last].max
          else
            merged.push(r)
          end
        end
        merged
      end # merge_range

      # TBD: Investigate replacing fail_array_overlap() and range_summarize()
      # with above methods.

      # Helper utility for checking if arrays are overlapping in a
      # give list.
      # For ex: if the list has '2-10,32,42,44-89' and '11-33'
      # then this will fail as they overlap
      def self.fail_array_overlap(list)
        array = []
        list.each do |range, _val|
          larray = range.split(',')
          larray.each do |elem|
            if elem.include?('-')
              elema = elem.split('-').map { |d| Integer(d) }
              ele = elema[0]..elema[1]
              if (array & ele.to_a).empty?
                array << ele.to_a
                array = array.flatten
              else
                fail 'overlapping arrays not allowed'
              end
            else
              elema = []
              elema << elem.to_i
              if (array & elema).empty?
                array << elema
                array = array.flatten
              else
                fail 'overlapping arrays not allowed'
              end
            end
          end
        end
      end

      # Helper utility method for range summarization of VLAN and BD ranges
      # Input is a range string. For example: '10-20, 30, 14, 100-105, 21'
      # Output should be: '10-21,30,100-105'
      def self.range_summarize(range_str, sort=true)
        ranges = []
        range_str.split(/,/).each do |elem|
          if elem =~ /\d+\s*\-\s*\d+/
            range_limits = elem.split(/\-/).map { |d| Integer(d) }
            ranges << (range_limits[0]..range_limits[1])
          else
            ranges << Integer(elem)
          end
        end
        # nrange array below will expand the ranges and get a single list
        nrange = []
        ranges.each do |item|
          # OR operations below will get rid of duplicates
          if item.class == Range
            nrange |= item.to_a
          else
            nrange |= [item]
          end
        end
        nrange.sort! if sort
        ranges = []
        left = nrange.first
        right = nil
        nrange.each do |obj|
          if right && obj != right.succ
            # obj cannot be included in the current range, end this range
            if left != right
              ranges << Range.new(left, right)
            else
              ranges << left
            end
            left = obj # start of new range
          end
          right = obj # move right to point to obj
        end
        if left != right
          ranges << Range.new(left, right)
        else
          ranges << left
        end
        ranges.join(',').gsub('..', '-')
      end

      # fretta check
      def self.check_slot_pid(inv)
        inv.each do |_x, slot|
          return true if slot['pid'][/-R/]
        end
        false
      end

      def self.product_tag
        data = Facter.value('cisco')
        case data['inventory']['chassis']['pid']
        when /N3/
          tag = check_slot_pid(data['inventory']) ? 'n3k-f' : 'n3k'
        when /N5/
          tag = 'n5k'
        when /N6/
          tag = 'n6k'
        when /N7/
          tag = 'n7k'
        when /N9/
          tag = check_slot_pid(data['inventory']) ? 'n9k-f' : 'n9k'
        else
          fail "Unrecognized product_id: #{data['inventory']['chassis']['pid']}"
        end
        tag
      end

      # Convert encryption type to symbol
      def self.enc_type_to_sym(type)
        case type
        when TACACS_SERVER_ENC_UNKNOWN
          :none
        when TACACS_SERVER_ENC_NONE
          :clear
        when TACACS_SERVER_ENC_CISCO_TYPE_7
          :encrypted
        end
      end

      # Convert encryption symbol to type
      def self.enc_sym_to_type(sym)
        case sym
        when :none
          TACACS_SERVER_ENC_UNKNOWN
        when :clear, :default
          TACACS_SERVER_ENC_NONE
        when :encrypted
          TACACS_SERVER_ENC_CISCO_TYPE_7
        end
      end

      # Convert return values to their specified ruby type
      #
      # Accepts the Resource API context and array of return values
      #
      # Returns the array of return values with individual values
      # correctly converted to their ruby type eg. Integer
      def self.enforce_simple_types(context, return_value)
        return_value.each do |individual_value_hash|
          individual_value_hash.each do |k, v|
            type_to_use = context.type.definition[:attributes][k][:type]
            if type_to_use.downcase =~ %r{^integer} || type_to_use.downcase =~ %r{^optional\[integer}
              individual_value_hash[k] = v.to_i
            end
            if type_to_use.downcase =~ %r{^string} || type_to_use.downcase =~ %r{^optional\[string}
              individual_value_hash[k] = v.to_s
            end
            next unless type_to_use.downcase =~ %r{^boolean} || type_to_use.downcase =~ %r{^optional\[boolean}
            individual_value_hash[k] = if v.to_s.casecmp('true').zero?
                                         true
                                       else
                                         false
                                       end
          end
        end
        return_value
      end
    end # class Utils
    # rubocop:enable Metrics/ClassLength

    # PuppetX::Cisco::BgpUtil - Common BGP methods used by BGP Types/Providers
    class BgpUtils
      def self.process_asnum(asnum)
        err_msg = "BGP asnum must be either a 'String' or an" \
                  " 'Integer' object"
        fail ArgumentError, err_msg unless asnum.is_a?(Integer) ||
                                           asnum.is_a?(String)
        if asnum.is_a? String
          # Match ASDOT '1.5' or ASPLAIN '55' strings
          fail ArgumentError unless /^(\d+|\d+\.\d+)$/.match(asnum)
          asnum = dot_to_big(asnum) if /\d+\.\d+/.match(asnum)
        end
        asnum.to_i
      end

      # Convert BGP ASN ASDOT+ to ASPLAIN
      def self.dot_to_big(dot_str)
        fail ArgumentError unless dot_str.is_a? String
        return dot_str unless /\d+\.\d+/.match(dot_str)
        mask = 0b1111111111111111
        high = dot_str.to_i
        low = 0
        low_match = dot_str.match(/\.(\d+)/)
        low = low_match[1].to_i if low_match
        high_bits = (mask & high) << 16
        low_bits = mask & low
        high_bits + low_bits
      end
    end
  end
end
