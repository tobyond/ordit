module Ordit
  class ResultGenerator
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
