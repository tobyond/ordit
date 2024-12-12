# frozen_string_literal: true

module Ordit
  class Scanner
    def initialize(config = Ordit.configuration)
      @config = config
    end

    def scan(controller)
      matches = find_matches(controller)
      print_results(controller, matches)
    end

    private

    def find_matches(controller)
      matches = []
      patterns = [
        /data-controller=["'](?:[^"']*\s)?#{Regexp.escape(controller)}(?:\s[^"']*)?["']/, # HTML attribute
        /data:\s*{\s*(?:controller:|:controller\s*=>)\s*["'](?:[^"']*\s)?#{Regexp.escape(controller)}(?:\s[^"']*)?["']/ # Both hash syntaxes
      ]

      @config.view_paths.each do |path|
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
      matches
    end

    def print_results(controller, matches)
      puts "\nSearching for stimulus controller: '#{controller}'\n\n"

      if matches.empty?
        puts "No matches found."
        return
      end

      current_file = nil
      matches.each do |match|
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
