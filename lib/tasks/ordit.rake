# frozen_string_literal: true

namespace :audit do
  desc "Audit Stimulus controllers usage and find orphaned controllers"
  task stimulus: :environment do
    StimulusAudit::Auditor.new.audit.to_console
  end

  desc "Scan files for stimulus controller usage (e.g., rake audit:scan[products])"
  task :scan, [:controller] => :environment do |_, args|
    controller = args[:controller]

    if controller.nil? || controller.empty?
      puts "Please provide a controller name: rake audit:scan[controller_name]"
      next
    end

    StimulusAudit::Scanner.new.scan(controller)
  end
end
