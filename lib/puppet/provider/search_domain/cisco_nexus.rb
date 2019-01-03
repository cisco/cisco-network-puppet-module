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

# Implementation for the search_domain type using the Resource API.
class Puppet::Provider::SearchDomain::CiscoNexus < Puppet::ResourceApi::SimpleProvider
  def canonicalize(_context, resources)
    resources
  end

  def get(_context, domains=nil)
    require 'cisco_node_utils'
    current_states = []
    if domains.nil? || domains.empty?
      @domainnames = Cisco::DomainName.domainnames
      @domainnames.each do |name, instance|
        current_states << get_current_state(name, instance)
      end
    else
      domains.each do |domain|
        @domainnames = Cisco::DomainName.domainnames
        domainname = @domainnames[domain]
        next if domainname.nil?
        current_states << get_current_state(domain, domainname)
      end
    end
    current_states
  end

  def get_current_state(name, _instance)
    {
      name:   name,
      ensure: 'present',
    }
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    Cisco::DomainName.new(name)
  end

  def delete(context, name)
    context.notice("Destroying '#{name}'")
    @domainnames = Cisco::DomainName.domainnames
    @domainnames[name].destroy
  end
end
