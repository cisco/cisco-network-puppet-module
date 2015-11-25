# Manages a Cisco Tacacs Server Host.
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

Puppet::Type.newtype(:cisco_tacacs_server_host) do
  @doc = "Configures Cisco TACACS+ server hosts.

  cisco_tacacs_server_host {\"<host>\":
    ..attributes..
  }

  <host> is the name of the tacacs server host.

  Example:
    cisco_tacacs_server_host {\"accounting\" :
      ensure              => present,
      port                => 50,
      timeout             => 10,
      encryption_type     => 'encrypted',
      encryption_password => 'xxxxx',
    }"

  ensurable

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
        [:host, identity]
      ],
    ]
    patterns
  end

  # Overwrites name method. Original method simply returns self[:name],
  # which is no longer valid or complete.
  # Would not have failed, but just return nothing useful.
  def name
    "#{self[:host]}"
  end

  # host
  newparam(:host, namevar: true) do
    desc 'Name of the tacacs_server_host instance. Valid values are string.'
  end

  #############################
  # Configuration Attributes #
  ############################

  # port
  newproperty(:port) do
    desc "Server port for the host. Valid values are Integer, keyword 'default'."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'The port must be a valid integer.'
      end
      value
    end
  end

  # timeout
  newproperty(:timeout) do
    desc "Timeout interval for the host. Valid values are Integer, in
          seconds."

    munge do |value|
      begin
        value = :default if value == 'default'
        value = Integer(value) unless value == :default
      rescue
        raise 'The timeout must be a valid integer.'
      end
      value
    end
  end

  # encryption_type
  newparam(:encryption_type) do
    desc "Specifies a preshared key for the host. keyword 'default'."

    munge do |value|
      begin
        value = case value
                when 'clear' then 0
                when 'encrypted' then 7
                when 'none' then 8
                when 'default' then :default

                else
                  fail "valid encryption types are 'none', 'clear',\
                       'encrypted', or 'default'"
                end
      end
      value
    end
    newvalues(:clear, :encrypted, :none, :default)
  end

  # encryption_password
  newproperty(:encryption_password) do
    desc "Specifies the preshared key password for the host. Valid
          values are string."
  end

  # validation for encryption_type and encryption_password combination
  validate do
    if self[:encryption_password].nil? &&
       !self[:encryption_type].nil? && self[:encryption_type] != 8
      fail("The encryption_password must be present in the manifest if encryption_type is present and not 'none'.")
    end
  end
end
