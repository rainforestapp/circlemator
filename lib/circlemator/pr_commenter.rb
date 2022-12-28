# frozen_string_literal: true

require "circlemator/pr_finder"

module Circlemator
  class PrCommenter
    def initialize(opts)
      github_repo = opts.fetch(:github_repo)
      raise "#{github_repo} is invalid" unless github_repo.is_a? GithubRepo

      @github_repo = github_repo
      @sha = opts.fetch(:sha)
      @opts = opts
    end

    def comment(text)
      _, pr_url = PrFinder.new(
        github_repo: @opts[:github_repo],
        base_branch: @opts[:base_branch],
        compare_branch: @opts[:compare_branch],
        sha: @opts[:sha]
      ).find_pr
      raise "PR not found!" unless pr_url

      response = @github_repo.post "#{pr_url}/reviews", body: { commit_id: @sha,
                                                                body: text,
                                                                event: "COMMENT",
                                                              }.to_json

      if response.code != 200
        body = JSON.parse(response.body)
        raise "PR Comment Failed: #{body.fetch('message')}"
      end
    end
  end
end
