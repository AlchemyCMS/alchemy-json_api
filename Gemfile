# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in alchemy-json_api.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]
gem "sqlite3", "~> 2.2"

alchemy_branch = ENV.fetch("ALCHEMY_BRANCH", "7.3-stable")
gem "alchemy_cms", github: "AlchemyCMS/alchemy_cms", branch: alchemy_branch
gem "alchemy-devise", github: "AlchemyCMS/alchemy-devise", branch: "main"

gem "rubocop", require: false
gem "standard", "~> 1.25", require: false
gem "pry-byebug"
