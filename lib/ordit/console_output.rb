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
      return print_scan if @name

      print_audit
    end

    def print_audit
      puts "\n📊 Stimulus Controller Audit\n"

      if unused_controllers.any?
        puts "\n❌ Defined but unused controllers:"
        unused_controllers.sort.each do |controller|
          puts "   #{controller}"
        end
      end

      if undefined_controllers.any?
        puts "\n⚠️  Used but undefined controllers:"
        undefined_controllers.sort.each do |controller|
          puts "   #{controller}"
        end
      end

      if active_controllers.any?
        puts "\n✅ Active controllers:"
        active_controllers.sort.each do |controller|
          puts "   #{controller}"
        end
      end

      puts "\n📈 Summary:"
      puts "   Total controllers defined: #{files.size}"
      puts "   Total controllers in use:  #{active_controllers.size}"
      puts "   Unused controllers:        #{unused_controllers.size}"
      puts "   Undefined controllers:     #{undefined_controllers.size}"
    end

    def print_scan
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
