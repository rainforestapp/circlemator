# frozen_string_literal: true
require 'httparty'
require 'json'
require 'pronto'
require 'pronto/rubocop'
require 'circlemator/pr_finder'

module Circlemator
  class StyleChecker
    def initialize(opts)
      @opts = opts
      @base_branch = opts.fetch(:base_branch)
    end

    def check!
      pr_number, _ = PrFinder.new(@opts).find_pr
      if pr_number
        ENV['PULL_REQUEST_ID'] = pr_number.to_s
        formatter = ::Pronto::Formatter::GithubPullRequestFormatter.new
      else
        formatter = ::Pronto::Formatter::GithubFormatter.new
      end

      ::Pronto.run("origin/#{@base_branch}", '.', formatter)
    end
  end
end
