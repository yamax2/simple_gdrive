
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "simple_gdrive/version"

Gem::Specification.new do |spec|
  spec.name          = "simple_gdrive"
  spec.version       = SimpleGdrive::VERSION
  spec.authors       = ["Maxim Tretyakov"]
  spec.email         = ["max@tretyakov-ma.ru"]

  spec.summary       = %q{Simple Google Drive file uploader}
  spec.description   = %q{Simple Google Drive file uploader with autocreating required folders}
  spec.homepage      = "https://github.com/yamax2/simple_gdrive"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'google-api-client', '~> 0.19.6'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'shoulda-matchers'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
end