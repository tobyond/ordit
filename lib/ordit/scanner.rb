# frozen_string_literal: true

module Ordit
  class Scanner
    def self.run(controller)
      new(controller).run
    end

    attr_reader :controller

    def initialize(controller)
      @controller = controller
    end

    def run
      print
    end

    def results
      config.view_paths.each_with_object([]) do |path, matches|
        Dir.glob(path.to_s).each do |file|
          content = File.readlines(file)
          content.each_with_index do |line, index|
            next unless patterns.any? { |pattern| line.match?(pattern) }

            matches << {
              file: Pathname.new(file).relative_path_from(Pathname.new(Dir.pwd)),
              line_number: index + 1,
              content: line.strip
            }
          end
        end
      end
    end

    private

    def config
      @config ||= Ordit.configuration
    end

    def patterns
      @patterns ||= [
        /data-controller=["'](?:[^"']*\s)?#{Regexp.escape(controller)}(?:\s[^"']*)?["']/, # HTML attribute
        /data:\s*{\s*(?:controller:|:controller\s*=>)\s*["'](?:[^"']*\s)?#{Regexp.escape(controller)}(?:\s[^"']*)?["']/ # Both hash syntaxes
      ]
    end

    def print
      puts "\nSearching for stimulus controller: '#{controller}'\n\n"

      if results.empty?
        puts "No matches found."
        return
      end

      current_file = nil
      results.each do |match|
        if current_file != match[:file]
          puts "📁 #{match[:file]}"
          current_file = match[:file]
        end
        puts "   Line #{match[:line_number]}:"
        puts "      #{match[:content]}\n\n"
      end
    end
  end
end
