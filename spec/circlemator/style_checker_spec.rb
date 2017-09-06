# frozen_string_literal: true
require 'circlemator/style_checker'
require 'circlemator/pr_finder'
require 'circlemator/github_repo'
require 'pronto'

RSpec.describe Circlemator::StyleChecker do
  describe 'check!' do
    let(:github_repo) do
      Circlemator::GithubRepo.new user: 'rainforestapp',
                                  repo: 'circlemator',
                                  github_auth_token: 'abc123'
    end
    let(:checker) do
      Circlemator::StyleChecker.new github_repo: github_repo,
                                    sha: 'abc123',
                                    base_branch: 'master',
                                    compare_branch: 'topic'
    end
    let(:pronto_double) { double }

    subject { checker.check! }

    context 'with an open PR' do
      let(:pr_number) { 12345 }

      before do
        allow_any_instance_of(Circlemator::PrFinder)
          .to receive(:find_pr).and_return [pr_number, '']
      end

      it 'runs pronto against that PR' do
        expect(Pronto::Formatter::GithubPullRequestFormatter).to receive(:new).and_return pronto_double
        expect(Pronto).to receive(:run).with 'origin/master', '.', pronto_double

        subject

        expect(ENV['PRONTO_PULL_REQUEST_ID']).to eq pr_number.to_s
      end
    end

    context 'without an open PR' do
      before do
        allow_any_instance_of(Circlemator::PrFinder)
          .to receive(:find_pr).and_return nil
      end

      it 'runs pronto against the commit' do
        expect(Pronto::Formatter::GithubFormatter).to receive(:new).and_return pronto_double
        expect(Pronto).to receive(:run).with 'origin/master', '.', pronto_double

        subject
      end
    end
  end
end
