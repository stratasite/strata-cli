require "yaml"

module Strata
  module CLI
    class Configuration
      DEFAULT_CONFIG = {
        "api_key" => "",
        "server" => "localhost:3030"
      }
      CONFIG_FILE = ".strata"
      attr_accessor :api_key, :server

      def initialize
        load_config
      end

      def global_config_file
        @global_config_file ||= File.expand_path(
          CONFIG_FILE,
          ENV["XDG_CONFIG_HOME"] || File.expand_path(".config", ENV["HOME"])
        )
      end

      def global_config_exists?
        File.exist?(global_config_file)
      end

      def local_config_file
        @local_config_file ||= File.expand_path(CONFIG_FILE)
      end

      def local_config_exists?
        File.exist?(local_config_file)
      end

      def load_config
        create_default_global_config
        @config = {}

        if global_config_exists?
          @config = @config.merge(YAML.load_file(global_config_file))
        end

        if local_config_exists?
          @config = @config.merge(YAML.load_file(local_config_file))
        end

        @api_key = @config["api_key"]
        @server = @config["server"]
      end

      def write_global_config(config)
        File.write(global_config_file, config.to_yaml)
      end

      def write_local_config(config)
        File.write(local_config_file, config.to_yaml)
      end

      private

      def create_default_global_config
        unless global_config_exists? || local_config_exists?
          directory = File.dirname(global_config_file)
          FileUtils.mkdir_p(directory) unless Dir.exist?(directory)
          write_global_config(DEFAULT_CONFIG)
        end
      end
    end
  end
end
