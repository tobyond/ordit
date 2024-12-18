# frozen_string_literal: true

namespace :ordit do
  desc "Audit Stimulus controllers usage and find orphaned controllers"
  task stimulus: :environment do
    Ordit::ConsoleOutput.run
  end
end
