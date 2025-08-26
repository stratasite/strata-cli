require_relative "utils"
module Strata
  module CLI
    module Guard
      def invoke_command(command, *args)
        Utils.exit_error_if_not_strata! unless command.name == "init"
        super
      end
    end
  end
end
