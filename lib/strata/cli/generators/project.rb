require_relative "group"
require_relative "add_ds"

module Strata::CLI
  module Generators
    class Project < Group
      argument :name, type: :string, desc: "The name of the project. No spaces or non word characters."
      class_option :datasource, type: :string, repeatable: true
      desc "Generates a new Strata project."

      def create_project_structure
        empty_directory uid
        empty_directory File.join(uid, "schema")
        empty_directory File.join(uid, "tests")
      end

      def create_strata_config_file
        template "strata.yml", "#{uid}/.strata"
      end

      def create_project_file
        template "project.yml", "#{uid}/project.yml"
      end

      def create_datasources_file
        template "datasources.yml", "#{uid}/datasources.yml"

        if options.key?(:datasource)
          options[:datasource].each do |ds|
            raise "Unsupported datasource #{ds}" unless DWH.adapters?(ds.to_sym)
            AddDs.new([ds.downcase.strip], options.merge({"path" => uid})).invoke_all
          end
        else
          AddDs.new(["snowflake"], options.merge({"path" => uid})).invoke_all
        end
      end

      def initialize_git
        inside uid do
          run "git init", verbose: false, capture: true
          create_file ".gitignore", ".strata\n"
        end
      end

      def completion_message
        say_status :done, "Initialized Strata project: #{uid}", :yellow
      end

      private

      def uid
        @uid ||= Utils.url_safe_str(name)
      end
    end
  end
end
