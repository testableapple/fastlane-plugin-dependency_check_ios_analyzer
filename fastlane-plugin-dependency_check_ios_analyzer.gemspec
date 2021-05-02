# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/dependency_check_ios_analyzer/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-dependency_check_ios_analyzer'
  spec.version       = Fastlane::DependencyCheckIosAnalyzer::VERSION
  spec.author        = 'Alexey Alter-Pesotskiy'
  spec.email         = 'a.alterpesotskiy@mail.ru'

  spec.summary       = 'Fastlane wrapper around the OWASP dependency-check iOS analyzers (Swift Package Manager and CocoaPods).'
  spec.homepage      = 'https://github.com/alteral/fastlane-plugin-dependency_check_ios_analyzer'
  spec.license       = 'MIT'

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency('curb')
  spec.add_dependency('rubyzip')
  spec.add_dependency('cocoapods')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('fasterer', '0.8.3')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.144.0')
end
