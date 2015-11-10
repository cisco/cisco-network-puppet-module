################################################################################
# Puppet Agent Bootstrap Utility
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
#
# Script Name:
#   install_puppet.rb.
#
# Purpose:
#   This script is called by the Beaker framework to install the puppet agent
#   on each agent node defined in the host configuration file.
#
# Usage:
#   beaker --host [host.cfg path] --pre-suite [install_puppet.rb path]
#     --no-validate --no-config
#
# Arguments:
#   --host        Path to the host configuration file
#   --pre-suite   Path to this install_puppet.rb agent bootstrap script
#   --no-validate Skip agent node package check
#   --no-config   Skip post-provisioning configuration to test nodes
#
# Sample host configuration file:
#  HOSTS:
#      agent-node1:
#          roles:
#              - agent
#          platform: cisco-7-x86_64
#          ip: agent-node1.domain.com
#          vrf: management
#          ssh:
#            auth_methods: ["password"]
#            password: example
#
#      agent-node2:
#          roles:
#              - agent
#          platform: cisco-7-x86_64
#          ip: agent-node2.domain.com
#          vrf: blue
#          target: guestshell
#          ssh:
#            auth_methods: ["password"]
#            user: devops
#            password: example
#
#      puppetmaster:
#          roles:
#              - master
#          platform: ubuntu-1404-x86_64
#          ip: puppetmaster.domain.com
#          ssh:
#            auth_methods: ["password"]
#            # *Must* be set to root for master
#            user: root
#            password: example
#
#  CONFIG:
#      puppet_config_template: /usr/config/puppet.conf
#      package_url: ftp://server.domain.com/
#      package_name: puppet-enterprise-3.7.1.rc2.6.g6cdc186-1.pe.nxos.x86_64.rpm
#      http_proxy: http://proxy.server.domain.com:8080
#      https_proxy: https://proxy.server.domain.com:8080
#      resolver: /usr/config/resolver_config
#
# Host Configuration File Usage:
#   HOSTS Section:
#     roles:          Choice of agent or master
#     platform:       <osfamily>-<version>-<architecture>
#     ip:             Fully qualified domain name of the node
#     vrf:            *Optional* vrf name for agent management interface
#     target:         *Optional* If set to 'guestshell' installs into the
#                      secure guestshell environment, else native shell
#     ssh:
#       auth_methods: *Optional* SSH authentication method.
#                       Set to 'password' for username/password authentication
#       username:     *Optional* SSH username if auth_methods is password
#                       NOTE: Puppet master user must be root
#       password:     *Optional* SSH password if auth_methods is password
#
#   CONFIG Section:
#     puppet_config_template: Local path to template puppet.conf file
#                             Template is customized with the agent certname:
#                             and master server: fields
#     package_url:            Base url for puppet rpm
#     package_name:           Name of puppet agent RPM package
#     rpm_gpg_key:            Local path to puppet rpm gpg key
#     http_proxy:             HTTP proxy URL
#     https_proxy:            HTTPS proxy URL
#     resolver:               Local path to file that will be used to overwrite
#                             /etc/resolv.conf on target agent
#
# Assumptions:
#   - Master node has been configured to auto accept/sign SSL certificates
#   - Only one master node per host configuration file
#   - Passwordless ssh must be configured if not using ssh_username/password
#
################################################################################

USAGE = <<ENDUSAGE

** WARNING ** This script is not a standalone script and can only be executed
              using the puppetlabs beaker tool!
