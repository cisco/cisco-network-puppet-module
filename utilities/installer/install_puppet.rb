################################################################################
# Puppet Agent Bootstrap Utility
#
# Copyright (c) 2014-2016 Cisco and/or its affiliates.
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
#      nexus-native.domain.com:
#          roles:
#              - agent
#          platform: cisco_nexus-7-x86_64
#          ip: 10.0.0.100
#          vrf: management
#          ssh:
#            auth_methods: ["password"]
#            password: example
#
#      nexus-guestshell.domain.com:
#          roles:
#              - agent
#          platform: cisco_nexus-7-x86_64
#          ip: 10.0.0.101
#          vrf: blue
#          target: guestshell
#          ssh:
#            auth_methods: ["password"]
#            user: devops
#            password: example
#
#      xr-agent.domain.com:
#          roles:
#              - agent
#          platform: cisco_ios_xr-6-x86_64
#          ip: 10.0.0.102
#          ssh:
#            auth_methods: ["password"]
#            port: 57722
#            user: admin
#            password: adminpassword
#
#      puppetmaster.domain.com:
#          roles:
#              - master
#          platform: ubuntu-1404-x86_64
#          ip: 10.0.0.2
#          ssh:
#            auth_methods: ["password"]
#            # *Must* be set to root for master
#            user: root
#            password: example
#
#  CONFIG:
#      puppet_config_template: /usr/config/puppet.conf
#      http_proxy: http://proxy.server.domain.com:8080
#      https_proxy: https://proxy.server.domain.com:8080
#      resolver: /usr/config/resolver_config
#
# Host Configuration File Usage:
#   HOSTS Section:
#     roles:          Choice of agent or master
#     platform:       <osfamily>-<version>-<architecture>
#     ip:             IP address of host
#     vrf:            *Optional* vrf name for agent management interface
#     target:         *Optional* If set to 'guestshell' installs into the
#                      secure guestshell environment, else native shell
#     ssh:
#       auth_methods: *Optional* SSH authentication method.
#                       Set to 'password' for username/password authentication
#       username:     *Optional* SSH username if auth_methods is password
#                       NOTE: Puppet master user must be root
#       password:     *Optional* SSH password if auth_methods is password
#       port:         *Optional* SSH server port - defaults to 22
#
#   CONFIG Section:
#     puppet_config_template: Local path to template puppet.conf file
#                             Template is customized with the agent certname:
#                             and master server: fields
#     rpm_gpg_key:            Local path to puppet rpm gpg key
#     http_proxy:             HTTP proxy URL
#     https_proxy:            HTTPS proxy URL
#     resolver:               Local path to file that will be used to overwrite
#                             /etc/resolv.conf on target agent
#     cisco_node_utils:       Install and configure the gem by this name
#       gem:                  Gem file to install (else, use rubygems.org)
#       port:                 gRPC server listen port
#       username:             IOS XR admin username
#       password:             IOS XR admin password
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
PUPPET_PATH = '/opt/puppetlabs/puppet'

# -------------------------#
# Bootstrap Helper Methods #
# -------------------------#

# Temporary file storage location on the target
def tmp_location(host)
  case host['platform']
  when /cisco_nexus/
    '/bootflash/tmp_puppet'
  when /cisco_ios_xr/
    '/disk0:/tmp_puppet'
  end
end

def create_tmp_location(agent)
  on agent, "mkdir -p #{tmp_location(agent)}"
  on agent, "chmod a+rw #{tmp_location(agent)}"
end

def destroy_tmp_location(agent)
  on agent, "rm -rf #{tmp_location(agent)}"
end

$env = {}
$env['http_proxy'] = options['http_proxy'] if options['http_proxy']
$env['https_proxy'] = options['https_proxy'] if options['https_proxy']
$env['PATH'] = "$PATH:#{PUPPET_PATH}/bin/:#{PUPPET_PATH}/lib/"

# TODO: if installing to guestshell:
# command.prepend "#{GSUTILITY} sudo chvrf ${host['vrf']}"

# Get location of puppet.conf file
#
# @param agent [String]
# @return [String] Path to puppet.conf file
def get_puppet_config(agent)
  cl = 'puppet agent --configprint config'
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
  opts = { acceptable_exit_codes: [0, 2] }
  opts[:pty] = true if target_guestshell?(agent)
  result = on agent, "ls #{get_puppet_config(agent)}", opts
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
  on(agent, "cat #{get_puppet_config(agent)}", opts).stdout
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
  logger.debug("puppet_config_tohash -> #{config_hash}")
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
  puppet_config['main']['certname'] = agent.hostname
  puppet_config['main']['server'] = master.hostname
  logger.debug("build_puppet_config -> #{puppet_config}")
  puppet_config
end

# Configure puppet.conf file
#
# @param agent [String]
def configure_puppet_nexus(agent, opts={})
  # Create temporary storage location for puppet.conf
  # file under /bootflash.  Bootflash is mounted into
  # the guestshell.
  tmp_puppet_file = "#{tmp_location(agent)}/puppet.conf"
  create_tmp_location(agent)

  # Determine location of puppet.conf
  puppet_conf = get_puppet_config(agent)

  # Build puppet.conf file within the temporary directory and then
  # move it to the correct /etc location
  conf_data = ''
  opts.each do |section, options|
    conf_data << "[#{section}]\n"
    logger.debug("Options for section #{section}: #{options}")
    options.each do |option, value|
      conf_data << "#{option}=#{value}\n"
    end
    conf_data << "\n"
  end
  on agent, "echo \"#{conf_data}\" > #{tmp_puppet_file}"
  on agent, "mv #{tmp_puppet_file} #{puppet_conf}", pty: true
  destroy_tmp_location(agent)
