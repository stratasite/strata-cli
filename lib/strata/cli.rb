# frozen_string_literal: true

require_relative "cli/version"
require_relative "cli/configuration"

module Strata
  module CLI
    class Error < StandardError; end

    @configuration = Configuration.new
    def self.config
      @configuration
    end
  end
end
