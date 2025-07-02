# frozen_string_literal: true

require_relative "cli/version"
require_relative "cli/configuration"
require_relative "cli/main"

module Strata
  module CLI
    class Error < StandardError; end

    @configuration = Configuration.new
    def self.config
      @configuration
    end

    def self.start(args)
      Main.start(args)
    end
  end
end
