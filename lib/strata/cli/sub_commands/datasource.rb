module Strata
  module CLI
    module SubCommands
      class Datasource < Thor
        desc "adapters", "Lists supported data warehouse adapters"
        def adapters
          out = "\nSUPPORTED ADAPTERS: \n\t#{ADAPTERS.join("\n\t")}"
          say out, :magenta
        end

        desc "list", "List current configured datasources by key and name"
        def list
          Utils.exit_error_if_not_strata!
          ds = YAML.load_file("datasources.yml")
          names = ds.keys.map { "#{it} => #{ds[it]["name"]}" }
          out = "\n  #{names.join("\n  ")}"
          say out, :magenta
        end

        desc "add", "Add a new datasource for specific data warehouse adapter"
        method_option :adapter, aliases: ["a"], type: :string, required: true, desc: "One of the supported data warehouse adapters."
        def add
        end

        desc "auth", "Set credentials and test connection to a datasource."
        long_desc <<-LONGDESC
          Example to set local credentials for a datasource with key games_dwh:
            `strata ds auth -d games_dwh`

          Example to set remote credentials for the same datasource:
            `strata ds auth -d games_dwh -r`

          Local credentials are saved in the projects .strata file. This will should not
          be checked into git.

          Remote credentials will securely send the credentials to the Strata server. This is
          not requires for some modes like OAuth. In that case each user will be prompted to 
          go through the OAuth flow. Not all adapters support OAuth.
        LONGDESC
        method_option :datasource, aliases: "d", type: :string, required: true, desc: "One of the datasource keys from datasources.yml"
        method_option :remote, aliases: "r", type: :boolean, desc: "Set credentials on remote server"
        def auth
          say options
        end

        desc "test", "Test connect to the given datasource."
        method_option :datasource, aliases: "d", type: :string, required: true, desc: "One of the datasource keys from datasources.yml"
        def test
          say options
        end

        desc "tables", "List tables from the given datasource"
        method_option :datasource, aliases: "d", type: :string, required: true, desc: "One of the datasource keys from datasources.yml"
        method_option :pattern, aliases: "p", type: :string, desc: "Limit tables to matching pattern. Use SQL compliant % for wild matches."
        method_option :database, aliases: "b", type: :string, desc: "Change the database from the configured one."
        method_option :catalog, aliases: "c", type: :string, desc: "Change the catalog from the configured one."
        method_option :schema, aliases: "s", type: :string, desc: "Change the schema from the configured one."
        def tables
          say options
        end

        desc "schema", "Show the schema of a specific table."
        method_option :datasource, aliases: "d", type: :string, required: true, desc: "One of the datasource keys from datasources.yml"
        method_option :table, aliases: "t", type: :string, required: true, desc: "Target table to inspect."
        method_option :database, aliases: "b", type: :string, desc: "Change the database from the configured one."
        method_option :catalog, aliases: "c", type: :string, desc: "Change the catalog from the configured one."
        method_option :schema, aliases: "s", type: :string, desc: "Change the schema from the configured one."
        def schema
          say options
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
      end
    end
  end
end
