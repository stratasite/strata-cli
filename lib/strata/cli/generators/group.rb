module Strata::CLI::Generators
  class Group < Thor::Group
    include Thor::Actions

    def self.source_root
      File.expand_path("templates/", __dir__)
    end

    def self.exit_on_failure?
      true
    end
  end
end
