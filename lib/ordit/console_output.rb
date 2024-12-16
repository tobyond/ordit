# frozen_string_literal: true

require "forwardable"

module Ordit
  class ConsoleOutput
    extend Forwardable

    def self.run(name = nil)
      new(name).run
    end

    def_delegators :@results,
                   :files, :active_controllers, :undefined_controllers, :unused_controllers

    def initialize(name = nil)
      @name = name
      @results = Results.new(name)
    end

    def run
      return print_find if @name

      print_audit
    end

    def print_audit
      puts "\n📊 Stimulus Controller Audit\n"

      if unused_controllers.any?
        puts "\n❌ Controllers not defined in any views:"
        unused_controllers.sort.each do |controller|
          puts "   #{controller}"
        end
      end

      if undefined_controllers.any?
        puts "\n⚠️ View with defined but missing controller:"
        undefined_controllers.each do |controller, files|
          puts "\n   #{controller}_controller"

          files.each_with_index do |file, index|
            puts "   #{ index.zero? ? '└─' : '  ' } 📁 #{file}"
          end
        end
      end

      puts "\n📈 Summary:"
      puts "   Total controllers defined: #{files.size}"
      puts "   Total controllers in use:  #{active_controllers.size}"
      puts "   Unused controllers:        #{unused_controllers.size}"
      puts "   Undefined controllers:     #{undefined_controllers.size}"
    end

    def print_find
      puts "\nSearching for stimulus controller: '#{@name}'\n\n"

      if files.empty?
        puts "No matches found."
        return
      end

      files.each do |file|
        puts "📁 #{file}"
      end
    end
  end
end
