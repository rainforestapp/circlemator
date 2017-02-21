# frozen_string_literal: true
require 'circlemator/pr_cleaner'
require 'circlemator/github_repo'
require 'json'

RSpec.describe Circlemator::PrCleaner do
  describe '#clean!' do
    let(:github_repo) do
      Circlemator::GithubRepo.new(user: 'octocat', repo: 'Hello-World', github_auth_token: 'abc123')
    end
    let(:pr_url) { 'https://api.github.com/repos/octocat/Hello-World/pulls/1347' }
    let(:cleaner) do
      described_class.new github_repo: github_repo,
                          pr_url: pr_url
    end
    let(:user_id) { 7 }
    let(:user_response) do
      {
        'login' => 'octocat',
        'id' => user_id,
      }.to_json
    end
    let(:comments_response) do
      [
        {
          'id' => 1,
          'user' => {
            'id' => user_id,
          },
        },
        {
          'id' => 2,
          'user' => {
            'id' => user_id + 1,
          },
        },
        {
          'id' => 3,
          'user' => {
            'id' => user_id,
          },
        },
      ].to_json
    end

    subject { cleaner.clean! }

    before do
      allow(github_repo)
        .to receive(:get_current_user).and_return double(code: 200, body: user_response)
      allow(github_repo)
        .to receive(:get).with("#{pr_url}/comments").and_return double(code: 200, body: comments_response)
    end

    context 'with a successful response' do
      it 'deletes all the comments for the PR for the authenticated user' do
        expect(github_repo).to receive(:delete).with(%r(comments/1)).once
        expect(github_repo).to receive(:delete).with(%r(comments/3)).once
        expect(github_repo).to_not receive(:delete).with(%r(comments/2))

        subject
      end
    end

    context 'with an unsuccessful response' do
      before do
        allow(github_repo).to receive(:get).and_return double(code: 500, body: 'BAD')
      end

      it 'raises an error' do
        expect { subject }.to raise_error Circlemator::GithubRepo::BadResponseError
      end
    end
  end
end
