module Strata::CLI
  module Generators
    class Project < Thor::Group
      include Thor::Actions

      argument :name, type: :string, desc: "The name of the project. No spaces or non word characters."
      class_option :datasource, type: :string, repeatable: true
      desc "Generates a new Strata project."

      def self.source_root
        File.expand_path("templates/", __dir__)
      end

      def self.exit_on_failure?
        true
      end

      def create_project_structure
        empty_directory uid
        empty_directory File.join(uid, "schema")
        empty_directory File.join(uid, "tests")
      end

      def create_project_file
        template "project.yml", "#{uid}/project.yml"
      end

      def create_datasources_file
        template "datasources.yml", "#{uid}/datasources.yml"

        ds = []
        options[:datasource].each do
          @ds_key = it.downcase.strip
          key_id = 1
          while ds.include?(@ds_key)
            @ds_key = "#{it.downcase.strip}_#{key_id}"
            key_id += 1
          end

          template "#{it}.yml", "#{uid}/tmp_ds.#{@ds_key}.yml"
          ds << @ds_key
        end

        ds.each do
          append_to_file "#{uid}/datasources.yml", File.read("#{uid}/tmp_ds.#{it}.yml")
          remove_file "#{uid}/tmp_ds.#{it}.yml"
        end
      end

      def initialize_git
        inside uid do
          run "git init", verbose: false
          create_file ".gitignore", ".strata\n"
        end
      end

      def completion_message
        say "Initialized Strata project: #{uid}", :green
      end

      private

      def uid
        @uid ||= Utils.url_safe_str(name)
      end
    end
  end
end
