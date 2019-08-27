# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name    = "seielit-figaro"
  gem.version = "1.1.2"

  gem.author      = "Steve Richert"
  gem.email       = "steve.richert@gmail.com"
  gem.summary     = "Simple Rails app configuration"
  gem.description = "Simple, Heroku-friendly Rails app configuration using ENV and a single YAML file (fork of https://github.com/laserlemon/figaro)"
  gem.homepage    = "https://github.com/seielit/figaro"
  gem.license     = "MIT"

  gem.add_dependency "thor", "~> 0.14"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake", "~> 10.4"

  gem.files      = `git ls-files`.split($\)
  gem.test_files = gem.files.grep(/^spec/)

  gem.executables << "figaro"
end
