# Manages VDC configuration.
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

begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end

Puppet::Type.newtype(:cisco_vdc) do
  @doc = "Manages VDC configuration.

  ~~~puppet
  cisco_vdc { '<title>':
    ..attributes..
  }
  ~~~

  `<title>` is the title of the vdc resource.

  Example:

  ~~~puppet
    cisco_vdc { 'default':
      ensure                        => present,
      limit_resource_module_type    => 'm1 m1xl',
    }
  ~~~

  "

  ###################
  # Resource Naming #
  ###################
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []
    patterns << [
      /^(\S+)/,
      [
        [:name, identity]
      ],
    ]
    patterns
  end

  ##############
  # Parameters #
  ##############

  ensurable

  newparam(:name, namevar: true) do
    desc "The name of the VDC. Valid values are String or keyword 'default'"
  end

  ##############
  # Properties #
  ##############

  newproperty(:limit_resource_module_type) do
    desc 'Restrict VDC to specific module-types. Valid values are a String '\
         "containing a list of module-types ('m1 m1xl'), or keyword 'default'"

    munge do |value|
      value = value.to_sym if value == 'default'
      value
    end
  end
end
