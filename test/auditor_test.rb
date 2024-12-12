# frozen_string_literal: true

require "test_helper"

class AuditorTest < OrditTest
  def test_finds_defined_controllers
    create_controller_file("toggle")
    create_controller_file("users/name")
    create_controller_file("products/form")

    result = Ordit::Auditor.run
    assert_includes result.defined_controllers, "toggle"
    assert_includes result.defined_controllers, "users--name"
    assert_includes result.defined_controllers, "products--form"
  end

  def test_finds_used_controllers_html_syntax
    create_view_file("users/index.html.erb", <<-HTML)
      <div data-controller="toggle"></div>
      <div data-controller="users--name"></div>
    HTML

    result = Ordit::Auditor.run
    assert_includes result.used_controllers, "toggle"
    assert_includes result.used_controllers, "users--name"
  end

  def test_finds_used_controllers_ruby_hash_syntax
    create_view_file("products/form.html.erb", <<-ERB)
      <%= form_for @product do |f| %>
        <%= f.submit 'Save', data: { controller: 'products--form' } %>
      <% end %>
    ERB

    result = Ordit::Auditor.run
    assert_includes result.used_controllers, "products--form"
  end

  def test_finds_used_controllers_hash_rocket_syntax
    create_view_file("users/edit.html.erb", <<-ERB)
      <%= form_for @user do |f| %>
        <%= f.submit 'Update', data: { :controller => 'users--name' } %>
      <% end %>
    ERB

    result = Ordit::Auditor.run
    assert_includes result.used_controllers, "users--name"
  end

  def test_identifies_unused_controllers
    create_controller_file("unused")
    create_view_file("users/index.html.erb", '<div data-controller="used"></div>')

    result = Ordit::Auditor.run
    assert_includes result.unused_controllers, "unused"
    refute_includes result.unused_controllers, "used"
  end

  def test_identifies_undefined_controllers
    create_controller_file("defined")
    create_view_file("users/index.html.erb", '<div data-controller="undefined"></div>')

    result = Ordit::Auditor.run
    assert_includes result.undefined_controllers, "undefined"
    refute_includes result.undefined_controllers, "defined"
  end

  def test_handles_underscore_to_hyphen_conversion
    create_controller_file("date_format")
    create_view_file("users/profile.html.erb", '<div data-controller="date-format"></div>')

    result = Ordit::Auditor.run
    assert_includes result.defined_controllers, "date-format"
    assert_includes result.used_controllers, "date-format"
    assert_includes result.active_controllers, "date-format"
  end

  def test_handles_namespaced_controllers_with_underscores
    create_controller_file("users/profile_card")
    create_view_file("users/show.html.erb", '<div data-controller="users--profile-card"></div>')

    result = Ordit::Auditor.run
    assert_includes result.defined_controllers, "users--profile-card"
    assert_includes result.used_controllers, "users--profile-card"
    assert_includes result.active_controllers, "users--profile-card"
  end

  def test_excludes_application_js
    create_plain_file("application")

    result = Ordit::Auditor.run
    assert_equal result.defined_controllers.size, 0
  end
end