Usage:
   beaker --host [HOST_CONFIG_FILE] --pre-suite [#{$PROGRAM_NAME} PATH]
     --no-validate --no-config

   --host         Path to host configuration file.
   --pre-suite    Path to #{$PROGRAM_NAME} script
   --no-validate  Do not perform beaker agent node package check
   --no-config    Do not perform beaker post-provisioning configuration

ENDUSAGE

if ARGV.empty?
  puts USAGE
  exit
end

GSUTILITY = '/isan/bin/guestshell'
TMP_PUPPET_LOCATION = '/bootflash/tmp_puppet'
PUPPET_PATH = '/opt/puppetlabs/puppet'

# -------------------------#
# Bootstrap Helper Methods #
# -------------------------#

# Generate commands to prepend to native or
# guestshell targets
#
# @param host [String]
# @return [String] Network namespace command
# @example on agent, "#{pp(agent)} puppet agent -t"
def pp(host)
  case host['platform']
  when /cisco/
    if host['vrf'].nil?
      command = 'sudo'
    else
      if target_guestshell?(host)
        command = "sudo chvrf #{host['vrf']}"
      else
        command = "sudo ip netns exec #{host['vrf']}"
      end
    end
    command.prepend "sudo #{GSUTILITY} " if target_guestshell?(host)
    command.prepend "http_proxy=#{options['http_proxy']} " if
                     options['http_proxy']
    command.prepend "https_proxy=#{options['https_proxy']} " if
                     options['https_proxy']
    command.prepend "PATH=$PATH:#{PUPPET_PATH}/bin/:#{PUPPET_PATH}/lib/ " unless
                     target_guestshell?(host)
  when /other_platform/
    command = 'do something different'
  else
    command = ''
  end
  command
end

# Get location of puppet.conf file
#
# @param agent [String]
# @return [String] Path to puppet.conf file
def get_puppet_config(agent)
  cl = "#{pp(agent)} puppet agent --configprint config"
  (on agent, cl, pty: true).stdout.chomp
end

# Determine if this is a native or guestshell install
#
# @param agent [String]
# @return [Boolean] true if guestshell, else false
def target_guestshell?(agent)
  agent['target'] == 'guestshell' ? true : false
end

# Check for user template in host configuration file
#
# @return [Boolean] true if it exists, else false
def user_template_exists?
  !options['puppet_config_template'].nil? &&
    File.exist?(options['puppet_config_template'])
end

# Check for resolver in host configuration file
#
# @return [Boolean] true if it exists, else false
def resolver_exists?
  !options['resolver'].nil? &&
    File.exist?(options['resolver'])
end

# Check for agent puppet.conf file existence
#
# @param agent [String]
# @return [Boolean] true if it exists, else false
def agent_template_exists?(agent)
  if target_guestshell?(agent)
    opts = { acceptable_exit_codes: [0, 2], pty: true }
  else
    opts = { acceptable_exit_codes: [0, 2] }
  end
  result = on agent, "#{pp(agent)} ls #{get_puppet_config(agent)}", opts
  result.exit_code == 0
end

# Get puppet.conf file template from file referenced in the
# host configuration file
#
# @return [String] Data containing puppet.conf information
def template_config
  File.read(options['puppet_config_template'])
end

# Get default puppet.conf file from puppet.conf file after
# the agent is installed.
#
# @param agent [String]
# @return [String] Data containing puppet.conf information
def get_agent_config(agent)
  target_guestshell?(agent) ? opts = { pty: true } : opts = {}
  config = on(agent,
              "#{pp(agent)} cat #{get_puppet_config(agent)}", opts).stdout
  config
end

# Check 'package_url' and 'package_name' params in the
# host configuration file
#
# @return [Hash] puppet.conf data.
def check_pkg_info
  return false if options['package_url'].nil? ||
                  options['package_name'].nil?
  true
end

# Get default puppet.conf file from puppet.conf file after
# the agent is installed.
#
# @param config [String] puppet.conf data
# @return [Hash] Data containing puppet.conf information
#
# Example of hash structure created by this method.
# {
#   "main" => {
#     "vardir" => "/var/opt/lib/pe-puppet",
#     "logdir" => "/var/log/pe-puppet",
#     "rundir" => "/var/run/pe-puppet",
#     "basemodulepath" => "/etc/puppetlabs/puppet/modules",
#     "user" => "pe-puppet",
#     "group" => "pe-puppet",
#     "archive_files" => "true",
#   },
#   "agent" => {
#     "report" => "true",
#     "classfile" => "$vardir/classes.txt",
#     "localconfig" => "$vardir/localconfig",
#     "graph" => "true",
#     "pluginsync" => "true",
#     "environment" => "production"
#   }
# }
def puppet_config_tohash(config)
  config_hash = Hash['main' => {}, 'agent' => {}]
  context = ''
  config_array = config.split("\n")
  config_array.each do |line|
    context = 'main' if /\[main\]/.match(line)
    context = 'agent' if /\[agent\]/.match(line)
    match = /^\s*(\w+)\s*=\s*(\S+)/.match(line)
    # Match all lines in main and agent sections except comment lines.
    config_hash[context][match[1]] = match[2] unless match.nil?
  end
  config_hash
end

# Build puppet.conf with user defined template or default
# puppet.conf file from agent node with custom 'certname'
# and 'server' parameters for each agent node.
#
# @param agent [String]
# @return [String] Data containing custom per node puppet.conf
def build_puppet_config(agent)
  error_string = %(
    INSTALL PUPPET: Unable to retrieve puppet.conf
    template from #{options['hosts_file']} or agent #{agent}
  )

  if user_template_exists?
    puppet_config = puppet_config_tohash(template_config)
  elsif agent_template_exists?(agent)
    puppet_config = puppet_config_tohash(get_agent_config(agent))
  else
    fail error_string
  end

  # Add certname and server values to main section
  puppet_config['main']['certname'] = agent['ip']
  puppet_config['main']['server'] = master['ip']

  puppet_config
end

# Handle install of puppet rpm to native or guestshell
#
# @param agent [String]
def install_target(agent, package)
  opts = { pty: true, prepend_cmds: pp(agent) }
  opts = { acceptable_exit_codes: [0, 1] }.merge(opts)
  agent.install_package(package, '', nil, opts)
  if agent.check_for_package('puppet-agent', opts)
    agent.upgrade_package('puppet', '', opts)
  else
    agent.install_package('puppet', '', nil, opts)
  end
  # Make sure install/upgrade succeeded
  agent.check_for_package('puppet-agent', pty:                   true,
                                          prepend_cmds:          pp(agent),
                                          acceptable_exit_codes: [0])
end

# Configure puppet.conf file
#
# @param agent [String]
def configure_puppet_nexus(agent, opts={})
  # Create temporary storage location for puppet.conf
  # file under /bootflash.  Bootflash is mounted into
  # the guestshell.
  tmp_puppet_file = "#{TMP_PUPPET_LOCATION}/puppet.conf"
  on agent, "rmdir #{TMP_PUPPET_LOCATION}",
     acceptable_exit_codes: [0, 1]
  on agent, "mkdir #{TMP_PUPPET_LOCATION}",
     acceptable_exit_codes: [0, 1]

  # Determine location of puppet.conf
  puppet_conf = get_puppet_config(agent)

  # Build puppet.conf file within the temporary directory and then
  # move it to the correct /etc location
  conf_data = ''
  opts.each do |section, options|
    conf_data << "[#{section}]\n"
    options.each do |option, value|
      conf_data << "#{option}=#{value}\n"
    end
    conf_data << "\n"
  end
  on agent, "echo \"#{conf_data}\" > #{tmp_puppet_file}"
  on agent, "#{pp(agent)} mv #{tmp_puppet_file} #{puppet_conf}",
     pty: true
  on agent, "rmdir #{TMP_PUPPET_LOCATION}",
     acceptable_exit_codes: [0, 1]
end

# Copy local resolve.conf file to target agent
#
# @param agent [String]
def copy_resolve_conf(agent)
  resolve_path = '/etc/resolv.conf'
  on agent, "#{pp(agent)} rm -rf #{resolve_path}",
     acceptable_exit_codes: [0, 1], pty: true
  tmp_puppet_file = "#{TMP_PUPPET_LOCATION}/resolve.conf"
  on agent, "rmdir #{TMP_PUPPET_LOCATION}",
     acceptable_exit_codes: [0, 1]
  on agent, "mkdir #{TMP_PUPPET_LOCATION}",
     acceptable_exit_codes: [0, 1]
  scp_to agent, options['resolver'], "#{tmp_puppet_file}"
  on agent, "#{pp(agent)} mv #{tmp_puppet_file} #{resolve_path}",
     pty: true
  on agent, "rmdir #{TMP_PUPPET_LOCATION}",
     acceptable_exit_codes: [0, 1]
end

def setup_env(agent)
  pupurl = 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs'
  gpgdir = '/etc/pki/rpm-gpg'
  codes  = { acceptable_exit_codes: [0, 1], pty: true }

  on agent, "#{pp(agent)} mkdir -p #{gpgdir}", codes
  if options['rpm_gpg_key'].nil?
    on agent, "#{pp(agent)} rpm --import #{pupurl}", codes
    on agent, "#{pp(agent)} wget #{pupurl} -P #{gpgdir}", codes
  else
    gpg_key_name = File.basename(options['rpm_gpg_key'])
    on agent, "rm -rf #{TMP_PUPPET_LOCATION}", codes
    on agent, "mkdir #{TMP_PUPPET_LOCATION}", codes
    scp_to agent, options['rpm_gpg_key'], TMP_PUPPET_LOCATION
    on agent, "#{pp(agent)} rpm --import #{TMP_PUPPET_LOCATION}/#{gpg_key_name}", codes
    on agent, "#{pp(agent)} cp #{TMP_PUPPET_LOCATION}/#{gpg_key_name} #{gpgdir}", codes
    on agent, "rm -rf #{TMP_PUPPET_LOCATION}", codes
  end
  on agent, "#{pp(agent)} ln -sf #{PUPPET_PATH}/bin/puppet /usr/bin/puppet", codes
end

#---------------------------------------------------------------------#
# Loop through each agent defined in the host configuration file
# and perform the following:
#
# 1) Install puppet agent defined by
#    package_url + package_name yaml param.
# 2) Configure puppet.conf file on agent
#      If defined, use 'puppet_config_file' host.cfg yaml parameter.
#      Else, build puppet.conf dynamically.
# 3) Start the puppet agent.
#---------------------------------------------------------------------#

package_error = %(
  INSTALL PUPPET: 'package_url:' and/or 'package_name:' parameters are
  not specfied in #{options['hosts_file']}
)
# Make sure package information is set in the host configuration file
unless check_pkg_info
  logger.warn package_error
  exit
end

# Puppet rpm package.
package = options['package_url'] + options['package_name']

# Keep track of failure information
$failures = 0
$failure_messages = []
$exceptions = []
$start_failures = 0

agents.each do |agent|
  begin
    test_name "Bootstrap puppet agent #{agent}"

    # Optional: Copy local resolve.conf to agent.
    copy_resolve_conf(agent) if resolver_exists?

    # Setup symlinks to puppet binary and copy gpg keys if needed
    setup_env(agent)

    # Install RPM to native shell or guestshell
    logger.notify "Installing puppet on agent: #{agent}"
    install_target(agent, package)

    # Configure puppet
    logger.notify "Configure puppet on agent: #{agent}"
    configure_puppet_nexus(agent, build_puppet_config(agent))

    # Clean agent certificats on master and agent
    if options['cert_clean']
      on master, "#{PUPPET_PATH}/bin/puppet cert clean #{agent['ip']}",
         accept_all_exit_codes: true, pty: true
      ssl_dir = (on agent, "#{pp(agent)} puppet agent --configprint ssldir",
                    accept_all_exit_codes: true, pty: true).stdout.chomp
      on agent, "#{pp(agent)} find #{ssl_dir} -name #{agent['ip']}.pem -delete",
         accept_all_exit_codes: true, pty: true
    end

    # Start puppet agent
    logger.notify "Kick start puppet on agent: #{agent}"
    result = on agent, "#{pp(agent)} puppet agent -t",
                accept_all_exit_codes: true, pty: true
    if result.exit_code != 0
      logger.warn "AGENT: #{agent} did not start properly. Check logs for details"
      $start_failures += 1
    end

  rescue StandardError => e
    $failure_messages[$failures] = "BOOTSTRAP OF AGENT #{agent} FAILED"
    $exceptions[$failures] = "AGENT: #{agent} Exception \n #{e.message}"
    $failures += 1
    next
  end
end

def report_results
  total_passed = agents.size - $failures
  total_failed = $failures
  total_agents = agents.size

  report = %(
  PUPPET AGENT BOOTSTRAP RESULTS:
  +---------------------------------------------------------+
    TOTAL NUMBER OF AGENTS PROCESSED : #{total_agents}
    TOTAL SUCCESSFUL AGENT INSTALLS  : #{total_passed}
    TOTAL FAILED AGENT INSTALLS      : #{total_failed}
  +---------------------------------------------------------+
  )

  install_report = %{
  WARNING:
    Attempt to start the puppet agent using 'puppet agent -t'
    resulted in a non-zero exit code on (#{$start_failures}) agents.

    Check logs above for details
  }

  logger.notify report
  logger.notify install_report if $start_failures > 0

  $failure_messages.each do |note|
    logger.warn "#{note}"
  end

  $exceptions.each do |exception|
    logger.debug "#{exception}"
  end

  return unless options['log_level'] == 'info'
  logger.info "Rerun with '--log-level trace' for additional debug info"
end

report_results
assert_equal(0, $failures,
             "** Failed to bootstrap (#{$failures}) of (#{agents.size}) agents **")
