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

      def raise_error_if_not_strata!
        unless File.exist?(File.expand_path("project.yml", Dir.pwd))
          Thor::Shell::Color.new.say_error "ERROR: This is not a valid strata project", :red
          exit 1
        end
      end
    end
  end
end
