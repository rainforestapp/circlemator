# frozen_string_literal: true
require 'circlemator/github_repo'

module Circlemator
  class PrCleaner
    def initialize(github_repo:, pr_url:)
      @github_repo = github_repo
      @pr_url = pr_url
      get_user_id
    end

    def clean!
      response = @github_repo.get("#{@pr_url}/comments")
      if response.code != 200
        raise ::Circlemator::GithubRepo::BadResponseError, response
      end

      comments = JSON.parse(response.body)
      comments.each do |comment|
        if comment.dig('user', 'id') == @user_id
          @github_repo.delete("#{@pr_url}/comments/#{comment.fetch('id')}")
        end
      end
    end

    private

    def get_user_id
      response = @github_repo.get_current_user
      if response.code != 200
        raise ::Circlemator::GithubRepo::BadResponseError, response
      end
      @user_id = JSON.parse(response.body).fetch('id')
    end
  end
end
