require 'bundler/setup'
require 'webmock/rspec'
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

  # c.before_record { |i| i.request.uri.sub! Rails.application.secrets.telegram_token, '.token.' }
  # c.before_playback { |i| i.request.uri.gsub! '.token.', Rails.application.secrets.telegram_token }
  # c.before_http_request(:real?) { |request| request.uri.gsub! '.token.', Rails.application.secrets.telegram_token }

  c.configure_rspec_metadata!
end
