# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < OrditTest
  def test_default_configuration
    config = Ordit::Configuration.new
    assert_kind_of Array, config.view_paths
    assert_kind_of Array, config.controller_paths
  end

  def test_custom_configuration
    custom_paths = ["custom/views"]
    custom_controller_paths = ["custom/controllers"]

    Ordit.configure do |config|
      config.view_paths = custom_paths
      config.controller_paths = custom_controller_paths
    end

    assert_equal custom_paths, Ordit.configuration.view_paths
    assert_equal custom_controller_paths, Ordit.configuration.controller_paths
  end
end
