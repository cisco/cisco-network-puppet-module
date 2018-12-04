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

# Basic implementation for the radius type using the Resource API.
class Puppet::Provider::Radius::CiscoNexus
  # radius does nothing on NX-OS as no option
  # to enable the feature from this level
  def set(context, _changes)
    context.notice("No operations for managing 'radius', use 'radius_global'")
  end

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
end
