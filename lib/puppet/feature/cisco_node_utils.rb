require 'puppet/util/feature'

# We have the cisco_node_utils gem at least version 1.0.0
Puppet.features.add :cisco_node_utils do
  begin
    require 'cisco_node_utils'
    min_version = Gem::Version.new('0.9.0')
    rec_version = Gem::Version.new('1.0.0')
    gem_version = Gem::Version.new(CiscoNodeUtils::VERSION)
    if gem_version < min_version
      error "This module requires version #{min_version} or later of the "\
            "'cisco_node_utils' gem but version #{gem_version} is installed. "\
            'Please upgrade.'
    elsif gem_version < rec_version
      warn "This module works best with version #{rec_version} of the "\
           "'cisco_node_utils' gem but version #{gem_version} is installed. "\
           'Some features may not be fully functional.'
    end
    gem_version >= min_version
  rescue LoadError
    false
  end
end
