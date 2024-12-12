# frozen_string_literal: true

module Ordit
  class Auditor
    def initialize(config = Ordit.configuration)
      @config = config
    end

    def audit
      defined_controllers = find_defined_controllers
      used_controllers = find_used_controllers

      AuditResult.new(
        defined_controllers: defined_controllers,
        used_controllers: used_controllers,
        controller_locations: find_controller_locations,
        usage_locations: find_usage_locations
      )
    end

    private

    def find_defined_controllers
      controllers = Set.new
      @config.controller_paths.each do |path|
        Dir.glob(path.to_s).each do |file|
          # Extract relative path from controllers directory
          full_path = Pathname.new(file)
          controllers_dir = full_path.each_filename.find_index("controllers")

          next unless controllers_dir

          # Get path components after 'controllers'
          controller_path = full_path.each_filename.to_a[(controllers_dir + 1)..]
          # Remove _controller.js from the last component
          controller_path[-1] = controller_path[-1].sub(/_controller\.(js|ts)$/, "")
          # Join with -- for namespacing and convert underscores to hyphens
          name = controller_path.join("--").gsub("_", "-")
          controllers << name
        end
      end
      controllers
    end

    def find_used_controllers
      controllers = Set.new
      patterns = [
        /data-controller=["']([^"']+)["']/, # HTML attribute syntax
        /data:\s*{\s*(?:controller:|:controller\s*=>)\s*["']([^"']+)["']/ # Both hash syntaxes
      ]

      @config.view_paths.each do |path|
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
      controllers
    end

    def find_controller_locations
      locations = {}
      @config.controller_paths.each do |path_pattern|
        Dir.glob(path_pattern).each do |file|
          relative_path = Pathname.new(file).relative_path_from(Dir.pwd)
          controller_path = relative_path.to_s.gsub(%r{^app/javascript/controllers/|_controller\.(js|ts)$}, "")
          name = controller_path.gsub("/", "--")
          locations[name] = relative_path
        end
      end
      locations
    end

    def find_usage_locations
      locations = Hash.new { |h, k| h[k] = {} }
      patterns = [
        /data-controller=["']([^"']+)["']/,
        /data:\s*{(?:[^}]*\s)?controller:\s*["']([^"']+)["']/,
        /data:\s*{(?:[^}]*\s)?controller\s*=>\s*["']([^"']+)["']/
      ]

      @config.view_paths.each do |path_pattern|
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
      locations
    end
  end

  class AuditResult
    attr_reader :defined_controllers, :used_controllers,
                :controller_locations, :usage_locations

    def initialize(defined_controllers:, used_controllers:,
                   controller_locations:, usage_locations:)
      @defined_controllers = defined_controllers
      @used_controllers = used_controllers
      @controller_locations = controller_locations
      @usage_locations = usage_locations
    end

    def unused_controllers
      defined_controllers - used_controllers
    end

    def undefined_controllers
      used_controllers - defined_controllers
    end

    def active_controllers
      defined_controllers & used_controllers
    end

    def to_console
      puts "\n📊 Stimulus Controller Audit\n"

      if unused_controllers.any?
        puts "\n❌ Defined but unused controllers:"
        unused_controllers.sort.each do |controller|
          puts "   #{controller}"
          puts "   └─ #{controller_locations[controller]}"
        end
      end

      if undefined_controllers.any?
        puts "\n⚠️  Used but undefined controllers:"
        undefined_controllers.sort.each do |controller|
          puts "   #{controller}"
          usage_locations[controller].each do |file, lines|
            puts "   └─ #{file} (lines: #{lines.join(", ")})"
          end
        end
      end

      if active_controllers.any?
        puts "\n✅ Active controllers:"
        active_controllers.sort.each do |controller|
          puts "   #{controller}"
          puts "   └─ Defined in: #{controller_locations[controller]}"
          puts "   └─ Used in:"
          usage_locations[controller].each do |file, lines|
            puts "      └─ #{file} (lines: #{lines.join(", ")})"
          end
        end
      end

      puts "\n📈 Summary:"
      puts "   Total controllers defined: #{defined_controllers.size}"
      puts "   Total controllers in use:  #{used_controllers.size}"
      puts "   Unused controllers:        #{unused_controllers.size}"
      puts "   Undefined controllers:     #{undefined_controllers.size}"
      puts "   Properly paired:           #{active_controllers.size}"
    end
  end
end
