# frozen_string_literal: true
require 'httparty'
require 'json'
require 'pronto'
require 'pronto/commentator'
require 'circlemator/pr_finder'

module Circlemator
  class CodeAnalyser
    def initialize(opts)
      @opts = opts
      @base_branch = opts.fetch(:base_branch)
    end

    def check_coverage
      require 'pronto/undercover'
      run_pronto
    end

    def check_style
      require 'pronto/rubocop'
      run_pronto
    end

    def check_security
      require 'pronto/brakeman'
      run_pronto
    end

    private

    def run_pronto
      Pronto.run("origin/#{@base_branch}", '.', formatter)
    end

    def formatter
      pr_number, _ = PrFinder.new(@opts).find_pr
      if pr_number
        ENV['PRONTO_PULL_REQUEST_ID'] = pr_number.to_s
        Pronto::Formatter::GithubPullRequestFormatter.new
      else
        Pronto::Formatter::GithubFormatter.new
      end
    end
  end
end
