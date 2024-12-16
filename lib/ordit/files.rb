# frozen_string_literal: true

module Ordit
  class Files
    def self.all
      run
    end

    def self.run
      Ordit.configuration.controller_paths.flat_map do |path_pattern|
        base_dir = path_pattern.split("/*").first
        
        Dir.glob(path_pattern).select do |file|
          # Only filter by controller pattern if we're finding all files
          file.match?(%r{[^/]*_?controller\.(js|ts)$})
        end.map do |file|
          Pathname.new(file).relative_path_from(Pathname.new(base_dir)).to_s
        end
      end.uniq
    end
  end
end
