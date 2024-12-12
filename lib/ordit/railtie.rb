# frozen_string_literal: true

module Ordit
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/ordit.rake"
    end

    initializer "ordit.setup" do
      require "ordit"
    end
  end
end
