#!/isan/bin/python
#md5sum=ec7497f2087cd87b8bccb06eb1ae61f8
# The line above is the embedded md5sum of this file taken without this line.
# The md5sum is an added level of script integrity verification beyond the
# basic tftp ip checksum. The script will also perform an integrity check
# on the image and configuration files by downloading corresponding files
# with .md5 extensions. The md5sum value can be generated for this file by
# issuing the following command:
#  f=puppet_agent_install.py ; cat $f | sed '/^#md5sum/d' > $f.md5 ; sed -i "s/^#md5sum=.*/#md5sum=$(md5sum $f.md5 | sed 's/ .*//')/" $f
#

import os
from datetime import datetime
import subprocess
import shlex
import sys

###############################################################################
# START OF USER-CONFIGURABLE PARAMETERS
# These user-configurable parameters should be updated to reflect the local
# automation environment.
###############################################################################

# (Required) RPM_NAME = The puppet agent release RPM
# **************************************************************
# *** IMPORTANT: CHOOSE THE RIGHT RPM FOR YOUR ENVIRONMENT! ****
# **************************************************************
bash_shell_rpm = 'puppetlabs-release-pc1-cisco-wrlinux-5.noarch.rpm'
guestshell_rpm = 'puppetlabs-release-pc1-el-7.noarch.rpm'
RPM_NAME = bash_shell_rpm


# (Required) RPM_URI = The download URI for the RPM
# RPM_URI = 'ftp://1.2.3.4/'
RPM_URI = 'http://yum.puppetlabs.com/'

# (required) PUPPET_SERVER = The DNS name or IP address of the agent's puppet server
PUPPET_SERVER = 'my_puppet.my_company.com'

# (Optional) VRF = The agent's VRF to use for the RPM install
VRF = 'management'

# (Optional) HTTP_PROXY = local http proxy server
# (Optional) HTTPS_PROXY = local https proxy server
# (Optional) NO_PROXY = proxy exclusions
#HTTP_PROXY = 'http://proxy.my_company.com:8080'
#HTTPS_PROXY = 'https://proxy.my_company.com:8080'
#NO_PROXY = ''

# (optional) DOMAIN = The domain name to use with the agent node
#DOMAIN = 'my_company.com'

# (Optional) DNS = The DNS configuration to use for /etc/resolv.conf
# Use triple-quote syntax for multiple lines:
#DNS = '''\n
#nameserver 1.2.3.4
#domain my_company.com
#search my_company.com
#'''

###############################################################################
# End OF USER-CONFIGURABLE PARAMETERS
# Do not modify the following section.
###############################################################################

# Script initializations. Note: os.environ vars always win over script vars
PUPPET_BINARY = '/opt/puppetlabs/puppet/bin/puppet'
PUPPET_CONFIGPRINT = 'sudo ' + PUPPET_BINARY + ' agent --configprint config'

# Check for required vars
reqd_vars = ['RPM_NAME', 'RPM_URI', 'PUPPET_SERVER']
for v in reqd_vars:
    if not (v in globals() and len(v)):
        raise ValueError("Required parameter '%s' is not set" % v)

# Build PREPEND_CMD to specify both sudo and optional vrf (namespace)
PREPEND_CMD = 'sudo'
if os.environ.get('VRF'):
    PREPEND_CMD += ' ip netns exec ' + os.environ['VRF']
elif 'VRF' in globals() and len(VRF):
    PREPEND_CMD += ' ip netns exec ' + VRF

# Optional DNS
if os.environ.get('DNS'):
    DNS = os.environ['DNS']
elif 'DNS' not in globals():
    DNS = ''

DNS = DNS.strip()
# Optional DOMAIN
if os.environ.get('DOMAIN'):
    DOMAIN = os.environ['DOMAIN']
elif 'DOMAIN' not in globals():
    DOMAIN = ''

DOMAIN = DOMAIN.strip()

# Optionally set os.environ proxies
proxies = ['HTTP_PROXY', 'HTTPS_PROXY', 'NO_PROXY']
for p in proxies:
    if not os.environ.get(p):
        if p in globals() and len(p):
            os.environ[p] = globals()[p]

# Create a logfile
log_prefix = datetime.now().strftime('/bootflash/puppet_agent_install.%Y%m%d-%H%M%S')
log_handle = open('%s.log' % log_prefix, "w+")

