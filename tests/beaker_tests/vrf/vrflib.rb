###############################################################################
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

# Require UtilityLib.rb path.
require File.expand_path("../../lib/utilitylib.rb", __FILE__)

module VrfLib

  # Method to create a manifest for VRF resource attribute with only
  # 'ensure' is set 
  # @param name [string] Vrf name to be created 
  # @param present [boolean] the value for ensure attribute
  # @result none [None] Returns no object.
  def VrfLib.create_vrf_manifest_default(name, present=true)
    ensure_str = present ? 'present' : 'absent'
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node default {
      cisco_vrf { '#{name}':
        ensure  => #{ensure_str},
      }
    }
    EOF"
    return manifest_str
  end

  # Method to create a manifest for VRF resource attributes:
  # ensure, description and shutdown
  # @param name [String] Name of the vrf. 
  # @param description [String] String for the description attribute
  # @param shutdown [Boolean] Boolean for the shutdown attribute
  # @result none [None] Returns no object.
  def VrfLib.create_vrf_manifest_nondefaults(name, description, shutdown)
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node default {
      cisco_vrf { '#{name}': 
        ensure       => present,
        description  => '#{description}',
        shutdown     => #{shutdown},
      }
    }
    EOF"
    return manifest_str
  end
  
  # Method to test removal of description
  # @param name [String] Name of the vrf
  # @result none [None] Returns no object
  def VrfLib.update_vrf_manifest_no_description(name)
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node default {
      cisco_vrf { '#{name}':
        ensure                    => present,
        description               => ' ',
      }
    }
    EOF"
    return manifest_str
  end

  # Method to create a manifest for VRF resource attribute 'name' to verify
  # the title pattern can be overridden by name attribute.
  # @param name [String] Name of the vrf. 
  # @param description [String] String for the description attribute
  # @param shutdown [Boolean] Boolean for the shutdown attribute
  # @result none [None] Returns no object.
  def VrfLib.update_vrf_manifest_by_name_attribute(name, description, shutdown)
    manifest_str = "cat <<EOF >#{UtilityLib::PUPPETMASTER_MANIFESTPATH}
    node default {
      cisco_vrf { 'any_#{name}':
        ensure                   => present,
        name                     => '#{name}',
        description              => '#{description}',
        shutdown                 => #{shutdown},
      }
    }
    EOF"
    return manifest_str
  end

end

