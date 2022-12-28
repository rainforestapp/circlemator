# frozen_string_literal: true
require 'httparty'
require 'json'

module Circlemator
  class SelfMerger
    MESSAGE = 'Auto-merge by Circlemator!'
    def initialize(opts)
      github_repo = opts.fetch(:github_repo)
      raise "#{github_repo} is invalid" unless github_repo.is_a? GithubRepo

      @github_repo = github_repo
      @sha = opts.fetch(:sha)
      @opts = opts
    end

    def merge!
      pr_number, pr_url = PrFinder.new(
        github_repo: @opts[:github_repo],
        base_branch: @opts[:base_branch],
        compare_branch: @opts[:compare_branch],
        sha: @opts[:sha]
      ).find_pr
      return if pr_number.nil? || pr_url.nil?

      response = @github_repo.put "#{pr_url}/merge",
                                  body: { commit_message: MESSAGE, sha: @sha }.to_json
      if response.code != 200
        body = JSON.parse(response.body)
        raise "Merge failed: #{body.fetch('message')}"
      end
    end
  end
end
