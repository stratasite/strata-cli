require_relative "utils"
module Strata
  module CLI
    module Guard
      ALLOWED_COMMANDS = %w[
        init
        help
        adapters
        version
      ]
      def invoke_command(command, *args)
        Utils.exit_error_if_not_strata! unless ALLOWED_COMMANDS.include?(command.name)
        super
      end
    end
  end
end
