# frozen_string_literal: true
require 'circlemator/github_repo'

RSpec.describe Circlemator::GithubRepo do
  let(:github_repo) { described_class.new(user: user, repo: repo, github_auth_token: auth_token) }
  let(:auth_token) { 'abc123' }
  let(:user) { 'rainforestapp' }
  let(:repo) { 'circlemator' }

  describe '#get' do
    context 'with a path' do
      it 'updates the path and adds the authorization' do
        expect(described_class)
          .to receive(:get).with("/repos/#{user}/#{repo}/pulls",
                                 query: { foo: :bar },
                                 basic_auth: { username: auth_token, password: 'x-oauth-basic' })

        github_repo.get('/pulls', query: { foo: :bar })
      end
    end

    context 'with a full URL' do
      it 'changes the URL to a path' do
        expect(described_class)
          .to receive(:get).with("/repos/#{user}/#{repo}/pulls", any_args)

        github_repo.get("https://api.github.com/repos/#{user}/#{repo}/pulls")
      end
    end

    context 'with an invalid path' do
      it 'raises an error' do
        expect { github_repo.get('foobar') }.to raise_error Circlemator::GithubRepo::InvalidPath
      end
    end

    context 'with a URL for the wrong repo' do
      it 'raises an error' do
        expect do
          github_repo.get('https://api.github.com/repos/rails/rails/pulls')
        end.to raise_error Circlemator::GithubRepo::WrongRepo
      end
    end
  end

  describe '#put' do
    it 'updates the path and adds the authorization' do
      expect(described_class)
        .to receive(:put).with("/repos/#{user}/#{repo}/pulls/123/merge",
                               body: { foo: :bar },
                               basic_auth: { username: auth_token, password: 'x-oauth-basic' })

      github_repo.put('/pulls/123/merge', body: { foo: :bar })
    end
  end
end
