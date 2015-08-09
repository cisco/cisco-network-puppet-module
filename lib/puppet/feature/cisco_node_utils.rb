require 'puppet/util/feature'

# We have the cisco_node_utils gem
Puppet.features.add(:cisco_node_utils, :libs => ['cisco_node_utils'])
