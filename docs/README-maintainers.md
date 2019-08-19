# Maintainers Guide

Guidelines for the core maintainers of the ciscopuppet project - above and beyond the [general developer guidelines](../CONTRIBUTING.md).

## Accepting Pull Requests

* Is the pull request correctly submitted against the `develop` branch?
* Does `rubocop` pass? (This is checked automatically by Travis-CI)
* Is `CHANGELOG.md` updated appropriately?
* Are new Beaker tests added? Do they provide sufficient coverage and consistent results?
* Are the example manifests updated appropriately? Does puppet-lint pass? (TODO - add to CI)
* Do tests pass on both N9K and N3K? (In particular, N3048 often has unique behavior.)
* Review the Gemfile
  * Is the data still relevant?
  * Do the version dependencies need to be updated? (e.g. rubocop)

## Release Process Checklist

### Pre-Merge to `master` branch:

When we are considering publishing a new release, all of the following steps must be carried out (using the latest code base in `develop`):

1. Pull release branch based on the `develop` branch.
      * 0.0.x - a bugfix release
      * 0.x.0 - new feature(s)
      * x.0.0 - backward-incompatible change (if unvoidable!)

1. Run full beaker test regression on [supported platforms.](https://github.com/cisco/cisco-network-puppet-module#resource-platform-support-matrix)
     * Fix All Bugs.
     * Make sure proper test case skips are in place for unsupported platforms.
     * Ensure that tests have been executed against released Gem versions (release a new version if necessary!) and do not have dependencies on unreleased Gem code.
     * Make sure to update [test_package_patch.rb](../tests/beaker_tests/file_service_package/test_package_patch.rb) for all versions that need to be validated.
       ```diff
       +when /7.0.3.I7.3/
       +  name = 'nxos.sample-n9k_ALL'
       +  filename = 'nxos.sample-n9k_ALL-1.0.0-7.0.3.I7.3.lib32_n9000.rpm'
       +  version =  '1.0.0-7.0.3.I7.3'
       ```

1. Update [changelog.](https://github.com/cisco/cisco-network-puppet-module/blob/develop/CHANGELOG.md)
     * Make sure CHANGELOG.md accurately reflects all changes since the last release.
     * Add any significant changes that weren't documented in the changelog
     * Clean up any entries that are overly verbose, unclear, or otherwise could be improved.
     * Indicate new platform support (if any) for exisiting providers.
     * Create markdown release tag.
       ```diff
       -## [Unreleased]
       +## [1.0.1] - 2015-08-28
       ...
       +[1.0.1]: https://github.com/cisco/cisco-network-puppet-module/compare/v1.0.0...v1.0.1
       [1.0.0]: https://github.com/cisco/cisco-network-puppet-module/compare/v0.9.0...v1.0.0
       ```

1. Update [metadata.json](https://github.com/cisco/cisco-network-puppet-module/blob/develop/metadata.json) file.
     * Update Version
       ```diff
          "name": "puppetlabs-ciscopuppet",
       -  "version": "1.0.0",
       +  "version": "1.0.1",
          "author": "cisco",
       ```
     * Update Supported OS Verions (if applicable)

1. Update [`cisco_node_utils.rb` rec_version = Gem::Version.new('x.x.x')](https://github.com/cisco/cisco-network-puppet-module/blob/develop/lib/puppet/feature/cisco_node_utils.rb#L40) version.

1. Verify/Update [netdev_stdlib version](https://github.com/cisco/cisco-network-puppet-module/blob/develop/metadata.json#L11) requirement if needed.

1. Verify puppet module can be built using the [new puppet module version](https://github.com/cisco/cisco-network-puppet-module/blob/develop/metadata.json#L3).

   ```apache
   # cd /etc/puppetlabs/code/environments/production/modules/cisco-network-puppet-module
   # pdk build
   pdk (INFO): Building puppetlabs-ciscopuppet version 2.1.0
   pdk (INFO): Build of puppetlabs-ciscopuppet has completed successfully. Built package can be found here: /etc/puppetlabs/code/environments/production/modules/cisco-network-puppet-module/pkg/puppetlabs-ciscopuppet-2.1.0.tar.gz

   # puppet module install /etc/puppetlabs/code/environments/production/modules/cisco-network-puppet-module/pkg/puppetlabs-ciscopuppet-2.1.0.tar.gz
   ```

1. Scrub README Docs.
     * Update references to indicate new platorm support where applicable.
     * Update nxos release information where applicable.
     * Update caveats for any new properties added in to existing/new providers.

1. Open pull request from release branch against the `master` branch.
     * Merge after approval.
     
1. Reach out to PuppetLabs and ask them to verify new release branches (Puppet and NodeUtils) against their CI.
     * **Important** Only after getting approval from puppet, move on to post-merge steps.

### Post-Merge to `master` branch:

1. Create annotated git tag for the release.
     * [HowTo](https://git-scm.com/book/en/v2/Git-Basics-Tagging#Annotated-Tags)
  
1. Draft a [new release](https://github.com/cisco/cisco-network-puppet-module/releases) on github.
  
1. Merge `master` branch back into `develop` branch.
     * Resolve any merge conflicts
     * Optional: Delete release branch (May want to keep for reference)
 
1. Reach out to PuppetLabs to publish the new module version to PuppetForge.
