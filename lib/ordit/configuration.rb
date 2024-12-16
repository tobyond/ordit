# frozen_string_literal: true

module Ordit
  class Configuration
    attr_accessor :view_paths, :controller_paths

    def initialize
      reset
    end

    def reset
      base_path = Ordit.root

      @view_paths = [
        base_path.join("app/views/**/*.{html,erb,haml,slim}").to_s,
        base_path.join("app/components/**/*.{html,erb,haml,rb}").to_s
      ]

      @controller_paths = [
        base_path.join("app/javascript/controllers/**/*.{js,ts}").to_s
      ]
    end
  end
end
