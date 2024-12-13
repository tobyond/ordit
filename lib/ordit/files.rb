# frozen_string_literal: true

module Ordit
  class Files
    def self.all
      run
    end

    def self.find(name)
      controller = name.end_with?('_controller') ? name : "#{name}_controller"
      run(controller)
    end

    def self.run(name = nil)
      Ordit.configuration.controller_paths.flat_map do |path_pattern|
        base_dir = path_pattern.split("/*").first

        # Adjust the pattern based on whether we're looking for a specific file
        pattern =
          if name
            name_without_ext = name.sub(/\.(js|ts)$/, "")
            File.join(base_dir, "#{name_without_ext}.{js,ts}")
          else
            path_pattern
          end

        Dir.glob(pattern).select do |file|
          # Only filter by controller pattern if we're finding all files
          name || file.match?(%r{[^/]*_?controller\.(js|ts)$})
        end.map do |file|
          Pathname.new(file).relative_path_from(Pathname.new(base_dir)).to_s
        end
      end.uniq
    end
  end
end
