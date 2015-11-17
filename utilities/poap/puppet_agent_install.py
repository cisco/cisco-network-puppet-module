#!/isan/bin/python
#md5sum="389bc090fb2bf9661f86c3ebab80eb91"
import os
import time
import subprocess
import shlex
import sys

# *** The following variables parametrize this script ***
# Update these values with data for your network.  If any optional
# parameter is not needed simply set it to ''. Example: VRF = ''

# Mandatory Parameters:
DOMAIN        = 'cisco.com'
RPM_URI       = 'ftp://10.122.84.225/'
RPM_NAME      = 'puppet-agent-1.1.0.227.g1d8334c-1.nxos5.x86_64.rpm'
PUPPET_MASTER = 'rtp-puppetmaster2.' + DOMAIN

# Optional Parameters:
VRF           = 'management'
PROXY         = 'http://proxy.esl.cisco.com:8080'
PROXY_SECURE  = 'https://proxy.esl.cisco.com:8080'
DNS           = {'nameserver1': '64.102.6.247',
                 'nameserver2': '72.163.131.10',
                 'nameserver3': '173.36.131.10',
                 'domain': DOMAIN, 'search': DOMAIN}

# ------------------------------------------------------------------------#
# *** DO NOT MODIFY BELOW THIS LINE UNLESS YOU KNOW WHAT YOU AR DOING! ***#
# ------------------------------------------------------------------------#

PUPPET_BINARY = '/opt/puppetlabs/puppet/bin/puppet'
PUPPET_CONFIG_CMD = 'agent --configprint config'

# Build String to prepend to commands executed on the puppet agent.
PREPEND_CMD = ' sudo'
if 'VRF' in globals() and VRF:
    PREPEND_CMD += ' ' + 'ip netns exec ' + VRF

# Set PROXY environment variables
if 'PROXY' in globals() and PROXY:
    os.environ['http_proxy'] = PROXY
if 'PROXY_SECURE' in globals() and PROXY_SECURE:
    os.environ['https_proxy'] = PROXY_SECURE

#setup logging
log_filename = "/bootflash/puppet_agent_install.log"
t=time.localtime()
now="%d_%d_%d" % (t.tm_hour, t.tm_min, t.tm_sec)

try:
    log_filename = "%s.%s" % (log_filename, now)
except Exception as e:
    print e
puppet_install_log = open(log_filename, "w+")

def logIt(text):
    puppet_install_log.write(text + "\n")
    puppet_install_log.flush()
    print "puppet_install_log:\n" + text
    sys.stdout.flush()

def logClose():
    puppet_install_log.close()

def process_cmd(cmd):
    """Process native bash or guestshell command"""

    #print '\n@@Processing CMD: ' + cmd + '\n'
    args = shlex.split(cmd)
    p = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output,error = p.communicate()
    if p.returncode == 0:
        if output:
            logIt(output)
        return output.rstrip()
    else:
        msg="FAIL: {0}{1}".format(output, error)
        logIt(msg)
        return msg

def resolver_configure():
    """Configure /etc/resolv.conf on the agent"""
    
    ns, d, s, = 'nameserver ', 'domain ', 'search '
    rpath = '/etc/resolv.conf'
    temp_rpath = '/bootflash/resolv.conf'

    # Remove existing /etc/resolve.conf
    process_cmd('sudo rm ' + rpath)
    process_cmd('sudo touch ' + temp_rpath)
    process_cmd('sudo chmod 666 ' + temp_rpath)
    f = open(temp_rpath, 'r+')
    for k, v in DNS.iteritems():
        if k.find('nameserver') == 0:
            f.write(ns + v + '\n')
        if k.find('domain') == 0:
            f.write(d + v + '\n')
        if k.find('search') == 0:
            f.write(s + v + '\n')
    f.close()

    process_cmd('sudo cp ' + temp_rpath + ' ' + rpath)
    process_cmd('sudo rm ' + temp_rpath)

def networking_verify():
    """Verify network reachability"""

    # Verify reachability to puppet master
    cmd = PREPEND_CMD + ' ping -c 5 ' + PUPPET_MASTER
    result = process_cmd(cmd)
    if result.find('FAIL') == 0:
        msg = "Failed to ping puppet master"
        logIt(msg)
        exit(0)

    # Verify reachability to RPM repo
    cmd = PREPEND_CMD + ' wget ' + RPM_URI
    result = process_cmd(cmd)
    if result.find('FAIL') == 0:
        msg = "Failed to contact RPM repo"
        logIt(msg)
        exit(0)

def gpg_keys_process():
    """Import GPG keys and copy to /etc/pki/rpm-gpg"""

    pass

def yum_install():
    """Install the puppet rpm"""

    cmd = PREPEND_CMD + ' yum install -y ' + RPM_URI + RPM_NAME
    process_cmd(cmd)

def puppet_configure():
    """Add master server and SSL certificate to puppet.conf"""
    
    cmd = 'sudo ' + PUPPET_BINARY + ' ' + PUPPET_CONFIG_CMD
    pcfpath = process_cmd(cmd)
    temp_pcfpath = '/bootflash/puppet.conf'
    hostname = process_cmd('hostname')

    #process_cmd('sudo rm ' + temp_pcfpath)
    process_cmd('sudo touch ' + temp_pcfpath)
    process_cmd('sudo chmod 666 ' + temp_pcfpath)
    f = open(temp_pcfpath, 'r+')
    f.write('[main]\n')
    f.write('certname=' + hostname + '.' + DOMAIN + '\n')
    f.write('server=' + PUPPET_MASTER + '\n')
    f.close()

    process_cmd('sudo cp ' + temp_pcfpath + ' ' + pcfpath)
    process_cmd('sudo rm ' + temp_pcfpath)

def puppet_kickstart():
    """Kickstart the puppet agent"""

    cmd = PREPEND_CMD + ' ' + PUPPET_BINARY + ' agent -t'
    process_cmd(cmd)


resolver_configure()
networking_verify()
yum_install()
puppet_configure()
puppet_kickstart()

logClose()
exit(0)

