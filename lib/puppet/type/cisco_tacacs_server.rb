##############################################
# Manages configuration for an TACACS server.
#
# March 2014
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
##############################################
Puppet::Type.newtype(:cisco_tacacs_server) do
  @doc = "Manages a Cisco TACACS+ Server global configuration.

  cisco_tacacs_server {\"<name>\":
    ..attributes..
  }

  The <name> is the name of the tacacs server instance.

  There can only be one instance of the cisco_tacacs_server.

  Example:
    cisco_tacacs_server {\"default\":
      ensure              => present,
      timeout             => 10,
      directed_request    => true,
      deadtime            => 20,
      encryption_type     => clear,
      encryption_password => 'test123',
      source_interface    => 'Ethernet1/2',
    }"

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

  ensurable

  newparam(:name, namevar: :true) do
    # Note, this parameter is only created to satisfy the namevar
    # since none of the tacacs_server attributes are good candidates.
    desc "Instance of the tacacs_server, only allow the value 'default'"
    validate do |name|
      if name != 'default'
        error "only 'default' is accepted as a valid tacacs_server resource name"
      end
    end
  end # property name

  # timeout
  newproperty(:timeout) do
    desc "Global timeout interval for TACACS+ servers.  Valid values are
          Integer, in seconds, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'timeout must be an integer.'
      end
      value
    end
  end

  # directed_request
  newproperty(:directed_request) do
    desc "Allows users to specify a TACACS+ server to send the
          authentication request when logging in."

    newvalues(:true, :false)
  end

  # deadtime
  newproperty(:deadtime) do
    desc "Specifies the global deadtime interval for TACACS+
          servers. Valid values are Integer, in minutes, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'deadtime must be an integer.'
      end
      value
    end
  end

  # encryption type
  newparam(:encryption_type) do
    desc 'Specifies the global preshared key type for TACACS+ servers.'

    munge do |value|
      value = :default if value == 'default'
      value.to_sym
    end

    newvalues(:clear,
              :encrypted,
              :none,
              :default)
  end

  # encryption password
  newproperty(:encryption_password) do
    desc "Specifies the global TACACS+ servers preshared key
          password. Valid values are string, keyword 'default'."
  end

  # source interface
  newproperty(:source_interface) do
    desc "Global source interface for all TACACS+ server groups
          configured on the device. Valid values are string, keyword 'default'."

    munge do |value|
      value = :default if value == 'default'
      value
    end
    validate do |source_interface|
      fail("source_interface - #{source_interface} must be a string") unless source_interface == :default || source_interface.kind_of?(String)
    end
  end

  # validation for encryption_type and encryption_password combination
  validate do
    if self[:encryption_password].nil? && !self[:encryption_type].nil? &&
       self[:encryption_type] != :none
      fail("The encryption_password must be present in the manifest if encryption_type is present and not 'none'.")
    end
  end
end # Puppet::Type.newtype
