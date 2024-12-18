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
    create_view_file("users/index.html.erb", view)
    create_view_file("products/show.html.erb", '<div data-controller="cart"></div>')
    create_view_file("posts/edit.html.erb", '<div data-controller="missing"></div>')
    create_view_file("users/edit.html.erb", '<div data-controller="tooltips"></div>')
    create_view_file("admin/new.html.erb", '<div data-controller="addresses"></div>')

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
      ].sort,
      undefined_controllers: {
        "missing" => [
          "test/tmp/ordit_test/app/views/posts/edit.html.erb",
          "test/tmp/ordit_test/app/views/users/index.html.erb"
        ],
        "tooltips" => ["test/tmp/ordit_test/app/views/users/edit.html.erb"]
      },
      unused_controllers: ["not_defined_controller.js"]
    }

    assert_equal result, expected_result
  end

  def test_finds_unused_controllers
    create_controller_file("toggle")
    create_controller_file("users/name")
    create_controller_file("products/form")

    result = Ordit::Results.new
    assert_includes result.unused_controllers, "toggle_controller.js"
    assert_includes result.unused_controllers, "users/name_controller.js"
    assert_includes result.unused_controllers, "products/form_controller.js"
  end

  def test_finds_undefined_controllers_html_syntax
    create_view_file("users/index.html.erb", <<-HTML)
      <div data-controller="toggle"></div>
      <div data-controller="users--name"></div>
    HTML

    result = Ordit::Results.new
    expected_result = {
      "toggle" => ["test/tmp/ordit_test/app/views/users/index.html.erb"],
      "users--name" => ["test/tmp/ordit_test/app/views/users/index.html.erb"]
    }
    assert_equal result.undefined_controllers, expected_result
  end

  def test_finds_undefined_controllers_ruby_hash_syntax
    create_view_file("products/form.html.erb", <<-ERB)
      <%= form_for @product do |f| %>
        <%= f.submit 'Save', data: { controller: 'products--form' } %>
      <% end %>
    ERB

    result = Ordit::Results.new
    expected_result = {
      "products--form" => ["test/tmp/ordit_test/app/views/products/form.html.erb"]
    }
    assert_equal result.undefined_controllers, expected_result
  end

  def test_finds_used_controllers_hash_rocket_syntax_with_symbol_key
    create_view_file("users/edit.html.erb", <<-ERB)
      <%= form_for @user do |f| %>
        <%= f.submit 'Update', data: { :controller => 'users--name' } %>
      <% end %>
    ERB

    result = Ordit::Results.new
    expected_result = {
      "users--name" => ["test/tmp/ordit_test/app/views/users/edit.html.erb"]
    }
    assert_equal result.undefined_controllers, expected_result
  end

  def test_finds_used_controllers_hash_rocket_syntax_with_string_key
    create_view_file("users/edit.html.erb", <<-ERB)
      <%= form_for @user do |f| %>
        <%= f.submit 'Update', data: { 'controller' => 'users--name' } %>
      <% end %>
    ERB

    result = Ordit::Results.new
    expected_result = {
      "users--name" => ["test/tmp/ordit_test/app/views/users/edit.html.erb"]
    }
    assert_equal result.undefined_controllers, expected_result
  end

  def test_identifies_unused_controllers
    create_controller_file("unused")
    create_view_file("users/index.html.erb", '<div data-controller="used"></div>')

    result = Ordit::Results.new
    assert_includes result.unused_controllers, "unused_controller.js"
    refute_includes result.unused_controllers, "used_controller.js"
  end

  def test_identifies_undefined_controllers
    create_controller_file("defined")
    create_view_file("users/index.html.erb", '<div data-controller="undefined"></div>')

    result = Ordit::Results.new
    expected_result = { "undefined" => ["test/tmp/ordit_test/app/views/users/index.html.erb"] }
    assert_equal result.undefined_controllers, expected_result
  end

  def test_handles_underscore_to_hyphen_conversion
    create_controller_file("date_format")
    create_view_file("users/profile.html.erb", '<div data-controller="date-format"></div>')

    result = Ordit::Results.new
    assert_includes result.active_controllers, "date_format_controller.js"
  end

  def test_handles_namespaced_controllers_with_underscores
    create_controller_file("users/profile_card")
    create_view_file("users/show.html.erb", '<div data-controller="users--profile-card"></div>')

    result = Ordit::Results.new
    assert_includes result.active_controllers, "users/profile_card_controller.js"
  end

  def test_excludes_application_js
    create_plain_file("application")

    result = Ordit::Results.new
    assert_equal result.active_controllers.size, 0
  end
end
