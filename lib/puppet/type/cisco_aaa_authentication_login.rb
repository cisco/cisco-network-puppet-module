# Manages configuration for an SNMP server.
#
# November 2015
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

Puppet::Type.newtype(:cisco_aaa_authentication_login) do
  @doc = "Manages AAA Authentication Login configuration.

~~~puppet
  cisco_aaa_authentication_login {\"default\":
    ..attributes..
  }
~~~

  There can only be one instance of the cisco_aaa_authentication_login.

  Example:
~~~puppet
    cisco_aaa_authentication_login {\"default\":
      ascii_authentication   => true,
      chap                   => false,
      error_display          => true,
      mschap                 => false,
      mschapv2               => false,
    }
~~~"

  ###################
  # Resource Naming #
  ###################

  # Parse out the title to fill in the attributes in these patterns. These
  # attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    # Below pattern matches both parts of the full composite name.
    patterns << [
      /^(\S+)$/,
      [
        [:name, identity]
      ],
    ]
    patterns
  end

  ##############
  # Attributes #
  ##############

  newparam(:name, namevar: :true) do
    # Note, this parameter is only created to satisfy the namevar
    # since none of the aaa_authentication_login attributes are good candidates.
    desc 'The name of the AAA Authentication Login instance. Must be "default".'
    validate do |name|
      error "only 'default' is accepted as a valid name" if name != 'default'
    end
  end # property name

  newproperty(:ascii_authentication) do
    desc 'Enable/disable ascii_authentication for AAA Authentication Login.' \
         "Valid values are true, false, keyword 'default'"

    newvalues(:true, :false, :default)
  end

  newproperty(:chap) do
    desc 'Enable/disable chap for AAA Authentication Login.'

    newvalues(:true, :false, :default)
  end

  newproperty(:error_display) do
    desc 'Enable/disable error_display for AAA Authentication Login.'

    newvalues(:true, :false, :default)
  end

  newproperty(:mschap) do
    desc 'Enable/disable mschap for AAA Authentication Login.'

    newvalues(:true, :false, :default)
  end

  newproperty(:mschapv2) do
    desc 'Enable/disable mschapv2 for AAA Authentication Login.'

    newvalues(:true, :false, :default)
  end

  # validate only one authentication method is configured before munging
  validate do
    props = [:ascii_authentication, :chap, :mschap, :mschapv2]

    auth_methods_intended = props.select { |prop| self[prop] == :true }
    fail 'Only one authentication login method can be configured at a time' if
      auth_methods_intended.size > 1

    # if user configures an auth method, make sure all other methods are off so
    # that configuration succeeds
    if auth_methods_intended.size == 1
      props.delete(auth_methods_intended.first) # remove from tmp array
      props.each { |prop| self[prop] = :false } # ensure others are disabled
    end
  end
end
