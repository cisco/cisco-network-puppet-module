#
# Puppet provider for feature X__RESOURCE_NAME__X
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

require 'cisco_node_utils' if Puppet.features.cisco_node_utils?

Puppet::Type.type(:cisco_X__RESOURCE_NAME__X).provide(:nxapi) do
  confine feature: :cisco_node_utils

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.instances
    inst = []
    return inst unless Cisco::X__CLASS_NAME__X.feature_enabled
    current_state = { name: 'default', ensure: :present }
    inst << new(current_state)
    inst
  end

  def self.prefetch(resources)
    provider = instances
    resources.values.first.provider = provider.first unless provider.first.nil?
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    case @property_flush[:ensure]
    when :present
      Cisco::X__CLASS_NAME__X.new.feature_enable
    when :absent
      Cisco::X__CLASS_NAME__X.new.feature_disable
    end
  end
end
