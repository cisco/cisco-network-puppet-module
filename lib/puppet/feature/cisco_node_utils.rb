require 'puppet/util/feature'

# We have the cisco_node_utils gem
Puppet.features.add(:cisco_node_utils, libs: ['cisco_node_utils'])

# TODO: simplify if https://tickets.puppetlabs.com/browse/PUP-1159 gets fixed.
# Override the default caching logic created in Puppet.features:
#
# meta_def('cisco_node_utils?') do
#   # we return a cached result if:
#   #  * if a block is given (and we just evaluated it above)
#   #  * if we already have a positive result
#   #  * if we've tested this feature before and it failed, but we're
#   #    configured to always cache
#   if block_given? ||
#      @results['cisco_node_utils'] ||
#      (@results.has_key?('cisco_node_utils') and
#       Puppet[:always_cache_features])
#     @results['cisco_node_utils']
#   else
#     @results['cisco_node_utils'] = test('cisco_node_utils',
#                                         libs: ['cisco_node_utils'])
#     @results['cisco_node_utils']
#   end
# end

class <<Puppet.features
  def cisco_node_utils?
    # we return a cached result if:
    #  * if we already have a positive result
    #  * if we've tested this feature before and it failed, but we're
    #    configured to always cache
    if @results['cisco_node_utils'] ||
       (@results.key?('cisco_node_utils') && Puppet[:always_cache_features])
      @results['cisco_node_utils']
    else
      @results['cisco_node_utils'] = test('cisco_node_utils',
                                          libs: ['cisco_node_utils'])
      if @results['cisco_node_utils']
        rec_version = Gem::Version.new('1.3.0')
        gem_version = Gem::Version.new(CiscoNodeUtils::VERSION)
        if gem_version < rec_version
          warn "This module works best with version #{rec_version} of gem "\
               "'cisco_node_utils' but version #{gem_version} is installed. "\
               'Some features may not be fully functional.'
        end
      end
      @results['cisco_node_utils']
    end
  end
end
