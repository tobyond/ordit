# frozen_string_literal: true

require "forwardable"

module Ordit
  class ConsoleOutput
    extend Forwardable

    def self.run
      new.run
    end

    def_delegators :@results,
                   :files, :active_controllers, :undefined_controllers, :unused_controllers

    def initialize
      @results = Results.new
    end

    def run
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
  end
end
