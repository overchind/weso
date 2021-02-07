# frozen_string_literal: true

require_relative 'lib/weso/version'

Gem::Specification.new do |spec|
  spec.name          = 'weso'
  spec.version       = Weso::VERSION
  spec.authors       = ['Roman Ovcharov']
  spec.email         = ['overchind@gmail.com']

  spec.summary       = 'Ruby Websocket Client with the idea of simplicity and efficiency.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/overchind/weso'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org/'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/overchind/weso'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1.4'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.9.0'

  spec.add_dependency 'event_emitter', '~> 0.2.6'
  spec.add_dependency 'openssl', '~> 2.1.2'
  spec.add_dependency 'uri', '~> 0.10.0'
  spec.add_dependency 'websocket', '~> 1.2.8'
end
