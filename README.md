# Circlemator [![Circle CI](https://circleci.com/gh/rainforestapp/circlemator.png?style=badge&circle-token=0b39cf33b52e34ef6bb29cf2f2a1c071fef3f26f)](https://circleci.com/gh/rainforestapp/circlemator)

Circlemator is a bucket of tricks for working with CircleCI and Github
used internally at [Rainforest QA](http://www.rainforestqa.com).

## Installation

Install the docker image with `docker pull rainforestapp/circlemator`.

## Usage

```
docker run rainforestapp/circlemator style-check --base-branch=develop
docker run rainforestapp/circlemator test-coverage --base-branch=develop
docker run rainforestapp/circlemator test-security --base-branch=develop
docker run rainforestapp/circlemator self-merge --base-branch=master --compare-branch=develop
docker run rainforestapp/circlemator cancel-old
docker run rainforestapp/circlemator comment 'A totally unnecessary comment' --base-branch=develop
```

## Tasks

### Cancel old builds (`cancel-old`)

CircleCI starts a build every time you push to Github. That's usually
a good thing, but if you have a big test suite it can be annoying when
your build queue gets gummed up running builds on out-of-date
commits. To clear things up, the `cancel-old` task cancels all builds
that are not at the head of their branch. It should be in your
`circle.yml` before your tests are run but after the dependencies have
been fetched.

In order for this to work, you need the following environment variable
to be set in CircleCI:

- `CIRCLE_API_TOKEN`: Your CircleCI API token. (Can also be set with
  the `-t` option.)

### Comment (`comment`)

You can comment on the open PR using the `comment` command:

```
docker run rainforestapp/circlemator comment 'A totally unnecessary comment' --base-branch=develop
```

### Style check

Think of this as a poor man's HoundCI: it runs Rubocop (and/or more
linters/checkers TBD) and comments on the Github pull request using
the excellent [Pronto](https://github.com/prontolabs/pronto). Use it
like so:

```
docker run rainforestapp/circlemator style-check --base-branch=develop
```

(Note: use local branch names, like `develop` instead of
`origin/develop`; `origin` will be prepended for running pronto as
necessary.)

It probably makes sense to put `style-check` in either the `pre` or
`override` steps.)

`style-check` requires the following environment variable to be set:

- `GITHUB_ACCESS_TOKEN`: A Github API auth token for a user with commit
  access to your repo. (Can also be set with the `-g` option.)

### Code coverage check

The code coverage check looks for untested lines in the pull request using [Pronto](https://github.com/prontolabs/pronto) and [Undercover](https://github.com/grodowski/undercover) and posts warnings as PR comments.

Set up code coverage reporting with SimpleCov to start finding untested code after tests have been executed:

```rb
# Gemfile
group :test do
  gem 'simplecov'
  gem 'simplecov-lcov'
end
```

```rb
# spec_helper.rb (or test_helper.rb)

require 'simplecov'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
SimpleCov.start do
  add_filter(/^\/spec\//) # For RSpec

  add_filter(/^\/test\//) # For Minitest
end

require 'your_app'

# ...
```

Then use it like this:

```
docker run rainforestapp/circlemator test-coverage --base-branch=develop
```

Circlemator reads additional config from [.pronto.yml](https://github.com/grodowski/pronto-undercover#configuring)

`test-coverage` requires the following environment variable to be set:

- `GITHUB_ACCESS_TOKEN`: A Github API auth token for a user with commit
  access to your repo. (Can also be set with the `-g` option.)

### Security check

The security check looks for common security errors using [Pronto](https://github.com/prontolabs/pronto) and [Brakeman](https://github.com/presidentbeef/brakeman) Static Application Security Testing and post warnings as PR comments.

```
docker run rainforestapp/circlemator test-security --base-branch=develop
```

(Note: use local branch names, like `develop` instead of
`origin/develop`; `origin` will be prepended for running pronto as
necessary.)

It probably makes sense to put `test-security` in either the `pre` or
`override` steps.)

`test-security` requires the following environment variable to be set:

- `GITHUB_ACCESS_TOKEN`: A Github API auth token for a user with commit
  access to your repo. (Can also be set with the `-g` option.)

### Self-merge release branch

Preamble: at Rainforest, our process for getting code into production
looks like this:

1. Push to feature branch pull request.
2. Run unit tests and get code review (repeat 1-2 as necessary).
3. Merge feature branch to `master`.
4. Deploy from `master`.

Out of these, steps 1, 2, and 3 require manual intervention, but
everything else should be automatically handled by CircleCI!

To use `self-merge`, add something like the following to your
circle.yml:

```yml
docker run rainforestapp/circlemator self-merge --base-branch=master --compare-branch=develop
```

Swap out `develop` and `master` as necessary to fit your workflow. Be
warned, the `circlemator` command should probably be the last command
in your deploy stage! (Otherwise you'll merge before your build is
done.)

`self-merge` will *only* run if there is an open pull request against
the base branch. That means you have a way to prevent automatic
shipping in exceptional circumstances: just don't open a release pull
request.

`self-merge` requires the following environment variable to be set:

- `GITHUB_ACCESS_TOKEN`: A Github API auth token for a user with commit
  access to your repo. (Can also be set with the `-g` option.)

Also, unfortunately branch protection cannot be enabled on your
`master` branch. (Contributions welcome for anyone who can think of a
workaround...)

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/rainforestapp/circlemator.

### Releasing

Merge to master, Google will build a new docker image and release it on GCR.io at https://gcr.io/rf-public-images/circlemator
