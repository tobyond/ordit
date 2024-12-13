# frozen_string_literal: true

module Ordit
  class Definitions
    def self.all
      Ordit.configuration.view_paths.each_with_object(Set.new) do |path, controllers|
        Dir.glob(path.to_s).each do |file|
          content = File.read(file)
          matches = DefinitionMatcher.run(content)
          controllers.merge(matches)
        end
      end
    end
  end
end
