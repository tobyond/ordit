# frozen_string_literal: true

require "test_helper"

class ScannerTest < OrditTest
  def test_scans_for_controller_html_syntax
    create_view_file("users/index.html.erb", <<-HTML)
      <div data-controller="toggle"></div>
      <div data-controller="other"></div>
    HTML

    scanner = Ordit::Scanner.new('toggle')
    matches = scanner.results

    assert_equal 1, matches.length
    assert_match(/toggle/, matches.first[:content])
  end

  def test_scans_for_namespaced_controller
    create_view_file("users/form.html.erb", <<-HTML)
      <div data-controller="users--name"></div>
    HTML

    scanner = Ordit::Scanner.new('users--name')
    matches = scanner.results

    assert_equal 1, matches.length
    assert_match(/users--name/, matches.first[:content])
  end

  def test_scans_for_controller_ruby_hash_syntax
    create_view_file("products/form.html.erb", <<-ERB)
      <%= f.submit 'Save', data: { controller: 'products--form' } %>
    ERB

    scanner = Ordit::Scanner.new('products--form')
    matches = scanner.results

    assert_equal 1, matches.length
    assert_match(/products--form/, matches.first[:content])
  end

  def test_scans_for_controller_hash_rocket_syntax
    create_view_file("users/edit.html.erb", <<-ERB)
      <%= f.submit 'Update', data: { :controller => 'users--name' } %>
    ERB

    scanner = Ordit::Scanner.new('users--name')
    matches = scanner.results

    assert_equal 1, matches.length
    assert_match(/users--name/, matches.first[:content])
  end

  def test_handles_multiple_controllers_in_attribute
    create_view_file("shared/modal.html.erb", <<-HTML)
      <div data-controller="modal users--name toggle"></div>
    HTML

    scanner = Ordit::Scanner.new('users--name')
    matches = scanner.results

    assert_equal 1, matches.length
    assert_match(/users--name/, matches.first[:content])
  end

  def test_ignores_matches_in_controller_files
    # Create a controller file with a comment mentioning the controller
    create_controller_file('payment', <<-JS)
      // Connects to data-controller="payment"
      export default class extends Controller {
      }
    JS

    # Create a view file using the controller
    create_view_file('payments/index.html.erb', <<-ERB)
      <div data-controller="payment"></div>
    ERB

    scanner = Ordit::Scanner.new('payment')
    matches = scanner.results
    
    # Should only find the view file, not the controller file
    assert_equal 1, matches.length
    assert_includes matches.first[:file].to_s, 'payments/index.html.erb'
  end

  def test_finds_controller_in_space_separated_list
    create_view_file('payments/form.html.erb', <<-ERB)
      <%= content_tag(:div, data: { controller: 'stripe paypal-checkout' }) %>
    ERB

    stripe_matches = Ordit::Scanner.new('stripe').results
    
    assert_equal 1, stripe_matches.length
    
    # Should find 'paypal-checkout'
    paypal_matches = Ordit::Scanner.new('paypal-checkout').results
    assert_equal 1, paypal_matches.length
  end

  def test_finds_controller_in_complex_data_attributes
    create_view_file('payments/show.html.erb', <<-ERB)
      <%= content_tag(:div,
            data: {
              turbo: 'false',
              controller: 'stripe paypal-checkout modal',
              action: 'click->modal#open'
            }) %>
    ERB

    # Should find each controller
    ['stripe', 'paypal-checkout', 'modal'].each do |controller|
      matches = Ordit::Scanner.new(controller).results

      assert_equal 1, matches.length, "Should find controller: #{controller}"
    end
  end
end
