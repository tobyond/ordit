# frozen_string_literal: true

require "test_helper"

class ViewParserTest < OrditTest
  def test_finds_in_plain_html
    str = <<-ERB
      <div data-controller="payment"></div>
    ERB

    matches = Ordit::ViewParser.matches(str)
    assert_equal matches, ["payment"]
  end

  def test_finds_in_plain_erb
    str = <<-ERB
      <%= content_tag(:div, data: { controller: 'stripe paypal-checkout' }) %>
    ERB

    matches = Ordit::ViewParser.matches(str)
    assert_equal matches, %w[stripe paypal-checkout]
  end

  def test_finds_in_plain_rb
    str = <<-RUBY
      div id: 'paypments', data: { turbo: false, controller: 'stripe paypal-checkout' }) do
        'woo'
      end
    RUBY

    matches = Ordit::ViewParser.matches(str)
    assert_equal matches, %w[stripe paypal-checkout]
  end

  def test_finds_in_plain_rb_hash_rocket
    str = <<-RUBY
      div 'id' => 'paypments', 'data' => { 'turbo' => false, 'controller' => 'stripe paypal-checkout' }) do
        'woo'
      end
    RUBY

    matches = Ordit::ViewParser.matches(str)
    assert_equal matches, %w[stripe paypal-checkout]
  end

  def test_finds_in_complex_data_attributes_erb
    str = <<-ERB
      <%= content_tag(:div,
            data: {
              turbo: 'false',
              controller: 'stripe paypal-checkout modal',
              action: 'click->modal#open'
            }) %>
      <%= content_tag(:div,
            data: {
              turbo: 'false',
              controller: 'woo hoo-show',
              action: 'click->modal#open'
            }) %>
    ERB

    matches = Ordit::ViewParser.matches(str)
    assert_equal matches, %w[stripe paypal-checkout modal woo hoo-show]
  end

  def test_finds_in_complex_data_attributes_html
    str = <<-HTML
      <div
        id="payment"
        data-action="do#that"
        data-controller="stripe paypal internal--checkout-viewer">
    HTML

    matches = Ordit::ViewParser.matches(str)
    assert_equal matches, ["stripe", "paypal", "internal--checkout-viewer"]
  end
end
