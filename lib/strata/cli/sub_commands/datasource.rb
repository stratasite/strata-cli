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
          Utils.raise_error_if_not_strata!
          ds = YAML.load_file("datasources.yml")
          names = ds.keys.map { "#{it} => #{ds[it]["name"]}" }
          out = "\n  #{names.join("\n  ")}"
          say out, :magenta
        end
      end
    end
  end
end
