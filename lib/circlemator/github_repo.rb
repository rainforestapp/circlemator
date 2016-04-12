# frozen_string_literal: true
require 'httparty'

module Circlemator
  class GithubRepo
    include HTTParty

    class InvalidPath < StandardError
      def initialize(path)
        super "Path #{path} is not valid for repo"
      end
    end

    class WrongRepo < StandardError
      def initialize(url, repo)
        super "URL #{url} does not belong to repo #{repo}"
      end
    end

    base_uri 'https://api.github.com/repos'

    def initialize(user:, repo:, github_auth_token:, **_opts)
      @user = user
      @repo = repo
      @auth_token = github_auth_token
    end

    def get(path, opts = {})
      self.class.get(fix_path(path), opts.merge(basic_auth: auth))
    end

    def put(path, opts = {})
      self.class.put(fix_path(path), opts.merge(basic_auth: auth))
    end

    private

    def fix_path(path)
      case path
      when %r(\A#{self.class.base_uri}(/#{@user}/#{@repo}.*)\z)
        $1
      when %r(\A#{self.class.base_uri})
        raise WrongRepo.new(path, "#{@user}/#{@repo}")
      when %r(\A/.*)
        "/#{@user}/#{@repo}#{path}"
      else
        raise InvalidPath, path
      end
    end

    def auth
      { username: @auth_token, password: 'x-oauth-basic' }
    end
  end
end
