# Copyright (c) 2018 Cisco and/or its affiliates.
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
require 'puppet/resource_api/simple_provider'

# Basic implementation for the radius type using the Resource API.
class Puppet::Provider::Radius::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  # NOTE that we just return default name
  def get(_context, _names=nil)
    radius = []
    radius << {
      name: 'default'
    }
    radius
  end

  # Does not create / update / delete
  def create(context, name, should)
    context.notice("No operation in creating '#{name}' with #{should.inspect}")
  end

  def update(context, name, should)
    context.notice("No operation in updating '#{name}' with #{should.inspect}")
  end

  def delete(context, name)
    context.notice("No operation in deleting '#{name}'")
  end
end
