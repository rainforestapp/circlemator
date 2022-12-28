# frozen_string_literal: true

require "circlemator/self_merger"
require "circlemator/github_repo"
require "circlemator/pr_finder"

RSpec.describe Circlemator::SelfMerger do
  describe "#merge!" do
    let(:github_repo) do
      Circlemator::GithubRepo.new user: "rainforestapp",
                                  repo: "circlemator",
                                  github_auth_token: "abc123"
    end
    let(:merger) do
      described_class.new github_repo: github_repo,
                          sha: "1234567",
                          base_branch: "master",
                          compare_branch: "topic"
    end
    let(:pr_url) { "https://api.github.com/rainforestapp/circlemator/pulls/12345" }

    before do
      allow_any_instance_of(Circlemator::PrFinder)
        .to receive(:find_pr)
             .and_return [12345, pr_url]
    end

    it "merges the pull request" do
      expect(github_repo)
        .to receive(:put).with("#{pr_url}/merge",
                               body: { commit_message: described_class::MESSAGE, sha: "1234567" }.to_json)
             .and_return double(code: 200)

      merger.merge!
    end
  end
end
