lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reel_uk/version'

Gem::Specification.new do |spec|
  spec.name          = 'reel_uk'
  spec.version       = ReelUk::VERSION
  spec.authors       = ['Andy Croll']
  spec.email         = ['andy@goodscary.com']
  spec.description   = 'Pull movie & cinema information from the Reel Cinemas website'
  spec.summary       = "It's a scraper, but a nice one"
  spec.homepage      = 'https://github.com/andycroll/reel_uk'
  spec.licenses      = %w(AGPL MIT)

  spec.required_ruby_version = '>= 3.4'

  spec.files         = Dir['lib/**/*.rb', 'README.md', 'CHANGELOG.md', 'LICENSE', 'COMM-LICENSE']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 2.0'
  spec.add_development_dependency 'minitest-mock'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov', '< 2'
  spec.add_development_dependency 'webmock'

  spec.add_runtime_dependency 'cinebase', '~> 5.8'
end
