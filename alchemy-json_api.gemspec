# frozen_string_literal: true
$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "alchemy/json_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "alchemy-json_api"
  spec.version = Alchemy::JsonApi::VERSION
  spec.authors = ["Martin Meyerhoff"]
  spec.email = ["mamhoff@gmail.com"]
  spec.homepage = "https://github.com/AlchemyCMS/alchemy-json_api"
  spec.summary = "A JSONAPI compliant API for AlchemyCMS"
  spec.description = "A JSONAPI compliant API for AlchemyCMS"
  spec.license = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "alchemy_cms", "~> 5.0"
  spec.add_dependency "fast_jsonapi", "~> 1.5"
  spec.add_dependency "jsonapi.rb"

  spec.add_development_dependency "factory_bot"
  spec.add_development_dependency "github_changelog_generator"
  spec.add_development_dependency "jsonapi-rspec"
  spec.add_development_dependency "rspec-rails"
end
