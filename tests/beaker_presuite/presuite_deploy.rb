###############################################################################
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
###############################################################################
# This presuite takes several optional parameters through environment variables
# to support different test scenarios for master/agent interactions. For agentless
# testing, the usual .fixtures.yml and Gemfile control the versions used.
#
#   * NETDEV_STDLIB_URL, NETDEV_STDLIB_REF: the source git URL and git ref (branch)
#     to load the netdev_stdlib module; if no NETDEV_STDLIB_URL is specified, the
#     last released version from the module forge is used
#   * MODULE_URL, MODULE_REF: the source git URL and git ref (branch)
#     to load the cisco-network-puppet-module module; if no MODULE_URL is specified, the
#     local checkout is used
#   * RSAPI_URL, RSAPI_REF: the source git URL and git ref (branch)
#     to load the puppetlabs-resource_api module; if no RSAPI_URL is specified, the
#     last released version from the module forge is used
#   * NODE_GEM_URL, NODE_GEM_REF: the source git URL and git ref (branch)
#     to load the cisco_node_utils gem; if no NODE_GEM_URL is specified, the
#     last released gem version
#   * RSAPI_GEM_URL, RSAPI_GEM_REF: the source git URL and git ref (branch)
#     to load the puppet-resource_api gem; if no RSAPI_GEM_URL is specified, the
#     last released gem version.
#
# If a URL, but no REF is specified, the `master` branch will be used.
#

require 'beaker-pe'
require 'shellwords'

