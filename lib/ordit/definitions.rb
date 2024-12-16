# frozen_string_literal: true

module Ordit
  class Definitions
    def self.all
      Ordit.configuration.view_paths.each_with_object({}) do |path, hash|
        Dir.glob(path.to_s).each do |file|
          content = File.read(file)
          matches = DefinitionMatcher.run(content)
          next if matches.empty?

          matches.each do |match|
            relative_file = Pathname.new(file).relative_path_from(
              Pathname.new(Ordit.root)
            ).to_s
            hash[match] ||= []
            hash[match] |= [relative_file]
          end
        end
      end
    end

    def self.find(name)
      Ordit.configuration.view_paths.flat_map do |path|
        results = Dir.glob(path.to_s).reject do |file|
          content = File.read(file)
          matches = DefinitionMatcher.run(content)
          matches.empty?
        end

        results.flat_map do |result|
          Pathname.new(result).relative_path_from(Pathname.new(Ordit.root)).to_s
        end
      end
    end
  end
end
