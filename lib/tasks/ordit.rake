# frozen_string_literal: true

namespace :ordit do
  desc "Audit Stimulus controllers usage and find orphaned controllers"
  task stimulus: :environment do
    Ordit::ConsoleOutput.run
  end

  desc "Scan files for stimulus controller usage (e.g., rake audit:scan[products])"
  task :scan, [:controller] => :environment do |_, args|
    controller = args[:controller]

    if controller.nil? || controller.empty?
      puts "Please provide a controller name: rake ordit:scan[controller_name]"
      next
    end

    Ordit::ConsoleOutput.run(controller)
  end
end
