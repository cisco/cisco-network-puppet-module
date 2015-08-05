# Manifest to demo cisco patch rpm 
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

# To apply this demo_cisco_patch_rpm manifest first you must setup your own
# local repository and replace the '<>' markers with local repo information.

class ciscopuppet::demo_cisco_patch_rpm {

  $repo = '<http://example_repo.domain.com/repo>'
  #Install a Patch file
  $target = { 'target' => 'host' }
  package { "${repo}/<n9000_sample-1.0.0-7.0.3.x86_64.rpm>":
    ensure           => present,
    provider         => 'nxapi',
    source           => $::repo,
    package_settings => $::target,
  }
}
