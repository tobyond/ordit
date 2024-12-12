# frozen_string_literal: true

require_relative "lib/ordit/version"

Gem::Specification.new do |spec|
  spec.name          = "ordit"
  spec.version       = Ordit::VERSION
  spec.authors       = ["Toby"]
  spec.email         = ["toby@darkroom.tech"]
  spec.summary       = "Audit Stimulus.js controllers in your Rails application"
  spec.description   = "A Ruby gem to analyze usage of Stimulus controllers, finding unused controllers and undefined controllers"
  spec.homepage      = "https://github.com/tobyond/ordit"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata = {
    "homepage_uri"    => spec.homepage,
    "changelog_uri"   => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "source_code_uri" => spec.homepage,
    "bug_tracker_uri" => "#{spec.homepage}/issues"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[
    lib/**/*
    README.md
    LICENSE.txt
    CHANGELOG.md
  ])
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
