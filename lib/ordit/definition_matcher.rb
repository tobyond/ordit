# frozen_string_literal: true

module Ordit
  class DefinitionMatcher
    # Match data-controller in HTML attributes
    HTML_PATTERN = /data-controller=["']([^"']+)["']/.freeze
    # Match controller: in Ruby/ERB
    RUBY_PATTERN = /controller:\s*['"]([^'"]+)['"]/.freeze
    # Match 'controller' => in Ruby/ERB
    HASH_ROCKET_PATTERN = /'controller'\s*=>\s*['"]([^'"]+)['"]/.freeze

    ALL_REGEX = [HTML_PATTERN, RUBY_PATTERN, HASH_ROCKET_PATTERN].freeze

    def self.run(str)
      ALL_REGEX.each_with_object(Set.new) do |pattern, controllers|
        matches = str.scan(pattern)
        next if matches.empty? || matches.nil?

        flattened_matches = matches.flatten.flat_map(&:split)
        controllers.merge(flattened_matches)
      end.to_a
    end
  end
end
