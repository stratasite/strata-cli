# frozen_string_literal: true

require_relative "lib/strata/cli/version"

Gem::Specification.new do |spec|
  spec.name = "strata-cli"
  spec.version = Strata::CLI::VERSION
  spec.authors = ["Ajo Abraham"]
  spec.email = ["heyajo81@gmail.com"]

  spec.summary = "CLI to for the Strata Semantic Analytics System."
  spec.description = "CLI tool to interact with your Strata servers. Create new projects and deploy them."
  spec.homepage = "https://strata.size"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/stratasite/strata-cli.git"
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "thor", "~> 1.3.2"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
