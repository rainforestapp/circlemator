[![Codacy Badge](https://api.codacy.com/project/badge/Grade/4629a31098bf4d49b8171f45dbbd06b3)](https://www.codacy.com/app/mail_57/circlemator?utm_source=github.com&utm_medium=referral&utm_content=rainforestapp/circlemator&utm_campaign=badger)
# Circlemator [![Circle CI](https://circleci.com/gh/rainforestapp/circlemator.png?style=badge&circle-token=0b39cf33b52e34ef6bb29cf2f2a1c071fef3f26f)](https://circleci.com/gh/rainforestapp/circlemator)

Circlemator is a bucket of tricks for working with CircleCI and Github
used internally at [Rainforest QA](http://www.rainforestqa.com).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'circlemator', require: false
```

Then run `bundle` and check in the resulting Gemfile.lock. That should
be enough, really.

## Usage

Circlemator tasks are designed to be added to your circle.yml file
like so:

```yml
- bundle exec circlemator <task> [options]
```

Different tasks require different options/placement in your
circle.yml.

## Tasks

### Cancel old builds

CircleCI starts a build every time you push to Github. That's usually
a good thing, but if you have a big test suite it can be annoying when
your build queue gets gummed up running builds on out-of-date
commits. To clear things up, the `cancel-old` task cancels all builds
that are not at the head of their branch. It should be in your
circle.yml before your tests are run but after the dependencies have
been fetched, for example:

```yml
test:
  pre:
    - bundle exec circlemator cancel-old
```

In order for this to work, you need the following environment variable
to be set in CircleCI:

- `CIRCLE_API_TOKEN`: Your CircleCI API token. (Can also be set with
  the `-t` option.)

### Style check

Think of this as a poor man's HoundCI: it runs Rubocop (and/or more
linters/checkers TBD) and comments on the Github pull request using
the excellent [Pronto](https://github.com/mmozuras/pronto). Use it
like so:

```yml
test:
  pre:
    - bundle exec circlemator style-check --base-branch=develop
```

(Note: use local branch names, like `develop` instead of
`origin/develop`; `origin` will be prepended for running pronto as
necessary.)

It probably makes sense to put `style-check` in either the `pre` or
`override` steps.)

`style-check` requires the following environment variable to be set:

- `GITHUB_ACCESS_TOKEN`: A Github API auth token for a user with commit
  access to your repo. (Can also be set with the `-g` option.)

### Self-merge release branch

Preamble: at Rainforest, our process for getting code into production
looks like this:

1. Push to feature branch pull request.
2. Run unit tests and get code review (repeat 1-2 as necessary).
3. Merge feature branch to `develop`.
4. Open release pull request from `develop` to `master`.
5. Run unit tests + [Rainforest](http://www.rainforestqa.com) against `develop`.
6. Merge `develop` into `master` if everything's green.
7. Deploy from `master`.

Out of these, steps 1, 2, 3, and 4 require manual intervention, but
everything else should be automatic! The `self-merge` task is designed
to take care of step 6 (the rest is handled by CircleCI out of the
box).

To use `self-merge`, add something like the following to your
circle.yml:

```yml
deployment:
  staging:
    branch: develop
    commands:
      <any commands you would normally run>
      - bundle exec circlemator self-merge --base-branch=master --compare-branch=develop
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

- Make sure you're an owner on rubygems.org
- `rake release`
