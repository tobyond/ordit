# frozen_string_literal: true

require "test_helper"

class FileFinderTest < OrditTest
  def test_finds_controllers
    create_controller_file("toggle")
    create_controller_file("users/name")
    create_controller_file("products/form")

    result = Ordit::FileFinder.run
    assert_includes result, "toggle_controller.js"
    assert_includes result, "users/name_controller.js"
    assert_includes result, "products/form_controller.js"
  end

  def test_finds_specific_controllers
    create_controller_file("toggle")
    create_controller_file("users/name")
    create_controller_file("products/form")

    result = Ordit::FileFinder.run('users/name_controller.js')
    assert_equal "users/name_controller.js", result
  end

  def test_returns_nil_if_no_result
    result = Ordit::FileFinder.run
    assert_empty result
  end

  def test_returns_nil_if_no_result_with_name
    result = Ordit::FileFinder.run('users/name_controller.js')
    assert_nil result
  end
end
