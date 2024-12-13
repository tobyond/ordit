# frozen_string_literal: true

require "test_helper"

class DefinitionMatcherTest < OrditTest
  def test_finds_defined_controllers
    definitions = %w[
      addresses
      analytics
      ar-modal
      all-buttons
      cart
      collection-drop
      products--collections
      internal--click-for-confirmation
      missing
    ]

    files = %w[
      addresses_controller.js
      analytics_controller.js
      ar_modal_controller.js
      all_buttons_controller.js
      cart_controller.js
      collection_drop_controller.js
      products/collections_controller.js
      internal/click_for_confirmation_controller.js
      not_defined_controller.js
    ]

    result = Ordit::DefinitionMatcher.run(definitions, files)
    expected_result = {
      active_controllers: [
        "addresses_controller.js",
        "analytics_controller.js",
        "ar_modal_controller.js",
        "all_buttons_controller.js",
        "cart_controller.js",
        "collection_drop_controller.js",
        "products/collections_controller.js",
        "internal/click_for_confirmation_controller.js"
      ],
      undefined_controllers: ["missing"],
      unused_controllers: ["not_defined_controller.js"]
    }

    assert_equal result, expected_result
  end
end
