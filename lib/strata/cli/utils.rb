module Strata
  module CLI
    module Utils
      module_function

      # Convert a given string to a Strata compliant
      # slug or url friendly ID.
      #
      # @param str [String]
      def url_safe_str(str)
        str.downcase.strip.gsub(/\s+/, "-").gsub(/[^\w-]/, "")
      end

      def exit_error_if_not_strata!
        unless CLI.config.strata_project?
          Thor::Shell::Color.new.say_error "ERROR: This is not a valid strata project", :red
          exit 1
        end
      end

      # Match a YAML block given a key.
      # It should match a block like so:
      #
      # key:
      #   attribute: value
      #   attr_2: val
      #
      # another_key: another_val
      #
      # This should match just the 'key' block
      # above.
      #
      # @param key [String]
      def yaml_block_matcher(key)
        /^#{key}:.*?(?=^\S|\z)/m
      end
    end
  end
end
