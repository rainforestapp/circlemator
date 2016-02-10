# frozen_string_literal: true
require 'circlemator/pr_finder'
require 'circlemator/github_repo'
require 'json'

RSpec.describe Circlemator::PrFinder do
  describe '#find_pr' do
    let(:github_repo) do
      Circlemator::GithubRepo.new(user: 'octocat', repo: 'Hello-World', github_auth_token: 'abc123')
    end
    let(:finder) do
      described_class.new github_repo: github_repo,
                          base_branch: base_branch,
                          compare_branch: compare_branch,
                          sha: sha
    end
    let(:sha) { '1234567' }
    let(:base_branch) { 'master' }
    let(:compare_branch) { 'new-topic' }
    let(:pr_number) { 1347 }
    let(:pr_url) { 'https://api.github.com/repos/octocat/Hello-World/pulls/1347' }
    let(:response) do
      [
        {
          'id' => 1,
          'url' => pr_url,
          'number' => pr_number,
          'state' => 'open',
          'title' => 'new-feature',
          'body' => 'Please pull these awesome changes',
          'head' => {
            'ref' => 'new-topic',
            'sha' => '1234567',
          },
          'base' => {
            'ref' => 'master',
            'sha' => '6dcb09b5b57875f334f61aebed695e2e4193db5e',
          }
        }
      ].to_json
    end

    subject { finder.find_pr }

    before do
      allow(github_repo).to receive(:get).and_return double(code: 200, body: response)
    end

    context 'with a successful response' do
      it 'returns the PR number and URL' do
        expect(subject).to eq [pr_number, pr_url]
      end
    end

    context 'with an unsuccessful response' do
      before do
        allow(github_repo).to receive(:get).and_return double(code: 500, body: 'BAD')
      end

      it 'raises an error' do
        expect { subject }.to raise_error Circlemator::PrFinder::BadResponseError
      end
    end

    context 'with a sha mismatch' do
      let(:sha) { 'abc123' }

      it { is_expected.to be_nil }
    end

    context 'with a base branch mismatch' do
      let(:base_branch) { 'develop' }

      it { is_expected.to be_nil }
    end

    context 'with a compare branch mismatch' do
      let(:compare_branch) { 'another-topic' }

      it { is_expected.to be_nil }
    end
  end
end
