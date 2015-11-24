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
import time
import subprocess
import shlex
import sys

###############################################################################
# START OF USER-CONFIGURABLE PARAMETERS
# These user-configurable parameters should be updated to reflect the local
# automation environment.
###############################################################################

# (Required) RPM_NAME = The puppet agent release RPM
#  bash shell: 'puppetlabs-release-pc1-cisco-wrlinux-5.noarch.rpm'
#  guestshell: 'puppetlabs-release-pc1-el-7.noarch.rpm'
RPM_NAME = 'puppetlabs-release-pc1-cisco-wrlinux-5.noarch.rpm'

# (Required) RPM_URI = The download URI for the RPM
# RPM_URI = 'ftp://1.2.3.4/'
RPM_URI = 'http://yum.puppetlabs.com/'

# (required) PUPPET_SERVER = The DNS name or IP address of the agent's puppet server
PUPPET_SERVER = 'puppet-cvh.cisco.com'

# (Optional) VRF = The agent's VRF to use for the RPM install
VRF = 'management'

# (Optional) HTTP_PROXY = local http proxy server
# (Optional) HTTPS_PROXY = local https proxy server
# (Optional) NO_PROXY = proxy exclusions
HTTP_PROXY = 'http://proxy.esl.cisco.com:8080'
HTTPS_PROXY = 'https://proxy.esl.cisco.com:8080'
NO_PROXY = ''

# (optional) DOMAIN = The domain name to use with the agent node
DOMAIN = 'cisco.com'

# (Optional) DNS = The DNS configuration to use for /etc/resolv.conf
# Use triple-quote syntax for multiple lines:
#  DNS = '''\
#  nameserver 1.2.3.4
#  domain cisco.com
#  '''
DNS = '''\
nameserver 64.102.6.247
nameserver 72.163.131.10
nameserver 173.36.131.10
search cisco.com
domain cisco.com
'''

###############################################################################
# End OF USER-CONFIGURABLE PARAMETERS
# Do not modify the following section.
###############################################################################

# Script initializations. Note: os.environ vars always win over script vars
PUPPET_BINARY = '/opt/puppetlabs/puppet/bin/puppet'
PUPPET_CONFIGPRINT = 'sudo ' + PUPPET_BINARY + 'agent --configprint config'

# Check for required vars
reqd_vars = ['RPM_NAME', 'RPM_URI', 'PUPPET_SERVER']
for v in reqd_vars:
    if not (v in globals() and len(v)):
        raise ValueError("Required parameter '%s' is not set" % v)

# Build PREPEND_CMD to specify both sudo and optional vrf (namespace)
PREPEND_CMD = ' sudo'
if os.environ.get('VRF'):
    PREPEND_CMD += ' ip netns exec ' + os.environ['VRF']
elif 'VRF' in globals() and len(VRF):
    PREPEND_CMD += ' ip netns exec ' + VRF

# Optionally set os.environ proxies
proxies = ['HTTP_PROXY', 'HTTPS_PROXY', 'NO_PROXY']
for p in proxies:
    if not os.environ.get(p):
        if p in globals() and len(p):
            os.environ[p] = globals()[p]

# Create a logfile
logfile = "/bootflash/puppet_agent_install.log"
t = time.localtime()
now = "%d.%d.%d" % (t.tm_hour, t.tm_min, t.tm_sec)
try:
    logfile = "%s.%s" % (logfile, now)
except Exception as e:
    print e
puppet_install_log = open(logfile, "w+")

# Do it!
configure_nameserver()
verify_reachability()
install_puppet()
configure_puppet()
run_puppet_agent()

puppet_install_log.close()
exit(0)


###############################################################################
# METHODS
###############################################################################

def log_it(text):
    puppet_install_log.write(text + "\n")
    puppet_install_log.flush()
    print "puppet_install_log:\n" + text
    sys.stdout.flush()

def process_cmd(cmd):
    """Process native bash or guestshell command"""

    log_it('\n@@Processing CMD: ' + cmd + '\n')
    args = shlex.split(cmd)
    p = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output,error = p.communicate()
    if p.returncode == 0:
        if output:
            log_it(output)
        return output.rstrip()
    else:
        msg="FAIL: {0}{1}".format(output, error)
        log_it(msg)
        return msg

def configure_nameserver():
    """Create /etc/resolv.conf in the agent environment"""

    if os.environ['DNS']:
        DNS = os.environ['DNS']
    elif 'DNS' not in globals():
	return

    resolv = '/etc/resolv.conf'
    process_cmd('sudo rm ' + resolv)
    with open(resolv, 'w') as f:
        f.write(DNS)
    process_cmd('sudo chmod 666 ' + resolv)

def verify_reachability():
    """Verify network reachability to puppet master and rpm repo """

    # Verify reachability to puppet master
    cmd = PREPEND_CMD + ' ping -c 5 ' + PUPPET_SERVER
    result = process_cmd(cmd)
    if result.find('FAIL') == 0:
        msg = "Failed to ping puppet master"
        log_it(msg)
        exit(0)

    # Verify reachability to RPM repo
    cmd = PREPEND_CMD + ' wget ' + RPM_URI
    result = process_cmd(cmd)
    if result.find('FAIL') == 0:
        msg = "Failed to contact RPM repo"
        log_it(msg)
        exit(0)

def install_puppet():
    """Install the puppet release rpm and agent rpm"""

    # First install the release rpm
    cmd = PREPEND_CMD + ' yum install -y ' + RPM_URI + RPM_NAME
    process_cmd(cmd)
    # CVH: Add check for return code?
    
    # now install agent rpm
    cmd = PREPEND_CMD + ' yum install -y '
    process_cmd(cmd)

def configure_puppet():
    """Configure puppet.conf"""

    if os.environ['DOMAIN']:
        DOMAIN = os.environ['DOMAIN']
    elif 'DOMAIN' not in globals():
	DOMAIN = ''

    conf = '''
    [main]
    certname = %s
    server = %s
    ''' % (process_cmd('hostname') + DOMAIN, PUPPET_SERVER)

    conf_file = process_cmd(PUPPET_CONFIGPRINT)
    process_cmd('sudo rm ' + conf_file)
    with open(conf_file, 'w') as f:
        f.write(conf)
    process_cmd('sudo chmod 666 ' + conf_file)

def run_puppet_agent():
    """Kickstart the puppet agent"""

    cmd = PREPEND_CMD + ' ' + PUPPET_BINARY + ' agent -t'
    process_cmd(cmd)

