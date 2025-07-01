# frozen_string_literal: true

require "debug"

# Set ENV before loading the library to avoid memoization issues
ENV["XDG_CONFIG_HOME"] = "/tmp/strata-cli-test/.config"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "strata/cli"
require "minitest/autorun"

# Clear any memoized config paths that may have been set before the ENV change
Strata::CLI::Configuration.class_eval do
  remove_instance_variable(:@global_config_file) if instance_variable_defined?(:@global_config_file)
end