end

# Copy local resolve.conf file to target agent
#
# @param agent [String]
def copy_resolve_conf(agent)
  logger.info 'Copying /etc/resolv.conf to node'
  resolve_path = '/etc/resolv.conf'
  on agent, "rm -rf #{resolve_path}", acceptable_exit_codes: [0, 1], pty: true
  tmp_puppet_file = "#{tmp_location(agent)}/resolve.conf"
  create_tmp_location(agent)
  scp_to agent, options['resolver'], "#{tmp_puppet_file}"
  on agent, "mv #{tmp_puppet_file} #{resolve_path}", pty: true
  destroy_tmp_location(agent)
end

def setup_env(agent)
  pupurl = 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs'
  gpgdir = '/etc/pki/rpm-gpg'
  codes  = { pty: true, environment: $env }

  on agent, "mkdir -p #{gpgdir}", codes
  if options['rpm_gpg_key'].nil?
    on agent, "rpm --import #{pupurl}", codes
    on agent, "wget #{pupurl} -P #{gpgdir}", codes
  else
    gpg_key_name = File.basename(options['rpm_gpg_key'])
    create_tmp_location(agent)
    scp_to agent, options['rpm_gpg_key'], tmp_location(agent)
    on agent, "rpm --import #{tmp_location(agent)}/#{gpg_key_name}", codes
    on agent, "cp #{tmp_location(agent)}/#{gpg_key_name} #{gpgdir}", codes
    destroy_tmp_location(agent)
  end
  on agent, "ln -sf #{PUPPET_PATH}/bin/puppet /usr/bin/puppet", codes
  # SSH environment directory may not exist by default for XR
  on agent, 'mkdir -p ~/.ssh', codes
  on agent, "chown #{agent['ssh']['user']} ~/.ssh", codes
end

# Install cisco_node_utils gem on target agent
def install_cisco_gem_on(agent)
  logger.notify "Installing cisco_node_utils gem on agent: #{agent}"
  opts = options['cisco_node_utils']
  opts = {} unless opts.is_a? Hash
  if opts['gem']
    create_tmp_location(agent)

    gem_file = "#{tmp_location(agent)}/#{File.basename(opts['gem'])}"
    scp_to agent, opts['gem'], gem_file
    on agent, "#{PUPPET_PATH}/bin/gem install --no-ri --no-rdoc #{gem_file}", environment: $env

    destroy_tmp_location(agent)
  else
    # install from rubygems.org
    on agent, "#{PUPPET_PATH}/bin/gem install --no-ri --no-rdoc cisco_node_utils", environment: $env
  end

  logger.notify "Configuring cisco_node_utils gem on agent: #{agent}"
  conf_data = 'default:'
  conf_data << "\n  username: #{opts['username']}" if opts['username']
  conf_data << "\n  password: #{opts['password']}" if opts['password']
  conf_data << "\n  port:     #{opts['port']}" if opts['port']
  config_file = '/etc/cisco_node_utils.yaml'
  on agent, "touch #{config_file}"
  on agent, "chmod a+rw #{config_file}"
  on agent, "echo \"#{conf_data}\" > #{config_file}"
  on agent, "chown root #{config_file}"
  on agent, "chmod 0600 #{config_file}"
end

#---------------------------------------------------------------------#
# Loop through each agent defined in the host configuration file
# and perform the following:
#
# 1) Install puppet agent
# 2) Configure puppet.conf file on agent
#      If defined, use 'puppet_config_file' host.cfg yaml parameter.
#      Else, build puppet.conf dynamically.
# 3) Start the puppet agent.
#---------------------------------------------------------------------#

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
    logger.notify "Set up environment on agent: #{agent}"
    setup_env(agent)

    # Install RPM to native shell or guestshell
    logger.notify "Installing puppet on agent: #{agent}"
    install_puppet_agent_on(agent)

    # Install cisco_node_utils gem
    install_cisco_gem_on(agent) if options.key?(:cisco_node_utils)

    # Configure puppet
    logger.notify "Configure puppet on agent: #{agent}"
    configure_puppet_nexus(agent, build_puppet_config(agent))

    # Clean agent certificats on master and agent
    if options['cert_clean']
      on master, "#{PUPPET_PATH}/bin/puppet cert clean #{agent.hostname}",
         accept_all_exit_codes: true, pty: true
      ssl_dir = (on agent, 'puppet agent --configprint ssldir',
                    accept_all_exit_codes: true, pty: true).stdout.chomp
      on agent, "find #{ssl_dir} -name #{agent.hostname}.pem -delete",
         accept_all_exit_codes: true, pty: true
    end

    # Start puppet agent
    logger.notify "Kick start puppet on agent: #{agent}"
    result = on agent, 'puppet agent -t',
                accept_all_exit_codes: true, pty: true
    if result.exit_code != 0 && result.exit_code != 2
      logger.warn "AGENT: #{agent} did not start properly. Check logs for details"
      $start_failures += 1
    end

  rescue StandardError => e
    $failure_messages[$failures] = "BOOTSTRAP OF AGENT #{agent} FAILED"
    $exceptions[$failures] = "AGENT: #{agent} Exception \n #{e.message}\n  #{e.backtrace.join("\n  ")}"
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
    logger.info "#{exception}"
  end

  return unless options['log_level'] == 'info'
  logger.info "Rerun with '--log-level trace' for additional debug info"
end

report_results
assert_equal(0, $failures,
             "** Failed to bootstrap (#{$failures}) of (#{agents.size}) agents **")
