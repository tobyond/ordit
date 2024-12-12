# frozen_string_literal: true

require "test_helper"

class ScannerTest < OrditTest
  def test_scans_for_controller_html_syntax
    create_view_file("users/index.html.erb", <<-HTML)
      <div data-controller="toggle"></div>
      <div data-controller="other"></div>
    HTML

    scanner = Ordit::Scanner.new
    matches = scanner.send(:find_matches, "toggle")

    assert_equal 1, matches.length
    assert_match(/toggle/, matches.first[:content])
  end

  def test_scans_for_namespaced_controller
    create_view_file("users/form.html.erb", <<-HTML)
      <div data-controller="users--name"></div>
    HTML

    scanner = Ordit::Scanner.new
    matches = scanner.send(:find_matches, "users--name")

    assert_equal 1, matches.length
    assert_match(/users--name/, matches.first[:content])
  end

  def test_scans_for_controller_ruby_hash_syntax
    create_view_file("products/form.html.erb", <<-ERB)
      <%= f.submit 'Save', data: { controller: 'products--form' } %>
    ERB

    scanner = Ordit::Scanner.new
    matches = scanner.send(:find_matches, "products--form")

    assert_equal 1, matches.length
    assert_match(/products--form/, matches.first[:content])
  end

  def test_scans_for_controller_hash_rocket_syntax
    create_view_file("users/edit.html.erb", <<-ERB)
      <%= f.submit 'Update', data: { :controller => 'users--name' } %>
    ERB

    scanner = Ordit::Scanner.new
    matches = scanner.send(:find_matches, "users--name")

    assert_equal 1, matches.length
    assert_match(/users--name/, matches.first[:content])
  end

  def test_handles_multiple_controllers_in_attribute
    create_view_file("shared/modal.html.erb", <<-HTML)
      <div data-controller="modal users--name toggle"></div>
    HTML

    scanner = Ordit::Scanner.new
    matches = scanner.send(:find_matches, "users--name")

    assert_equal 1, matches.length
    assert_match(/users--name/, matches.first[:content])
  end
end
