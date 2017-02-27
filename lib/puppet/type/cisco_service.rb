#
# Manages the version of Cisco Image running on a device.
#
# Copyright (c) 2016-2017 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_service) do
  @doc = "Manages the version of Cisco Image running on a device.

  ```
  cisco_service {\"<version>\":
    ..attributes..
  }
  ```

  <version> is the version of the Cisco image.

  Example:
  ```
    cisco_service {'7.0(3)I5(1)' :
      source_uri        => 'bootflash:///nxos.7.0.3.I5.1.bin',
      force_all         => false,
      delete_boot_image => false,
    }
  ```
  "

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    patterns << [
      /^(\S+)$/,
      [
        [:version, identity]
      ],
    ]
    patterns
  end

  # Overwrites name method.
  def name
    "#{self[:version]}"
  end

  newparam(:name) do
    desc 'Name of cisco_service, not used, but needed for puppet'
  end

  newparam(:version, namevar: :true) do
    desc 'Name of the version of image. Valid values are string.'
  end # param version

  newparam(:force_all) do
    desc 'Force upgrade the device.'
    defaultto :false
    newvalues(:true, :false)
  end # param force_all

  newparam(:delete_boot) do
    desc 'Delete the booted image(s).'
    defaultto :false
    newvalues(:true, :false)
  end # param delete_boot

  ##############
  # Attributes #
  ##############

  newproperty(:source_uri) do
    desc 'URI to the image to install on the device. Format <media>:<image>.
          Valid values are string.'
  end # property source_uri

  def check_version
    # validate that the version string is not empty or nil
    # and that only the version string consists of only a
    # few permitted characters
    fail ArgumentError,
         "The version shouldn't be nil or an empty string" if
         self[:version] == '' || self[:version].nil? == :true
    fail ArgumentError,
         'Invalid version string. Version can only have the following
          characters: 0-9, a-z, A-Z, (, ) and .' unless
         (/([0-9a-zA-Z().]*)/.match(self[:version]))[0] == self[:version]
  end

  def check_source_uri
    # validate that the source_uri property is specified as
    # <media>:<filename>
    image = self[:source_uri].split(':')
    fail ArgumentError,
         'source_uri should be of the format <media>:<filename>' if
      image[0] == image[-1]
  end

  # Validation block
  validate do
    fail ArgumentError,
         'source_uri is required' if self[:source_uri].nil?
    check_version
    check_source_uri
  end
end
