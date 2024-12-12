# frozen_string_literal: true

gem "minitest" # Ensure we're using the gem version
require "minitest/autorun"
require "bundler/setup"
require "fileutils"
require "pathname"

# Define test root before requiring ordit
TEST_ROOT = Pathname.new(File.expand_path("tmp", __dir__))

require "ordit"

# Base test class without Rails
class OrditTest < Minitest::Test
  def setup
    @temp_dir = TEST_ROOT.join("ordit_test")
    cleanup_test_directories
    setup_test_directories
    configure_ordit
  end

  def teardown
    cleanup_test_directories
  end

  private

  def setup_test_directories
    FileUtils.mkdir_p(@temp_dir)

    [
      "app/views/users",
      "app/views/products",
      "app/components/shared",
      "app/javascript/controllers/users",
      "app/javascript/controllers/products"
    ].each do |dir|
      FileUtils.mkdir_p(@temp_dir.join(dir))
    end
  end

  def configure_ordit
    Ordit.configure do |config|
      config.view_paths = [
        @temp_dir.join("app/views/**/*.{html,erb}").to_s,
        @temp_dir.join("app/components/**/*.{html,erb}").to_s
      ]
      config.controller_paths = [
        @temp_dir.join("app/javascript/controllers/**/*.{js}").to_s
      ]
    end
  end

  def cleanup_test_directories
    FileUtils.rm_rf(@temp_dir) if @temp_dir && File.exist?(@temp_dir)
  end

  def create_controller_file(name, content = "")
    parts = name.split("/")
    filename = parts.pop
    controller_dir = @temp_dir.join("app/javascript/controllers", *parts)
    FileUtils.mkdir_p(controller_dir)
    path = controller_dir.join("#{filename}_controller.js")
    File.write(path, content || "")
  end

  def create_view_file(name, content)
    parts = name.split("/")
    filename = parts.pop
    view_dir = @temp_dir.join("app/views", *parts)
    FileUtils.mkdir_p(view_dir)
    path = view_dir.join(filename)
    File.write(path, content)
  end

  def create_component_file(name, content)
    parts = name.split("/")
    filename = parts.pop
    component_dir = @temp_dir.join("app/components", *parts)
    FileUtils.mkdir_p(component_dir)
    path = component_dir.join(filename)
    File.write(path, content)
  end
end
