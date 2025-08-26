require_relative "generators/project"
require_relative "sub_commands/datasource"

module Strata
  module CLI
    class Main < Thor
      include Guard

      def self.exit_on_failure?
        true
      end

      desc "version", "Prints this version of strata-cli"
      def version
        say VERSION
      end

      desc "init PROJECT_NAME", "Initializes a new Strata project."
      option :datasource, aliases: ["d"], type: :string, desc: "One of the supported data warehouse adapters.",
        repeatable: true
      def init(project_name)
        say_status :started, "Creating #{project_name} - #{options[:datasource]}", :yellow
        invoke Generators::Project, [project_name], options
      end

      desc "adapters", "Lists supported data warehouse adapters"
      def adapters
        out = " SUPPORTED ADAPTERS: \n\t#{DWH.adapters.keys.join("\n\t")}"
        say out, :magenta
      end

      desc "ds", "Manage project datasources"
      subcommand "ds", SubCommands::Datasource
    end
  end
end
