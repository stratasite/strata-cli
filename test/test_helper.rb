# frozen_string_literal: true

require "debug"

# Set ENV before loading the library to avoid memoization issues
ENV["XDG_CONFIG_HOME"] = "/tmp/strata-cli-test/.config"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "strata/cli"
require "minitest/autorun"

module TestHelper
  module_function

  def wipe_tmp_config_dir
    FileUtils.rm_rf("/tmp/strata-cli-test/")
  end
end
