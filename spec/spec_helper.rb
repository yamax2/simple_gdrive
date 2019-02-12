require 'bundler/setup'
require 'pry-byebug'
require 'webmock/rspec'
require 'timecop'
require 'vcr'

require 'simple_gdrive'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock

  # remove all secrets from cassettes
  c.before_record do |i|
    i.request.body = ''
    i.request.headers['Authorization'] = 'token'
  end

  c.configure_rspec_metadata!
end
