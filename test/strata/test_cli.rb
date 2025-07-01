# frozen_string_literal: true

require "test_helper"

class Strata::TestCli < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Strata::CLI::VERSION
  end

  def test_load_default_global_config
    # TestHelper.wipe_tmp_config_dir
    assert_equal "/tmp/strata-cli-test/.config", ENV["XDG_CONFIG_HOME"]
    assert_equal "/tmp/strata-cli-test/.config/.strata", Strata::CLI.config.global_config_file

    assert_equal Strata::CLI.config.server, "localhost:3030"
  end
end
