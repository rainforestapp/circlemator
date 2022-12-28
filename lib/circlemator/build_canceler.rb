# frozen_string_literal: true

require "httparty"
require "json"

module Circlemator
  class BuildCanceler
    def initialize(user:, repo:, current_build:, circle_api_token:)
      @user = user
      @repo = repo
      @current_build = current_build
      @circle_api_token = circle_api_token
    end

    def cancel_old_builds!
      resp = HTTParty.get "https://circleci.com/api/v1/project/#{@user}/#{@repo}",
                          circle_auth
      check_response resp

      builds = JSON.parse(resp.body)
               .select   { |b| %w(running scheduled queued not_running).include?(b.fetch("status")) && b["branch"] }
               .group_by { |b| b.fetch("branch") }
               .flat_map { |_, group| group.sort_by { |b| b.fetch("build_num") }[0...-1] }
               .map      { |b| b.fetch("build_num") }

      cancel_self = !!builds.delete(@current_build)

      builds.each do |build_num|
        resp = HTTParty.post "https://circleci.com/api/v1/project/#{@user}/#{@repo}/#{build_num}/cancel",
                             circle_auth
        check_response resp
      end

      if cancel_self
        puts "Daisy, Daisy, give me your answer, do..."
        HTTParty.post "https://circleci.com/api/v1/project/#{@user}/#{@repo}/#{@current_build}/cancel",
                      circle_auth
      end
    end

    private

    def circle_auth
      {
        query: { 'circle-token': @circle_api_token },
        headers: { "Accept" => "application/json" },
      }
    end

    def check_response(resp)
      if resp.code != 200
        raise "CircleCI API call failed: #{JSON.parse(resp.body)}"
      end
    end
  end
end
