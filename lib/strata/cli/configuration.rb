require "yaml"

module Strata
  module CLI
    class Configuration
      DEFAULT_CONFIG = {
        "api_key" => "",
        "server" => "http://localhost:3030"
      }
      CONFIG_FILE = ".strata"
      attr_accessor :api_key, :server
      attr_reader :config

      def initialize
        @config = DEFAULT_CONFIG
        load_config
      end

      def local_config_file
        @local_config_file ||= File.expand_path(CONFIG_FILE)
      end

      def local_config_exists?
        File.exist?(local_config_file)
      end
      alias_method :is_strata_project?, :local_config_exists?

      def load_config
        if local_config_exists?
          @config = @config.merge(YAML.load_file(local_config_file))
        end

        @api_key = @config["api_key"]
        @server = @config["server"]
      end
    end
  end
end
