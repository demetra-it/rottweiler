# frozen_string_literal: true

require_relative 'lib/rottweiler/version'

Gem::Specification.new do |spec|
  spec.name = 'rottweiler'
  spec.version = Rottweiler::VERSION
  spec.authors = ['Demetra Opinioni.net S.r.l.']
  spec.email = ['developers@opinioni.net']

  spec.summary = 'Rottweiler is a Ruby gem for easy verification of JSON Web Tokens (JWTs) in Rails applications.'
  spec.description = <<~DESC
    Rottweiler is a Ruby gem that provides functionality for verifying JSON Web Tokens (JWTs).
    It allows you to easily verify the authenticity and integrity of JWTs, making it an essential tool for applications
    that rely on JWT-based authentication and authorization.
    Rottweiler's intuitive interface and comprehensive documentation make it easy to use and integrate into new or existing Rails projects.
  DESC

  spec.homepage = 'https://github.com/demetra-it/rottweiler'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_runtime_dependency 'jwt', '>= 2.0'
  spec.add_runtime_dependency 'rails', '>= 5.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
