require "yaml"

module Strata
  module CLI
    class Configuration
      # Every strata project will have a .strata file
      CONFIG_FILE = ".strata"

      # Default configuration
      DEFAULT = {
        "api_key" => "",
        "server" => "http://localhost:3030",
        "log_level" => "info"
      }.freeze

      attr_reader :data
      def initialize
        @data = {}
        load_config
      end

      def [](key)
        @data[key]
      end

      def method_missing(method_name, *args, &block)
        if @data.key?(method_name.to_s)
          @data[method_name.to_s]
        else
          super
        end
      end

      def respond_to_missing?
        @data.key?(method_name.to_s) || super
      end

      def strata_project?
        File.exist?(config_file_path)
      end

      def config_file_path
        @config_file_path ||= File.expand_path(CONFIG_FILE)
      end

      # Get configuration value with type conversion
      def get(key, type: nil)
        value = self[key]
        return value unless type

        case type
        when :boolean
          convert_to_boolean(value)
        when :integer
          Integer(value)
        when :float
          Float(value)
        when :array
          Array(value)
        else
          value
        end
      rescue ArgumentError, TypeError => e
        raise StrataError, "Invalid #{type} value for '#{key}': #{value} \n\t#{e.message}"
      end

      def reload!
        @data.clear
        load_config
      end

      private

      def load_config
        raise ConfigError, "Not a valid Strata project" unless strata_project?
        @data = DEFAULT.merge(YAML.load_file(config_file_path))

        @api_key = @data["api_key"]
        @server = @data["server"]
      end

      def convert_to_boolean(value)
        case value
        when true, false
          value
        when "true", "yes", "1", 1
          true
        when "false", "no", "0", 0, nil
          false
        else
          raise ArgumentError, "Cannot convert #{value.inspect} to boolean"
        end
      end
    end
  end
end
