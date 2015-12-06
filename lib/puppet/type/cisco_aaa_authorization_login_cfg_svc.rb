# Manages configuration for Aaa Authorization Login Config Service.
#
# December 2015
#
# Copyright (c) 2013-2015 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_aaa_authorization_login_cfg_svc) do
  @doc = "Manages configuration for Authorization Login Config Service.

~~~puppet
  cisco_aaa_authorization_login_cfg_svc {\"[console|default]\":
    ..attributes..
  }
~~~

  'console' and 'default' are the only services configurable.

  Example:
~~~puppet
    cisco_aaa_authorization_login_cfg_svc {\"console\":
      ensure    => present,
      groups    => ['group1', 'group2'],
      method    => \"local\",
    }
~~~"

  ensurable

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these patterns.
  # These attributes can be overwritten later.
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

  newparam(:name, namevar: true) do
    desc 'Name of the config login service. Valid values are "console" or "default".'

    validate do |value|
      fail unless value == 'default' || value == 'console'
    end
  end

  ##############
  # Attributes #
  ##############

  newproperty(:groups, array_matching: :all) do
    desc "Tacacs+ groups configured for this service. Valid values are
          an array of strings, keyword 'default'."

    validate do |value|
      fail "group #{value} must be a String" unless
        value.kind_of?(String) || value == :default
    end

    munge do |value|
      value = :default if value == 'default'
      value
    end

    def insync?(is)
      (is.size == should.size && is.sort == should.sort)
    end
  end

  newproperty(:method) do
    desc "Authentication methods on this device. Valid values are 'local',
      'unselected', 'default'."

    newvalues(:local, :unselected, :default)
  end

  ################
  # Autorequires #
  ################

  # Autorequire all cisco_aaa_group_tacacs associated with this service
  autorequire(:cisco_aaa_group_tacacs) do |rel_catalog|
    groups = []
    if self[:groups]
      self[:groups].each do |group|
        groups << rel_catalog.catalog.resource('Cisco_aaa_group_tacacs',
                                               "#{group}")
      end
    end
    groups
  end
end
