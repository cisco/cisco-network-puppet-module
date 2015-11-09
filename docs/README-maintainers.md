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

## Setting up git-flow

If you don't already have [`git-flow`](https://github.com/petervanderdoes/gitflow/) installed, install it.

Either run `git flow init` from the repository root directory, or manually edit your `.git/config` file. Either way, when done, you should have the following in your config:

```ini
[gitflow "branch"]
        master = master
        develop = develop
[gitflow "prefix"]
        feature = feature/
        release = release/
        hotfix = hotfix/
        support = support/
        versiontag = v
```

Most of these are default for git-flow except for the `versiontag` setting.

## Release Checklist

When we are considering publishing a new release, all of the following steps must be carried out (using the latest code base in `develop`):

1. With the latest released `cisco_node_utils` gem (no development code!
released only! Do a new gem release first if needed!), run Beaker tests and
demo manifests against all supported platforms running latest OS release or
release candidate:
  * N30xx
  * N31xx
  * N9xxx

2. Triage any test failures.

3. Make sure CHANGELOG.md accurately reflects all changes since the last release.
  * Add any significant changes that weren't documented in the changelog
  * Clean up any entries that are overly verbose, unclear, or otherwise could be improved.

## Release Process

When the release checklist above has been fully completed, the process for publishing a new release is as follows:


1. Ensure that tests have been executed against released Gem versions (release a new version if necessary!) and do not have dependencies on unreleased Gem code.

2. Create a release branch. Follow [semantic versioning](http://semver.org):
    * 0.0.x - a bugfix release
    * 0.x.0 - new feature(s)
    * x.0.0 - backward-incompatible change (only if unavoidable!)

    ```
    git flow release start 1.0.1
    ```

3. In the newly created release branch, update `CHANGELOG.md`:

    ```diff
    -## [Unreleased]
    +## [1.0.1] - 2015-08-28
    ...
    +[1.0.1]: https://github.com/cisco/cisco-network-puppet-module/compare/v1.0.0...v1.0.1
    [1.0.0]: https://github.com/cisco/cisco-network-puppet-module/compare/v0.9.0...v1.0.0
    ```
    
    and also update `metadata.json`:
    
    ```diff
       "name": "puppetlabs-ciscopuppet",
    -  "version": "1.0.0",
    +  "version": "1.0.1",
       "author": "cisco",
    ```
    
4. Commit your changes and push the release branch to GitHub for review by Cisco and PuppetLabs:

	```
	git flow release publish 1.0.1
	```
	
5. Once Cisco and PuppetLabs are in agreement that the release branch is sane, finish the release and push the finished release to GitHub:

    ```
    git flow release finish 1.0.1
    git push origin master
    git push origin develop
    git push --tags
    ```

6. Add release notes on GitHub, for example `https://github.com/cisco/cisco-network-puppet-module/releases/new?tag=v1.0.1`. Usually this will just be a copy-and-paste of the relevant section of the `CHANGELOG.md`.

7. Reach out to PuppetLabs to publish the new module version to PuppetForge.
