require_relative "../guard"
require_relative "../credentials"

module Strata
  module CLI
    module SubCommands
      class Datasource < Thor
        include Thor::Actions
        include Guard

        desc "adapters", "Lists supported data warehouse adapters"
        def adapters
          out = "\nSUPPORTED ADAPTERS: \n\t#{DWH.adapters.keys.join("\n\t")}"
          say out, :magenta
        end

        desc "list", "List current configured datasources by key and name"
        def list
          ds = YAML.load_file("datasources.yml")
          names = ds.keys.map { "#{it} => #{ds[it]["name"]}" }
          out = "\n  #{names.join("\n  ")}"
          say out, :magenta
        end

        desc "add", "Add a new datasource for specific data warehouse adapter"
        method_option :adapter, aliases: ["a"], type: :string, required: true, desc: "One of the supported data warehouse adapters."
        method_option :key, aliases: ["k"], type: :string, required: false, desc: "Unique key to identify this datasource"
        def add
          adapter = options[:adapter]
          name = options[:key]

          unless DWH.adapters.key?(adapter.to_sym)
            say "Error: '#{adapter}' is not a supported adapter.", :red
            say "Supported adapters: #{DWH.adapters.keys.join(", ")}", :yellow
            return
          end

          require_relative "../generators/add_ds"
          generator = Strata::CLI::Generators::AddDs.new([adapter, name], options)
          generator.invoke_all

          say "Successfully added #{adapter} datasource configuration.", :green
        end

        desc "auth [DS_KEY]", "Set credentials for the given datasource key."
        long_desc <<-LONGDESC
          Example to set local credentials for a datasource with key games_dwh:
            `strata ds auth games_dwh`

          Example to set remote credentials for the same datasource:
            `strata ds auth games_dwh -r`

          Local credentials are saved in the projects .strata file. This will should not
          be checked into git.

          Remote credentials will securely send the credentials to the Strata server. This is
          not requires for some modes like OAuth. In that case each user will be prompted to 
          go through the OAuth flow. Not all adapters support OAuth.
        LONGDESC
        method_option :remote, aliases: ["r"], type: :boolean, desc: "Set credentials on remote server"
        def auth(ds_key)
          unless datasources[ds_key]
            say "Error: Datasource '#{ds_key}' not found in datasources.yml", :red
            return
          end

          adapter = datasources[ds_key]["adapter"]
          creds = Credentials.new(adapter)

          unless creds.required?
            say "Credentials not required for #{adapter} adapter.", :yellow
            return
          end

          say "Setting up credentials for datasource '#{ds_key}' (#{adapter})", :blue

          creds.collect
          creds.write_local(ds_key, self)

          say "Credentials saved successfully to .strata file.", :green
        end

        desc "test [DS_KEY]", "Test connect to the given datasource."
        def test(ds_key)
          say "\n\t● Testing #{ds_key} connection", :yellow
          adapter = create_adapter(ds_key)
          adapter.test_connection(raise_exception: true)
          say "\t✓ Connected!", :green
        rescue => e
          say "\t!! Failed to connect: \n\t#{e.message}", :red
        end

        desc "tables [DS_KEY]", "List tables from [DS_KEY] datasource"
        method_option :pattern, aliases: "p", type: :string, desc: "Limit tables to matching pattern. Use SQL compliant % for wild matches."
        method_option :catalog, aliases: "c", type: :string, desc: "Change the catalog from the configured one."
        method_option :schema, aliases: "s", type: :string, desc: "Change the schema from the configured one."
        def tables(ds_key)
          say "\n\t● Listing #{ds_key} tables\n\n", :yellow
          adapter = create_adapter(ds_key)
          tables = adapter.tables(**options)
          tables.each do
            say "\t\t● #{it}", :magenta
          end

          say "\n\t● End of List", :yellow
        rescue => e
          say "\n\t!!Failed: #{e.message}", :red
        end

        desc "meta [DS_KEY] [TABLE_NAME]", "Show the metadata of [TABLE_NAME] in datasource [DS_KEY]."
        method_option :catalog, aliases: "c", type: :string, desc: "Change the catalog from the configured one."
        method_option :schema, aliases: "s", type: :string, desc: "Change the schema from the configured one."
        def meta(ds_key, table_name)
          say "\n● #{table_name}(#{ds_key}):\n\n", :yellow
          adapter = create_adapter(ds_key)
          md = adapter.metadata(table_name, **options.transform_keys { it.to_sym })

          say "\t #{md.to_h}", :magenta
        rescue => e
          say "\n\t!!Failed: #{e.message}", :red
        end

        desc "exec", "Run the given query"
        method_option :datasource, aliases: "d", type: :string, required: true, desc: "One of the datasource keys from datasources.yml"
        method_option :table, aliases: "q", type: :string, required: true, desc: "SQL query or path to query file."
        method_option :database, aliases: "b", type: :string, desc: "Change the database from the configured one."
        method_option :catalog, aliases: "c", type: :string, desc: "Change the catalog from the configured one."
        method_option :schema, aliases: "s", type: :string, desc: "Change the schema from the configured one."
        def exec
          say options
        end

        private

        def datasources
          @datasources ||= YAML.load_file("datasources.yml")
        end

        def create_adapter(ds_key)
          config = ds_config(ds_key).merge(Credentials.fetch(ds_key))
          DWH.create(config["adapter"].to_sym, config)
        end

        def ds_config(ds_key)
          if datasources.key?(ds_key)
            datasources[ds_key]
          else
            raise "Datasource definition with key #{ds_key} was not found in datasources.yml file."
          end
        end
      end
    end
  end
end
