# Class to install Cisco gems 
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

class ciscopuppet::install (String $repo = 'https://rubygems.org', String $proxy = '') {

  # Process proxy settings 
  if $proxy == '' {
    $opts = {}
  }
  else {
    $opts = { '--http-proxy' => $proxy }
  }

  package { 'cisco_node_utils' :
    ensure          => present,
    provider        => 'gem',
    source          => $repo,
    install_options => $opts,
  }
}
