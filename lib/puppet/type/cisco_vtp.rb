# Manages the VTP configuration of a Cisco Device.
#
# January 2014
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_vtp) do
  @doc = "Manages the VTP (VLAN Trunking Protocol) configuration of a Cisco device.

  cisco_vtp { <title>:
    ..attributes..
  }

  There can only be one instance of the cisco_vtp.
  Example:
    cisco_vtp { default:
      ensure   => present,
      domain   => 'mydomain',
      password => 'xxxxx',
      version  => 2,
      filename => 'bootflash:/vlan.dat',
    }
  "

  newparam(:name, namevar: :true) do
    desc "Instance of vtp, only allow the value 'default'"
    validate do |name|
      if name != 'default'
        error "only 'default' is accepted as a valid vtp resource name"
      end
    end
  end

  ##############
  # Attributes #
  ##############

  ensurable

  newproperty(:domain) do
    desc 'VTP administrative domain. Valid values are string. Mandatory parameter.'

    validate do |domain_name|
      fail 'Domain name is not a string.' unless domain_name.is_a? String
    end
  end # property domain

  newproperty(:version) do
    desc "Version for the VTP domain. Valid values are integer, keyword 'default'."

    munge do |version|
      begin
        version = :default if version == 'default'
        version = Integer(version) unless version == :default
      rescue
        raise "Version #{version} is not a number."
      end # rescue
      version
    end
  end # property version

  newproperty(:filename) do
    desc "VTP file name. Valid values are string, keyword 'default'."

    munge do |file_name|
      file_name = :default if file_name == 'default'
      fail 'File name is not a string.' unless
        file_name == :default || file_name.is_a?(String)
      file_name
    end
  end # property filename

  newproperty(:password) do
    desc "Password for the VTP domain. Valid values are string, keyword 'default'."

    munge do |password|
      password = :default if password == 'default'
      fail 'Password is not a string.' unless
        password == :default || password.is_a?(String)
      password
    end
  end # property password
end # type
