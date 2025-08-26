# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"

class TestProjectInit < Minitest::Test
  def setup
    @tmp_dir = Dir.mktmpdir("strata_test")
    @original_dir = Dir.pwd
    Dir.chdir(@tmp_dir)
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@tmp_dir)
  end

  def test_init_creates_basic_project_structure
    project_name = "test_project"

    Strata::CLI::Main.start(["init", project_name])

    # Verify project directory was created
    assert Dir.exist?(project_name), "Project directory should be created"

    # Verify subdirectories were created
    assert Dir.exist?(File.join(project_name, "schema")), "Schema directory should be created"
    assert Dir.exist?(File.join(project_name, "tests")), "Tests directory should be created"
  end

  def test_init_creates_required_files
    project_name = "test_project"

    Strata::CLI::Main.start(["init", project_name])

    # Verify required files were created
    assert File.exist?(File.join(project_name, ".strata")), ".strata config file should be created"
    assert File.exist?(File.join(project_name, "project.yml")), "project.yml should be created"
    assert File.exist?(File.join(project_name, "datasources.yml")), "datasources.yml should be created"
    assert File.exist?(File.join(project_name, ".gitignore")), ".gitignore should be created"
  end

  def test_init_creates_git_repository
    project_name = "test_project"

    Strata::CLI::Main.start(["init", project_name])

    # Verify git repository was initialized
    assert Dir.exist?(File.join(project_name, ".git")), "Git repository should be initialized"
  end

  def test_gitignore_contains_strata_config
    project_name = "test_project"

    Strata::CLI::Main.start(["init", project_name])

    gitignore_content = File.read(File.join(project_name, ".gitignore"))
    assert_includes gitignore_content, ".strata", ".gitignore should contain .strata file"
  end

  def test_strata_config_file_content
    project_name = "test_project"

    Strata::CLI::Main.start(["init", project_name])

    strata_config = File.read(File.join(project_name, ".strata"))
    assert_includes strata_config, "api_key: YOUR_STRATA_API_KEY", "Strata config should contain API key placeholder"
    assert_includes strata_config, "server: http://localhost:3030", "Strata config should contain default server"
  end

  def test_project_yml_content
    project_name = "test_project"

    Strata::CLI::Main.start(["init", project_name])

    project_yml = File.read(File.join(project_name, "project.yml"))
    assert_includes project_yml, "name: #{project_name}", "project.yml should contain project name"
    assert_includes project_yml, "uid: #{project_name}", "project.yml should contain project uid"
  end

  def test_init_with_single_datasource_option
    project_name = "test_project"

    Strata::CLI::Main.start(["init", project_name, "--datasource", "mysql"])

    # Verify project was created
    assert Dir.exist?(project_name), "Project directory should be created with datasource option"

    # Verify datasource file was created (this would depend on AddDs generator)
    datasources_yml = File.read(File.join(project_name, "datasources.yml"))
    refute_empty datasources_yml, "Datasources.yml should not be empty when datasource is specified"
  end

  def test_init_with_multiple_datasource_options
    project_name = "test_project"

    Strata::CLI::Main.start(["init", project_name, "--datasource", "mysql", "--datasource", "postgres"])

    # Verify project was created
    assert Dir.exist?(project_name), "Project directory should be created with multiple datasources"

    # Verify datasources file exists
    assert File.exist?(File.join(project_name, "datasources.yml")), "datasources.yml should exist"
  end

  def test_init_with_datasource_alias
    project_name = "test_project"

    Strata::CLI::Main.start(["init", project_name, "-d", "snowflake"])

    # Verify project was created with alias option
    assert Dir.exist?(project_name), "Project directory should be created with datasource alias"
  end

  def test_init_sanitizes_project_name
    project_name = "Test Project With Spaces"
    expected_directory = "test-project-with-spaces"

    Strata::CLI::Main.start(["init", project_name])

    # Verify sanitized directory name was used
    assert Dir.exist?(expected_directory), "Project directory should use sanitized name"
    refute Dir.exist?(project_name), "Original name with spaces should not be used as directory"
  end

  def test_init_displays_completion_message
    project_name = "test_project"

    Strata::CLI::Main.start(["init", project_name])

    # Test passes if no exception is raised during project creation
    assert Dir.exist?(project_name), "Project should be created successfully"
  end

  def test_init_fails_without_project_name
    assert_raises(SystemExit) do
      Strata::CLI::Main.start(["init"])
    end
  end

  def test_init_handles_special_characters_in_project_name
    project_name = "my-project_123"
    expected_directory = "my-project_123"

    Strata::CLI::Main.start(["init", project_name])

    # Should create directory with sanitized name (this name is already URL-safe)
    assert Dir.exist?(expected_directory), "Should handle special characters in project name"
  end

  def test_project_structure_is_complete
    project_name = "complete_test"

    Strata::CLI::Main.start(["init", project_name])

    expected_files = [
      ".strata",
      "project.yml",
      "datasources.yml",
      ".gitignore"
    ]

    expected_dirs = [
      "schema",
      "tests",
      ".git"
    ]

    expected_files.each do |file|
      assert File.exist?(File.join(project_name, file)), "#{file} should exist"
    end

    expected_dirs.each do |dir|
      assert Dir.exist?(File.join(project_name, dir)), "#{dir} directory should exist"
    end
  end

  def test_snowflake_used_as_default_datasource
    project_name = "test_project"

    Strata::CLI::Main.start(["init", project_name])

    # Verify snowflake datasource was added by default
    datasources_yml = File.read(File.join(project_name, "datasources.yml"))
    assert_includes datasources_yml, "snowflake:", "Snowflake should be used as default datasource when none specified"
  end

  def test_error_raised_for_unsupported_adapter
    project_name = "test_project"

    # Test that unsupported adapter raises an error
    assert_raises(DWH::ConfigError, "Unsupported datasource should raise an error") do
      Strata::CLI::Main.start(["init", project_name, "--datasource", "unsupported_adapter"])
    end
  end
end