test_name 'Prep Masters & Install Puppet' do
  # collect host objects from the nodeset. code further down needs to be prepared that one of those lists is empty
  # in regular testing at puppet there is either a master and an agent for agentful testing, or a default node for agentless testing
  # Get all hosts with role master or compile_master
  masters = select_hosts(roles: ['master', 'compile_master'])
  # Get all hosts with role agent
  agents = select_hosts(roles: ['agent'])
  # Get all hosts with role proxy_agent
  proxy_agents = select_hosts(roles: ['proxy_agent'])

  def beaker_config_connection_address
    if default[:ip]
      default[:ip]
    elsif default[:vmhostname]
      default[:vmhostname]
    elsif default[:hostname]
      default[:hostname]
    else
      logger.error("stdout:\n--\nip, vmhostname or hostname not found, check beaker hosts configuration\n--")
      nil
    end
  end

  unless ENV['BEAKER_provision'] == 'no' || masters.empty?
    step 'install PE on masters' do
      masters.each do |node|
        if node.options['provision']
          install_pe_on(masters, {})
        end
      end
    end
  end

  def mod_line_from_env(module_name, env_prefix=nil)
    if env_prefix && ENV["#{env_prefix}_URL"]
      "mod '#{module_name}', git: '#{ENV["#{env_prefix}_URL"]}', ref: '#{ENV["#{env_prefix}_REF"] || 'master'}'"
    else
      "mod '#{module_name}'"
    end
  end

  unless masters.empty?
    step 'install Cisco Module on master' do
      masters.each do |node|
        # Clear out the Puppetfile as we may be reusing a master
        on(node, '> /root/Puppetfile')
        on(node, "echo #{Shellwords.escape(mod_line_from_env('puppetlabs-resource_api', 'RSAPI'))} >> /root/Puppetfile")
        on(node, "echo #{Shellwords.escape(mod_line_from_env('puppetlabs-puppetserver_gem', 'RSAPI'))} >> /root/Puppetfile")
        on(node, "echo #{Shellwords.escape(mod_line_from_env('puppetlabs-netdev_stdlib', 'NETDEV_STDLIB'))} >> /root/Puppetfile")
        on(node, "echo #{Shellwords.escape(mod_line_from_env('puppetlabs-ciscopuppet', 'MODULE'))} >> /root/Puppetfile")
        if proxy_agents
          on(node, "echo #{Shellwords.escape(mod_line_from_env('puppetlabs-device_manager', 'DEVICE_MANAGER'))} >> /root/Puppetfile")
          on(node, "echo #{Shellwords.escape(mod_line_from_env('puppetlabs-concat', 'CONCAT'))} >> /root/Puppetfile")
          on(node, "echo #{Shellwords.escape(mod_line_from_env('puppetlabs-hocon', 'HOCON'))} >> /root/Puppetfile")
          on(node, "echo #{Shellwords.escape(mod_line_from_env('puppetlabs-stdlib', 'STDLIB'))} >> /root/Puppetfile")
          # whitelist device for autosigning
          on(node, "echo #{beaker_config_connection_address} >> /etc/puppetlabs/puppet/autosign.conf")
        end
        on(node, '/opt/puppetlabs/puppet/bin/r10k puppetfile install /root/Puppetfile -v --moduledir /etc/puppetlabs/code/environments/production/modules', acceptable_exit_codes: [0])
        on(node, puppet('plugin', 'download'), acceptable_exit_codes: [0, 1])
      end
    end
  end

  def clone_and_build_gem(gem_name, env_prefix=nil)
    # nothing to do when no URL set
    return unless env_prefix && ENV["#{env_prefix}_URL"]

    `git clone #{ENV["#{env_prefix}_URL"]} #{gem_name}`
    Dir.chdir(gem_name) do
      `git checkout #{ENV["#{env_prefix}_REF"] || 'master'}`
      `gem build #{gem_name}.gemspec`
    end
  end

  if ENV['RSAPI_GEM_URL']
    step 'Build Resource API gem' do
      clone_and_build_gem('puppet-resource_api', 'RSAPI_GEM')
    end
  end

  if ENV['NODE_GEM_URL']
    step 'Build Cisco Node Utils gem' do
      clone_and_build_gem('cisco_node_utils', 'NODE_GEM')
    end
  end

  def upload_gem_to(node, target_path, gem_name, env_prefix=nil)
    # nothing to upload if gem should be installed from rubygems
    return unless env_prefix && ENV["#{env_prefix}_URL"]

    gem_path = Dir.glob("#{gem_name}/*.gem")[0]
    gem_file = "#{gem_name}.gem"
    scp_to node, gem_path, "#{target_path}/#{gem_file}"
  end

  def install_server_gem(node, gem_name, env_prefix=nil)
    upload_gem_to(node, '/tmp', gem_name, env_prefix)
    gem_location = if env_prefix && ENV["#{env_prefix}_URL"]
                     "/tmp/#{gem_name}.gem"
                   else
                     gem_name
                   end
    on(node, "/opt/puppetlabs/bin/puppetserver gem install #{gem_location}")
  end

  unless masters.empty?
    step 'install Resource API on masters' do
      masters.each do |node|
        install_server_gem(node, 'puppet-resource_api', 'RSAPI_GEM')
        on(node, '/usr/bin/systemctl restart pe-puppetserver.service', acceptable_exit_codes: [0])
      end
    end
  end

  def install_agent_gem(node, gem_name, env_prefix=nil)
    upload_gem_to(node, '/var/volatile/tmp', gem_name, env_prefix)
    gem_location = if env_prefix && ENV["#{env_prefix}_URL"]
                     "/var/volatile/tmp/#{gem_name}.gem"
                   else
                     gem_name
                   end
    on(node, "/opt/puppetlabs/puppet/bin/gem install #{gem_location}")
  end

  unless ENV['BEAKER_provision'] == 'no' || agents.empty?
    step 'Install agent on switches, sign certificates' do
      opts = {
        puppet_collection:    'PC1',
        puppet_agent_sha:     ENV['SHA'],
        puppet_agent_version: ENV['SUITE_VERSION'] || ENV['SHA']
      }
      agents.each do |switch|
        next unless switch['platform'] =~ /cisco_/
        on(switch, 'yum -y erase puppet-agent', acceptable_exit_codes: [0, 1])
        on(switch, 'rpm -qa | grep -i puppetlabs | xargs rpm -e', acceptable_exit_codes: [0, 123])
        on(switch, 'rm -rf /var/cache/yum/puppetlabs-pc1/packages/puppet*', acceptable_exit_codes: [0, 1])
        on(switch, 'rm -rf /var/cache/yum/pl-puppet-agent*', acceptable_exit_codes: [0, 1])
        on(switch, 'rm -rf /etc/yum/repos.d/pl-puppet-agent*', acceptable_exit_codes: [0, 1])
        on(switch, 'rm -rf /var/volatile/log/puppet*', acceptable_exit_codes: [0, 1])
        on(switch, 'find /var/volatile/tmp -type f -delete')
        install_puppet_agent_dev_repo_on(switch, opts)
        install_agent_gem(switch, 'puppet-resource_api', 'RSAPI_GEM')
        install_agent_gem(switch, 'cisco_node_utils', 'NODE_GEM')
        on(switch, 'find /etc/puppetlabs/puppet/ssl/ -type f -print0 |xargs -0r sudo rm')
        on(switch, 'rm /etc/puppetlabs/puppet/puppet.conf')
        on(switch, 'touch /etc/puppetlabs/puppet/puppet.conf')
        on(switch, 'chmod a+w /etc/puppetlabs/puppet/puppet.conf')
        on(switch, "/opt/puppetlabs/bin/puppet config set server #{master.hostname}")
        on(switch, "/opt/puppetlabs/bin/puppet config set certname #{switch}")
        unless masters.empty?
          # Purge existing node in case we are reusing a master
          on(master, puppet('node', 'purge', switch.to_s), acceptable_exit_codes: [0, 1])
        end
        on(switch, '/opt/puppetlabs/bin/puppet agent -t', acceptable_exit_codes: [1])
        unless masters.empty?
          # Puppet server changed the CA command starting in 2019.0.0
          version = on(master, '/opt/puppetlabs/bin/puppetserver --version', acceptable_exit_codes: [0])
          major = /(\d{4})/.match(version.output)
          if major && major[0].to_i <= 2018
            on(master, puppet('cert', 'sign', switch.to_s), acceptable_exit_codes: [0, 1])
          elsif major
            # Modify CA checking so we can use 5.x agents against 6.x masters - PUP-9291
            scp_from master, '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem', '.'
            scp_to switch, 'ca_crt.pem', '/etc/puppetlabs/puppet/ssl/certs/ca.pem'
            on(switch, '/opt/puppetlabs/bin/puppet config set --section main certificate_revocation false')
            on(master, "/opt/puppetlabs/bin/puppetserver ca sign --certname #{switch}", acceptable_exit_codes: [0, 1])
          else
            # We didn't find the major version, fallback to legacy command
            on(master, puppet('cert', 'sign', switch.to_s), acceptable_exit_codes: [0, 1])
          end
        end
        on(switch, '/opt/puppetlabs/bin/puppet agent -t --waitforcert 60', acceptable_exit_codes: [0, 2])
      end
    end
  end

  def configure_device_config(proxy_agent)
    "cat <<EOF >'/etc/puppetlabs/code/environments/production/manifests/site.pp'
      \nnode '#{proxy_agent.hostname}' {
        device_manager { '#{beaker_config_connection_address}':
          type => 'cisco_nexus',
          credentials => {
            address => '#{beaker_config_connection_address}',
            username => #{default[:ssh][:user] || 'admin'},
            port => #{default[:ssh][:port] || 80},
            password => #{default[:ssh][:password] || 'admin'},
          },
        }\n
        }\nnode '#{beaker_config_connection_address}' {
        \n}
    \nEOF"
  end

  unless ENV['BEAKER_provision'] == 'no' || proxy_agents.empty?
    step 'Install Puppet agent on proxy agents, sign certificates' do
      opts = {
        puppet_collection:    ENV['BEAKER_PUPPET_COLLECTION'] || 'puppet5',
        puppet_agent_sha:     ENV['SHA'] || '5.5.10',
        puppet_agent_version: ENV['SUITE_VERSION'] || '5.5.10'
      }
      proxy_agents.each do |proxy_agent|
        next if proxy_agent['platform'] =~ /cisco_/
        on(proxy_agent, 'yum -y erase puppet-agent', acceptable_exit_codes: [0, 1])
        on(proxy_agent, 'rpm -qa | grep -i puppetlabs | xargs rpm -e', acceptable_exit_codes: [0, 123])
        on(proxy_agent, 'rm -rf /var/cache/yum/puppetlabs-pc1/packages/puppet*', acceptable_exit_codes: [0, 1])
        on(proxy_agent, 'rm -rf /var/cache/yum/pl-puppet-agent*', acceptable_exit_codes: [0, 1])
        on(proxy_agent, 'rm -rf /etc/yum/repos.d/pl-puppet-agent*', acceptable_exit_codes: [0, 1])
        on(proxy_agent, 'rm -rf /var/volatile/log/puppet*', acceptable_exit_codes: [0, 1])
        install_puppet_agent_on(proxy_agent, opts)
        on(proxy_agent, '/opt/puppetlabs/puppet/bin/gem install puppet-resource_api')
        on(proxy_agent, '/opt/puppetlabs/puppet/bin/gem install cisco_node_utils')
        on(proxy_agent, 'find /etc/puppetlabs/puppet/ssl/ -type f -print0 |xargs -0r sudo rm')
        on(proxy_agent, 'rm /etc/puppetlabs/puppet/puppet.conf')
        on(proxy_agent, 'touch /etc/puppetlabs/puppet/puppet.conf')
        on(proxy_agent, 'chmod a+w /etc/puppetlabs/puppet/puppet.conf')
        on(proxy_agent, "/opt/puppetlabs/bin/puppet config set server #{master.hostname}")
        on(proxy_agent, "/opt/puppetlabs/bin/puppet config set certname #{proxy_agent}")
        unless masters.empty?
          # Purge existing node in case we are reusing a master
          on(master, puppet('node', 'purge', proxy_agent.to_s), acceptable_exit_codes: [0, 1])
          # set up device config
          on(master, configure_device_config(proxy_agent), acceptable_exit_codes: [0, 1])
        end
        on(proxy_agent, '/opt/puppetlabs/bin/puppet agent -t', acceptable_exit_codes: [1])
        unless masters.empty?
          # Puppet server changed the CA command starting in 2019.0.0
          version = on(master, '/opt/puppetlabs/bin/puppetserver --version', acceptable_exit_codes: [0])
          major = /(\d{4})/.match(version.output)
          if major && major[0].to_i <= 2018
            on(master, puppet('cert', 'sign', proxy_agent.to_s), acceptable_exit_codes: [0, 1])
          elsif major
            # Modify CA checking so we can use 5.x agents against 6.x masters - PUP-9291
            scp_from master, '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem', '.'
            scp_to proxy_agent, 'ca_crt.pem', '/etc/puppetlabs/puppet/ssl/certs/ca.pem'
            on(proxy_agent, '/opt/puppetlabs/bin/puppet config set --section main certificate_revocation false')
            on(master, "/opt/puppetlabs/bin/puppetserver ca sign --certname #{proxy_agent}", acceptable_exit_codes: [0, 1])
          else
            # We didn't find the major version, fallback to legacy command
            on(master, puppet('cert', 'sign', proxy_agent.to_s), acceptable_exit_codes: [0, 1])
          end
        end
        on(proxy_agent, '/opt/puppetlabs/bin/puppet agent -t --waitforcert 60', acceptable_exit_codes: [0, 2])
        on(proxy_agent, '/opt/puppetlabs/bin/puppet device --debug --verbose', acceptable_exit_codes: [0, 1, 2])
      end
    end
  end
end
