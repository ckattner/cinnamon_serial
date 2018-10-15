# frozen_string_literal: true

require './lib/cinnamon_serial/version'

Gem::Specification.new do |s|
  s.name        = 'cinnamon_serial'
  s.version     = CinnamonSerial::VERSION
  s.summary     = 'Domain-specific language for serialization specification.'

  s.description = <<-DESCRIPTION
    Domain-specific language for serialization specification.
  DESCRIPTION

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mruggio@bluemarblepayroll.com']
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.homepage    = 'https://github.com/bluemarblepayroll/cinnamon_serial'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.3.1'

  s.add_development_dependency('pry', '~> 0.11.3')
  s.add_development_dependency('rspec', '~> 3.8.0')
  s.add_development_dependency('rubocop', '~> 0.59.2')
end
