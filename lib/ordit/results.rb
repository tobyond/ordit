# frozen_string_literal: true

module Ordit
  class Results
    def initialize(name = nil)
      @name = name
    end

    def files
      return Definitions.find(@name) if @name

      Files.all
    end

    def definitions
      Definitions.all
    end

    def active_controllers = to_h[:active_controllers].sort
    def undefined_controllers = to_h[:undefined_controllers]
    def unused_controllers = to_h[:unused_controllers].sort

    def to_h
      @to_h ||= begin
        base_object = {
          active_controllers: [],
          undefined_controllers: {},
          unused_controllers: files.dup || []
        }


        definitions.each_with_object(base_object) do |(definition, file), result|
          # Convert definition pattern to match file pattern
          file_pattern = definition_to_file_pattern(definition)

          # Find matching file
          matching_file = files.find { |f| file_pattern == file_pattern_from_path(f) }

          if matching_file
            result[:active_controllers] << matching_file
            result[:unused_controllers].delete(matching_file)
            result[:active_controllers].sort!
          else
            result[:undefined_controllers][definition] ||= []
            result[:undefined_controllers][definition] |= file
          end
        end
      end
    end

    private

    def definition_to_file_pattern(definition)
      # Handle nested paths (double hyphen becomes directory separator)
      path_parts = definition.split("--")

      # Convert each part from kebab-case to snake_case
      path_parts = path_parts.map { |part| part.gsub("-", "_") }

      # Join with directory separator
      path_parts.join("/")
    end

    def file_pattern_from_path(file)
      # Remove _controller.js suffix and return the pattern
      file.sub(/_controller\.(js|ts)$/, "")
    end
  end
end