# Temporary wget html (deleted by script)
wget_html = '%s.wget' % log_prefix

###############################################################################
# METHODS
###############################################################################

def log_it(text):
    print text
    log_handle.write('\n' + text)
    log_handle.flush()
    sys.stdout.flush()

def log_it_step(text):
    text = '\n--------\n [STEP] %s' % text
    print text
    log_handle.write('\n' + text)
    log_handle.flush()
    sys.stdout.flush()

def log_globals():
    """Log all global variables"""

    all_vars = 'PUPPET_BINARY PUPPET_CONFIGPRINT RPM_NAME RPM_URI \
                PUPPET_SERVER PREPEND_CMD DNS VRF DOMAIN \
                HTTP_PROXY HTTPS_PROXY NO_PROXY'
    buf = ''
    for v in all_vars.split():
        buf += '\n%20s = %s' % (v, globals().get(v))
    log_it('--------\nGlobal Variables:\n' + buf)

def process_cmd(cmd):
    """Process native bash or guestshell command"""

    log_it('\ncommand> ' + cmd)
    args = shlex.split(cmd)
    p = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output,error = p.communicate()
    log_it('\n stdout> ' + output)
    if error:
        log_it('\n stderr> ' + error)
    if p.returncode == 0:
        return output.rstrip()
    else:
        return "FAIL: {0}{1}".format(output, error)

def configure_nameserver():
    """Create /etc/resolv.conf in the agent environment"""

    if not DNS:
        return
    resolv = '/etc/resolv.conf'
    log_it_step('Create config for %s' % resolv)
    process_cmd('sudo rm -f ' + resolv)
    log_it('\ncommand> (Write config to %s)' % resolv)
    with open(resolv, 'w') as f:
        f.write(DNS)
    process_cmd('sudo chmod 666 ' + resolv)

def verify_reachability():
    """Verify network reachability to puppet master and rpm repo """

    log_it_step('Verify reachability to puppet master')
    cmd = PREPEND_CMD + ' ping -c 5 ' + PUPPET_SERVER
    result = process_cmd(cmd)
    if result.find('FAIL') == 0:
        log_it('Failed to ping puppet master')
        exit(-1)

    log_it_step('Verify reachability to RPM repo (wget writes to stderr)')
    cmd = '%s wget %s -O %s' % (PREPEND_CMD, RPM_URI, wget_html)
    result = process_cmd(cmd)
    if result.find('FAIL') == 0:
        log_it("Failed to reach RPM repo")
        exit(-1)
    cmd = 'sudo rm %s' % wget_html
    result = process_cmd(cmd)

def install_puppet():
    """Install the puppet release rpm and agent rpm"""

    log_it_step('RPM Install Part 1. Install puppet release rpm + gpg keys')
    cmd = PREPEND_CMD + ' yum install -y ' + RPM_URI + RPM_NAME
    process_cmd(cmd)

    log_it_step('RPM Install Part 2. Install puppet agent rpm')
    cmd = PREPEND_CMD + ' yum install puppet -y '
    process_cmd(cmd)

def configure_puppet():
    """Configure puppet.conf"""

    log_it_step('Create config for puppet.conf')
    conf_file = process_cmd(PUPPET_CONFIGPRINT)
    process_cmd('sudo rm -f ' + conf_file)
    if DOMAIN:
        domain = '.' + DOMAIN
    conf = '''\n
[main]
certname = %s
server = %s\n''' % (process_cmd('hostname') + domain, PUPPET_SERVER)
    log_it('\ncommand> (Write config to %s)\n%s' % (conf_file, conf))

    with open(conf_file, 'w') as f:
        f.write(conf)
    process_cmd('sudo chmod 666 ' + conf_file)

def run_puppet_agent():
    """Kickstart the puppet agent"""

    log_it_step('Run puppet agent -t to generate ssl certificate')
    process_cmd('%s %s agent -t' % (PREPEND_CMD, PUPPET_BINARY))

# Main
log_it_step('Script Start')
log_globals()
configure_nameserver()
verify_reachability()
install_puppet()
configure_puppet()
run_puppet_agent()

log_it_step('Script Complete')
log_handle.close()
exit(0)
