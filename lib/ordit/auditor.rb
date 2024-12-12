# frozen_string_literal: true

module Ordit
  class Auditor
    def self.run
      new.run
    end

    def run
      ResultGenerator.new(
        defined_controllers:,
        used_controllers:,
        controller_locations:,
        usage_locations:
      )
    end

    private

    def config
      @config ||= Ordit.configuration
    end

    def defined_controllers
      config.controller_paths.each_with_object(Set.new) do |path, controllers|
        Dir.glob(path.to_s).each do |file|
          # Extract relative path from controllers directory
          full_path = Pathname.new(file)
          controllers_dir = full_path.each_filename.find_index("controllers")

          next unless controllers_dir

          # Get path components after 'controllers'
          controller_path = full_path.each_filename.to_a[(controllers_dir + 1)..]
          next unless controller_path[-1].include?('_controller')

          # Remove _controller.js from the last component
          controller_path[-1] = controller_path[-1].sub(/_controller\.(js|ts)$/, "")
          # Join with -- for namespacing and convert underscores to hyphens
          name = controller_path.join("--").gsub("_", "-")
          controllers << name
        end
      end
    end

    def used_controllers
      config.view_paths.each_with_object(Set.new) do |path, controllers|
        Dir.glob(path.to_s).each do |file|
          content = File.read(file)
          patterns.each do |pattern|
            content.scan(pattern) do |match|
              # Split in case of multiple controllers
              match[0].split(/\s+/).each do |controller|
                # Store controller names exactly as they appear in the view
                # (they should already have hyphens as per Stimulus conventions)
                controllers << controller
              end
            end
          end
        end
      end
    end

    def controller_locations
      config.controller_paths.each_with_object({}) do |path_pattern, locations|
        Dir.glob(path_pattern).each do |file|
          relative_path = Pathname.new(file).relative_path_from(Dir.pwd)
          controller_path = relative_path.to_s.gsub(%r{^app/javascript/controllers/|_controller\.(js|ts)$}, "")
          name = controller_path.gsub("/", "--")
          locations[name] = relative_path
        end
      end
    end

    def usage_locations
      config.view_paths.each_with_object(Hash.new { |h, k| h[k] = {} }) do |path_pattern, locations|
        Dir.glob(path_pattern).each do |file|
          File.readlines(file).each_with_index do |line, index|
            patterns.each do |pattern|
              line.scan(pattern) do |match|
                match[0].split(/\s+/).each do |controller|
                  relative_path = Pathname.new(file).relative_path_from(Dir.pwd)
                  locations[controller][relative_path] ||= []
                  locations[controller][relative_path] << index + 1
                end
              end
            end
          end
        end
      end
    end

    def patterns
      @patterns ||= [
        /data-controller=["']([^"']+)["']/, # HTML attribute syntax
        # Ruby 1.9+ hash syntax - covers both with and without symbol prefix
        /data:\s*{(?:[^}]*\s)?(?::)?controller:\s*["']([^"']+)["']/,
        # Hash rocket syntax - covers both with and without symbol prefix
        /data:\s*{(?:[^}]*\s)?(?::)?controller\s*=>\s*["']([^"']+)["']/
      ]
    end
  end
end
