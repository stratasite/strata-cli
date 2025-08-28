require_relative "../guard"
require_relative "../credentials"
require_relative "../terminal"

module Strata
  module CLI
    module SubCommands
      class Datasource < Thor
        include Thor::Actions
        include Guard
        include Terminal

        desc "adapters", "Lists supported data warehouse adapters"
        def adapters
          say "\n\tSupported Adapters\n\n", :yellow
          DWH.adapters.keys.each do
            say "\t\t● #{it}", :magenta
          end
        end

        desc "list", "List current configured datasources by key and name"
        def list
          ds = YAML.load_file("datasources.yml")
          names = ds.keys.map { "#{it} => #{ds[it]["name"]}" }
          out = "\n  #{names.join("\n  ")}"
          say out, :magenta
        end

        desc "add [ADAPTER]", "Add a new datasource for [ADAPTER]"
        long_desc <<-LONGDESC
          Example: add a new datasource for postgres:

              strata ds add postgres

          Example: add a new datasource for mysql with key csops_db:

            strata ds add postgres -k csops_db
        LONGDESC
        method_option :key, aliases: ["k"], type: :string, required: false, desc: "Unique key to identify this datasource"
        def add(adapter)
          name = options[:key]

          unless DWH.adapters.key?(adapter.to_sym)
            say "Error: '#{adapter}' is not a supported adapter.", :red
            say "Supported adapters: #{DWH.adapters.keys.join(", ")}", :yellow
            return
          end

          require_relative "../generators/add_ds"
          generator = Generators::AddDs.new([adapter, name], options)
          generator.invoke_all

          say "Successfully added #{adapter} datasource configuration.", :green
        end

        desc "auth [DS_KEY]", "Set credentials for the given datasource key."
        long_desc <<-LONGDESC
          Example to set local credentials for a datasource with key games_dwh:

            strata ds auth games_dwh

          Example to set remote credentials for the same datasource:

            strata ds auth games_dwh -r

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

          say "\nEnter credentials for #{ds_key}", :red
          creds.collect
          creds.write_local(ds_key, self)

          say "Credentials saved successfully to .strata file.", :green
        end

        desc "test [DS_KEY]", "Test connect to the given datasource."
        def test(ds_key)
          adapter = create_adapter(ds_key)
          with_spinner("Testing #{ds_key} connection...", success_message: "Connected!",
            failed_message: "Failed to connect.") {
            adapter.test_connection(raise_exception: true)
          }
        rescue => e
          say "\t!! Failed to connect: \n\t#{e.message}", :red
        end

        desc "tables [DS_KEY]", "List tables from [DS_KEY] datasource"
        method_option :pattern, aliases: "p", type: :string, desc: "Regex pattern to filter table list"
        method_option :catalog, aliases: "c", type: :string, desc: "Change the catalog from the configured one."
        method_option :schema, aliases: "s", type: :string, desc: "Change the schema from the configured one."
        def tables(ds_key)
          say "\nListing #{ds_key} tables...\n\n", :yellow
          adapter = create_adapter(ds_key)
          tables = adapter.tables(**options)
          tables = tables.select { it =~ /#{options[:pattern]}/ } if options[:pattern]

          tables.each do
            say "\t● #{it}", :magenta
          end

          say "\nFound #{tables.count} table(s)", :yellow
        rescue => e
          say "\n\t!!Failed: #{e.message}", :red
        end

        desc "meta [DS_KEY] [TABLE_NAME]", "Show the structure of [TABLE_NAME] in datasource [DS_KEY]."
        method_option :catalog, aliases: "c", type: :string, desc: "Change the catalog from the configured one."
        method_option :schema, aliases: "s", type: :string, desc: "Change the schema from the configured one."
        def meta(ds_key, table_name)
          say "\n● Schema for table: #{table_name} (#{ds_key}):\n", :yellow
          adapter = create_adapter(ds_key)
          md = adapter.metadata(table_name, **options.transform_keys { it.to_sym })

          headings = md.columns.first.to_h.keys
          rows = md.columns.map(&:to_h).map(&:values)

          say print_table(rows, headers: headings, color: :yellow)
        rescue => e
          say "\n\t!!Failed: #{e.message}", :red
        end

        desc "exec [DS_KEY] -q \"select * from my_table\"", "Run the given query or queries on [DS_KEY]"
        long_desc <<-LONGDESC
          Example: run a single query inline on csops_db 

          strata ds exec csops_db -q "select * from customer limit 10;"

          Example: run queries from a file 

          strata ds exec csops_db -f path/to/my/file.sql
        LONGDESC
        method_option :query, aliases: "q", type: :string, desc: "Inline SQL query"
        method_option :file, aliases: "f", type: :string, desc: "SQL query from file"
        def exec(ds_key)
          adapter = create_adapter(ds_key)
          if options[:file]
            queries = File.read(options[:file]).split(";").reject { it.nil? || it.strip == "" }
          elsif options[:query]
            queries = options[:query].split(";").reject { it.nil? || it.strip == "" }
          else
            raise StrataError, "Either a file (-f) or a query (-q) should b submitted."
          end

          queries.each_with_index do |query, index|
            puts ""
            res = with_spinner("running #{index + 1}/#{queries.length} queries...") {
              adapter.execute(query, format: :object)
            }
            print_table(res.map(&:values), headers: res.first.keys)
          end
        rescue => e
          say "\n\t!!Failed: #{e.message}", :red
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
