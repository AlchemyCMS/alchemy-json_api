# frozen_string_literal: true

$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "alchemy/json_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "alchemy-json_api"
  spec.version = Alchemy::JsonApi::VERSION
  spec.authors = ["Martin Meyerhoff", "Thomas von Deyen"]
  spec.email = ["mamhoff@gmail.com"]
  spec.homepage = "https://github.com/AlchemyCMS/alchemy-json_api"
  spec.summary = "A JSONAPI compliant API for AlchemyCMS"
  spec.description = "A JSONAPI compliant API for AlchemyCMS"
  spec.license = "BSD-3-Clause"

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "alchemy_cms", [">= 8.1.0.a", "< 9"]
  spec.add_dependency "jsonapi.rb", [">= 1.6.0", "< 2.2"]

  spec.add_development_dependency "factory_bot"
  spec.add_development_dependency "jsonapi-rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "shoulda-matchers"
end
