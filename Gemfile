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

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place, fake_version=nil)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { git: Regexp.last_match(1), branch: Regexp.last_match(2), require: false }].compact
  elsif place =~ %r{^file://(.*)}
    ['>= 0', { path: File.expand_path(Regexp.last_match(1)), require: false }]
  else
    [place, { require: false }]
  end
end

beaker_version = ENV['BEAKER_VERSION']
beaker_rspec_version = ENV['BEAKER_RSPEC_VERSION']
group :system_tests do
  if beaker_version
    gem 'beaker', *location_for(beaker_version)
  else
    gem 'beaker', '~> 2.38', '>= 2.38.1', require: false
  end
  if beaker_rspec_version
    gem 'beaker-rspec', *location_for(beaker_rspec_version)
  else
    gem 'beaker-rspec', require: false
  end
  gem 'serverspec', require: false
end

facterversion = ENV['GEM_FACTER_VERSION'] || ENV['FACTER_GEM_VERSION']
if facterversion
  gem 'facter', *location_for(facterversion)
else
  gem 'facter', require: false
end

puppetversion = ENV['GEM_PUPPET_VERSION'] || ENV['PUPPET_GEM_VERSION']
if puppetversion
  gem 'puppet', *location_for(puppetversion)
else
  gem 'puppet', '~> 4.0', require: false
end

group :development, :unit_tests do
  gem 'cisco_node_utils', '~> 1.0', require: false
  gem 'rake', '~> 10.1.0',       require: false
  gem 'rspec', '~> 3.1.0',       require: false
  gem 'rspec-puppet',            require: false
  gem 'mocha',                   require: false
  gem 'puppetlabs_spec_helper',  require: false
  gem 'puppet-lint',             require: false
  gem 'pry',                     require: false
  gem 'rubocop', '= 0.35.1',     require: false
  gem 'simplecov',               require: false
end

# vim:ft=ruby
