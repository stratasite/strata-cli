# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"
require "stringio"

class TestDatasourceAdd < Minitest::Test
  def setup
    @tmp_dir = Dir.mktmpdir("strata_datasource_test")
    @original_dir = Dir.pwd
    Dir.chdir(@tmp_dir)

    # Create a basic project structure
    FileUtils.mkdir_p("schema")
    FileUtils.mkdir_p("tests")
    File.write("project.yml", "name: test_project\nuid: test_project\n")
    File.write("datasources.yml", "# Datasources configuration\n")
    File.write(".strata", "api_key: test\nserver: http://localhost:3030\n")

    # Force reload the configuration to pick up the .strata file in temp dir
    Strata::CLI.instance_variable_set(:@configuration, Strata::CLI::Configuration.new)
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@tmp_dir)
  end

  def test_add_postgres_datasource_success
    Strata::CLI::Main.start(["ds", "add", "--adapter", "postgres"])

    # Verify datasource was added to file
    datasources_content = File.read("datasources.yml")
    assert_includes datasources_content, "postgres:"
    assert_includes datasources_content, "adapter: postgres"
    assert_includes datasources_content, "name: MYDATASOURCENAME"
  end

  def test_add_snowflake_datasource_success
    Strata::CLI::Main.start(["ds", "add", "--adapter", "snowflake"])

    datasources_content = File.read("datasources.yml")
    assert_includes datasources_content, "snowflake:"
    assert_includes datasources_content, "adapter: snowflake"
    assert_includes datasources_content, "account_identifier:"
  end

  def test_add_mysql_datasource_success
    Strata::CLI::Main.start(["ds", "add", "--adapter", "mysql"])

    datasources_content = File.read("datasources.yml")
    assert_includes datasources_content, "mysql:"
    assert_includes datasources_content, "adapter: mysql"
  end

  def test_add_datasource_with_alias_flag
    Strata::CLI::Main.start(["ds", "add", "-a", "postgres"])

    datasources_content = File.read("datasources.yml")
    assert_includes datasources_content, "postgres:"
  end

  def test_add_unsupported_adapter_shows_error
    output = capture_io do
      Strata::CLI::Main.start(["ds", "add", "--adapter", "unsupported_adapter"])
    end

    error_output = output.join
    assert_includes error_output, "Error: 'unsupported_adapter' is not a supported adapter"
    assert_includes error_output, "Supported adapters:"

    # Verify no changes to datasources file
    datasources_content = File.read("datasources.yml")
    refute_includes datasources_content, "unsupported_adapter:"
  end

  def test_add_multiple_datasources_creates_unique_keys
    # Add first postgres datasource
    Strata::CLI::Main.start(["ds", "add", "--adapter", "postgres"])

    # Add second postgres datasource
    Strata::CLI::Main.start(["ds", "add", "--adapter", "postgres"])

    datasources_content = File.read("datasources.yml")
    assert_includes datasources_content, "postgres:"
    assert_includes datasources_content, "postgres_1:"
  end

  def test_add_duckdb_handles_special_requirements
    # Mock the duckdb installation check
    original_method = Strata::CLI::Generators::AddDs.instance_method(:duckdb_installed?)
    Strata::CLI::Generators::AddDs.define_method(:duckdb_installed?) { true }

    # Mock gem installation
    Strata::CLI::Generators::AddDs.define_method(:install_duckdb_gem) { true }

    Strata::CLI::Main.start(["ds", "add", "--adapter", "duckdb"])

    datasources_content = File.read("datasources.yml")
    assert_includes datasources_content, "duckdb:"
    assert_includes datasources_content, "adapter: duckdb"
  ensure
    # Restore original method
    Strata::CLI::Generators::AddDs.define_method(:duckdb_installed?, original_method)
  end

  def test_add_without_adapter_option_fails
    assert_raises(SystemExit) do
      Strata::CLI::Main.start(["ds", "add"])
    end
  end

  def test_add_preserves_existing_datasources
    # Add initial content to datasources.yml
    initial_content = <<~YAML
      # Initial configuration
      existing_ds:
        name: Existing Datasource
        adapter: postgres
    YAML
    File.write("datasources.yml", initial_content)

    Strata::CLI::Main.start(["ds", "add", "--adapter", "mysql"])

    datasources_content = File.read("datasources.yml")
    assert_includes datasources_content, "existing_ds:"
    assert_includes datasources_content, "Existing Datasource"
    assert_includes datasources_content, "mysql:"
  end

  private

  def capture_io
    original_stdout = $stdout
    original_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new

    yield

    [$stdout.string, $stderr.string]
  ensure
    $stdout = original_stdout
    $stderr = original_stderr
  end
end
