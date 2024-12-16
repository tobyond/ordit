# frozen_string_literal: true

require "test_helper"

class FilesTest < OrditTest
  def test_finds_controllers
    create_controller_file("toggle")
    create_controller_file("users/name")
    create_controller_file("products/form")

    result = Ordit::Files.run
    assert_includes result, "toggle_controller.js"
    assert_includes result, "users/name_controller.js"
    assert_includes result, "products/form_controller.js"
  end

  def test_returns_nil_if_no_result
    result = Ordit::Files.run
    assert_empty result
  end
end
