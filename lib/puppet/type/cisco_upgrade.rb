#
# Manages the version of Cisco Image running on a device.
#
# June 2018
#
# Copyright (c) 2017-2018 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_upgrade) do
  @doc = "Manages the version of Cisco Image running on a device.

  ```
  cisco_upgrade {\"<instance_name>\":
    ..attributes..
  }
  ```

  There can only be one instance of cisco_upgrade i.e. 'image'

  Example:
  ```
    cisco_upgrade {'image' :
      package           => 'bootflash:///nxos.7.0.3.I5.1.bin',
      force_upgrade     => false,
      delete_boot_image => false,
    }
  ```
  "

  apply_to_all

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    patterns << [
      /^(\S+)$/,
      [
        [:name, identity]
      ],
    ]
    patterns
  end

  newparam(:name, namevar: :true) do
    # Parameter used only to satisfy namevar
    desc 'Name of cisco_upgrade instance. Valid values are string'
    validate do |name|
      warning "only 'image' is accepted as a valid name" if name != 'image'
    end
  end

  newparam(:force_upgrade) do
    desc 'Force upgrade the device.'
    defaultto :false
    newvalues(:true, :false)
  end # param force_upgrade

  newparam(:delete_boot_image) do
    desc 'Delete the booted image(s).'
    defaultto :false
    newvalues(:true, :false)
  end # param delete_boot_image

  ##############
  # Attributes #
  ##############

  # Deprecated
  newproperty(:version) do
    desc 'Version of the Cisco image to install on the device.
          Valid values are strings'
    validate do |ver|
      valid_chars = 'Version can only have the following
          characters: 0-9, a-z, A-Z, (, ) and .'
      fail "Invalid version string. #{valid_chars}" unless
        (/([0-9a-zA-Z().]*)/.match(ver))[0] == ver
    end
  end # property version

  newproperty(:package) do
    examples = "\nExample:\nbootflash:nxos.7.0.3.I5.2.bin\n
      tftp://x.x.x.x/path/to/nxos.7.0.3.I5.2.bin\n
      usb1:nxos.7.0.3.I5.2.bin"
    supported = "\nNOTE: Only bootflash:,tftp: and usb are supported."
    desc "{ackage to install on the device. Format <uri>:<image>.
          Valid values are string.#{examples}#{supported}"
    validate do |pkg|
      fail 'Package should be a string.' unless pkg.is_a?(String)
      fail 'package must match format <uri>:<image>' unless pkg[/\S+:\S+/]
    end
  end # property package

  validate do
    fail "The property 'version' has been deprecated. Please use 'package'." if
      self[:version] && self[:package].nil?
  end
end
