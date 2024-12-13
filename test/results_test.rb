# frozen_string_literal: true

require "test_helper"

class ResultsTest < OrditTest
  def test_finds_defined_controllers
    view = %w[
      addresses
      analytics
      ar-modal
      all-buttons
      cart
      collection-drop
      products--collections
      internal--click-for-confirmation
      missing
    ].each_with_object(String.new) do |definition, s|
      s << <<-HTML
        <div data-controller="#{definition}"></div>
      HTML
    end
    create_view_file("users/index.html", view)

    %w[
      addresses
      analytics
      ar_modal
      all_buttons
      cart
      collection_drop
      products/collections
      internal/click_for_confirmation
      not_defined
    ].each do |controller|
      create_controller_file(controller)
    end

    result = Ordit::Results.new.to_h
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

  def test_finds_specific_controller
    view = %w[
      addresses
      analytics
      ar-modal
      all-buttons
      cart
      collection-drop
      products--collections
      internal--click-for-confirmation
      missing
    ].each_with_object(String.new) do |definition, s|
      s << <<-HTML
        <div data-controller="#{definition}"></div>
      HTML
    end
    create_view_file("users/index.html", view)

    %w[
      addresses
      analytics
      ar_modal
      all_buttons
      cart
      collection_drop
      products/collections
      internal/click_for_confirmation
      not_defined
    ].each do |controller|
      create_controller_file(controller)
    end

    result = Ordit::Results.new("addresses").files
    binding.irb

    assert_equal result, ["addresses_controller.js"]
  end
end
