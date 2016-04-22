#
# Copyright (c) 2016 Cisco and/or its affiliates.
#
# April 2016, Chris Van Heuveln
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
#########################################################################
#
# Please note: This resource is a helper utility for test purposes only.
#
#########################################################################

begin
  require 'puppet_x/cisco/cmnutils'
rescue LoadError # seen on master, not on agent
  # See longstanding Puppet issues #4248, #7316, #14073, #14149, etc. Ugh.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                     'puppet_x', 'cisco', 'cmnutils.rb'))
end

Puppet::Type.newtype(:cisco_interface_capabilities) do
  @doc = 'Interface capabilities utility. This is a test-only resource.'

  newparam(:name, namevar: :true) do
    munge(&:downcase)
  end

  newproperty(:capabilities) do
    desc 'This is a getter-only property used by the test facility to '\
         'determine interface capabilities.'
  end
end
