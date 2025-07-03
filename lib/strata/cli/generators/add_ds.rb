require_relative "group"

module Strata::CLI::Generators
  class AddDs < Group
    argument :adapter, type: :string, desc: "Data warehouse adapter to add as a datasource.", required: true
    class_option :path, type: :string, desc: "Need path when outside project directory"

    def create_adapter_file
      @ds_key = get_unique_ds_key
      say_status :adapter, "adding #{adapter} template to datasources", :yellow
      template "#{adapter}.yml", pathify("tmp_ds.#{adapter}.yml")
    end

    def add_datasource_config
      append_to_file pathify("datasources.yml"), File.read(pathify("tmp_ds.#{adapter}.yml"))
    end

    def remove_temp_ds_file
      remove_file pathify("tmp_ds.#{adapter}.yml")
    end

    private

    def pathify(file)
      options["path"].nil? ? file : "#{options["path"].gsub(/$\//, "")}/#{file}"
    end

    def get_unique_ds_key
      key_id = 1
      ds_key = adapter
      while current_ds.key?(ds_key)
        ds_key = "#{ds_key}_#{key_id}"
        key_id += 1
      end
      ds_key
    end

    def current_ds
      @ds ||= YAML.load_file(pathify("datasources.yml")) || {}
    end
  end
end
