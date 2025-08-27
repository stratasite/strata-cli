require "thor"
require "dwh"
require_relative "cli/version"
require_relative "cli/configuration"
require_relative "cli/main"
require_relative "cli/utils"

module Strata
  class StrataError < StandardError; end

  class ConfigError < StrataError; end

  module CLI
    @configuration = Configuration.new
    def self.config
      @configuration
    end

    def self.start(args)
      Main.start(args)
    end
  end
end
