# frozen_string_literal: true

require "set"
require "pathname"
require_relative "ordit/version"
require_relative "ordit/configuration"
require_relative "ordit/auditor"
require_relative "ordit/scanner"
require_relative "ordit/result_generator"

if defined?(Rails)
  require "rails"
  require 'ordit'
  require "ordit/railtie"
end

module Ordit
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    def root
      if defined?(Rails)
        Rails.root
      else
        Pathname.new(Dir.pwd)
      end
    end
  end
end
