require_relative "group"

module Strata
  module CLI
    module Generators
      class AddDs < Group
        argument :adapter, type: :string, desc: "Data warehouse adapter to add as a datasource.", required: true
        argument :name, type: :string, desc: "Optional name to be used as the key for the datasource.", required: false
        class_option :path, type: :string, desc: "Need path when outside project directory"

        def check_duckdb_requirements
          return unless adapter.downcase == "duckdb"

          unless duckdb_installed?
            raise DWH::ConfigError, "DuckDB is not installed. Please install DuckDB. We will need the header files to compile libraries."
          end

          install_duckdb_gem
        end

        def add_datasource_config
          @ds_key = get_unique_ds_key
          say_status :adapter, "adding #{adapter} template to datasources", :yellow

          # Process template in memory without creating temp file
          template_content = render_template("adapters/#{adapter}.yml")
          append_to_file pathify("datasources.yml"), "\n#{template_content}"
        end

        private

        def duckdb_installed?
          # Check if DuckDB is installed globally by trying to run it
          system("duckdb --version > /dev/null 2>&1")
        end

        def install_duckdb_gem
          say_status :gem, "Installing duckdb gem...", :yellow

          begin
            # Install the duckdb gem
            run "gem install duckdb", verbose: false, capture: true
            say_status :success, "duckdb gem installed successfully", :green
          rescue => e
            raise DWH::ConfigError, "Failed to install duckdb gem: #{e.message}"
          end
        end

        def pathify(file)
          options["path"].nil? ? file : "#{options["path"].gsub(/$\//, "")}/#{file}"
        end

        def get_unique_ds_key
          base_key = (name && !name.strip.empty?) ? Utils.url_safe_str(name) : adapter
          key_id = 1
          ds_key = base_key
          while current_ds.key?(ds_key)
            ds_key = "#{base_key}_#{key_id}"
            key_id += 1
          end
          ds_key
        end

        def current_ds
          @ds ||= YAML.load_file(pathify("datasources.yml")) || {}
        end

        def render_template(source, context: instance_eval("binding", __FILE__, __LINE__))
          source = File.expand_path(find_in_source_paths(source.to_s))
          capturable_erb = CapturableERB.new(::File.binread(source), trim_mode: "-", eoutvar: "@output_buffer")
          capturable_erb.tap { |erb| erb.filename = source }.result(context)
        end
      end
    end
  end
end
