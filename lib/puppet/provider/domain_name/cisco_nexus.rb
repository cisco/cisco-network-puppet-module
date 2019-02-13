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

# Implementation for the domain_name type using the Resource API.
class Puppet::Provider::DomainName::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, domains=nil)
    require 'cisco_node_utils'
    current_state = []
    @domains = Cisco::DomainName.domainnames
    if domains.nil? || domains.empty?
      @domains.each_key do |id|
        current_state << get_current_state(id)
      end
    else
      domains.each do |domain|
        next if @domains[domain].nil?
        current_state << get_current_state(domain)
      end
    end
    current_state
  end

  def get_current_state(name)
    {
      name:   name,
      ensure: 'present',
    }
  end

  def create(_context, name, _should)
    Cisco::DomainName.new(name)
  end

  def delete(_context, name)
    @domains = Cisco::DomainName.domainnames
    @domains[name].destroy
  end
end
