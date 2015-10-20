# How to Contribute
Cisco Network Elements support a rich set of features to make networks robust, efficient and secure. This project enables Cisco Network Elements to be managed by Puppet by defining a set of resource types and providers. This set is expected to grow with contributions from Cisco, Puppet Labs and third-party alike. Contributions to this project are welcome. To ensure code quality, contributers will be requested to follow a few guidelines.

## Getting Started

* Create a [GitHub account](https://github.com/signup/free)
* A virtual Nexus N9000/N3000 may be helpful for development and testing. Users with a valid [cisco.com](http://cisco.com) user ID can obtain a copy of a virtual Nexus N9000/N3000 by sending their [cisco.com](http://cisco.com) user ID in an email to <get-n9kv@cisco.com>. If you do not have a [cisco.com](http://cisco.com) user ID please register for one at [https://tools.cisco.com/IDREG/guestRegistration](https://tools.cisco.com/IDREG/guestRegistration)


## Making Changes

* Fork the repository
* Pull a branch under the "develop" branch for your changes.
* Follow all guidelines documented in [README-develop-types-providers](docs/README-develop-types-providers.md)
* Make changes in your branch.
* Testing
  * Add beaker test cases to validate your changes.
  * Run all the tests to ensure there was no collateral damage to existing code.
  * Check for unnecessary whitespace with `git diff --check`
  * Run `rubocop --lint` against all changed files. See [https://rubygems.org/gems/rubocop](https://rubygems.org/gems/rubocop)
* For new resources, add a 'demo' entry to examples/demo_install.rb
* Ensure that your commit messages clearly describe the problem you are trying to solve and the proposed solution.

## Submitting Changes

* All contributions you submit to this project are voluntary and subject to the terms of the Apache 2.0 license.
* Submit a pull request for commit approval to the "develop" branch.
* A core team consisting of Cisco and Puppet Labs employees will looks at Pull Request and provide feedback.
* After feedback has been given we expect responses within two weeks. After two weeks we may close the pull request if it isn't showing any activity.
* All code commits must be associated with your github account and email address. Before committing any code use the following commands to update your workspace with your credentials:

```bash
git config --global user.name "John Doe"
git config --global user.email johndoe@example.com
```
 
# Additional Resources

* [General GitHub documentation](http://help.github.com/)
* [GitHub pull request documentation](http://help.github.com/send-pull-requests/)
* \#puppet-dev IRC channel on freenode.org ([Archive](https://botbot.me/freenode/puppet-dev/))
* [puppet-dev mailing list](https://groups.google.com/forum/#!forum/puppet-dev)
