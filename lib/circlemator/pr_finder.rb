# frozen_string_literal: true
require 'circlemator/github_repo'

module Circlemator
  class PrFinder
    def initialize(github_repo:, base_branch:, compare_branch:, sha:, **_opts)
      @github_repo = github_repo
      @base_branch = base_branch
      @compare_branch = compare_branch
      @sha = sha
    end

    def find_pr
      response = @github_repo.get '/pulls', query: { base: @base_branch }
      if response.code != 200
        raise ::Circlemator::GithubRepo::BadResponseError, response
      end

      prs = JSON.parse(response.body)
      target_pr = prs.find do |pr|
        pr.fetch('head').fetch('ref') == @compare_branch &&
          pr.fetch('head').fetch('sha') == @sha &&
          pr.fetch('base').fetch('ref') == @base_branch
      end

      return if target_pr.nil?

      [target_pr.fetch('number'), target_pr.fetch('url')]
    end
  end
end
