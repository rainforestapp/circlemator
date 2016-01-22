require 'httparty'
require 'json'

module Circlemator
  class SelfMerger
    def initialize(user: ,
                   repo: ,
                   sha: ,
                   github_auth_token: ,
                   base_branch: ,
                   compare_branch: )
      @user = user
      @repo = repo
      @sha = sha
      @auth_token = github_auth_token
      @base_branch = base_branch
      @compare_branch = compare_branch
    end

    def merge!
      pr_number, pr_url = find_pr
      return if pr_number.nil? || pr_url.nil?

      msg = "Auto-merge by Circlemator!"
      response = HTTParty.put "#{pr_url}/merge",
                              body: { commit_message: msg, sha: @sha }.to_json,
                              basic_auth: github_auth
      if response.code != 200
        body = JSON.parse(response.body)
        raise "Merge failed: #{body.fetch('message')}"
      end
    end

    private

    def find_pr
      response = HTTParty.get "https://api.github.com/repos/#{github_repo}/pulls",
                              query: { base: @base_branch },
                              basic_auth: github_auth
      if response.code != 200
        raise "Bad response from Github: #{response.inspect}"
      end

      prs = JSON.parse(response.body)
      pr = prs.find do |pr|
        pr.fetch('head').fetch('ref') == @compare_branch &&
          pr.fetch('head').fetch('sha') == @sha &&
          pr.fetch('base').fetch('ref') == @base_branch
      end

      if pr.nil?
        puts 'No release PR. Not merging.'
        return
      end

      [pr.fetch('number'), pr.fetch('url')]
    end


    def github_repo
      "#{@user}/#{@repo}"
    end


    def github_auth
      { username: @auth_token, password: 'x-oauth-basic' }
    end
  end
end
