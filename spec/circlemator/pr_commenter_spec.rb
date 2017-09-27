# frozen_string_literal: true
require 'circlemator/pr_finder'
require 'circlemator/pr_commenter'
require 'circlemator/github_repo'

RSpec.describe Circlemator::PrCommenter do
  describe 'comment' do
    let(:github_repo) do
      Circlemator::GithubRepo.new user: 'rainforestapp',
                                  repo: 'circlemator',
                                  github_auth_token: 'abc123'
    end
    let(:commenter) do
      Circlemator::PrCommenter.new github_repo: github_repo,
                                   sha: 'abc123',
                                   base_branch: 'master',
                                   compare_branch: 'topic'
    end

    subject { commenter.comment 'FOOBAR' }

    context 'with an open PR' do
      let(:pr_url) { 'https://api.github.com/repos/rainforestapp/circlemator/pulls/1' }

      before do
        allow_any_instance_of(Circlemator::PrFinder)
          .to receive(:find_pr).and_return [1, pr_url]
      end

      it 'comments on the PR' do
        expect(github_repo)
          .to receive(:post).with("#{pr_url}/reviews", body: { commit_id: 'abc123',
                                                               body: 'FOOBAR',
                                                               event: 'COMMENT',
                                                             }.to_json)
                .and_return double(code: 200)

        subject
      end
    end
  end
end
