# frozen_string_literal: true

require "vcr"

require "simplecov"
require "simplecov-lcov"
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::LcovFormatter, SimpleCov::Formatter::HTMLFormatter]
)
SimpleCov.start do
  add_filter(%r{/spec/})
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.warnings = true
  if config.files_to_run.one?
    config.default_formatter = "doc"
  end
  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end
