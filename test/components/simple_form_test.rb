require "test_helper"

class SimpleFormTest < ViewComponent::TestCase
  delegate :simple_form_for, to: :vc_test_view_context

  context "simple_form_for" do
    context "with string inputs" do
      should "add the expected classes to the <input>" do
        html = simple_form_for(:search, url: "/posts") do |form|
          form.input(:tags, as: :string, input_html: { class: "custom-class" })
        end

        input = Nokogiri::HTML5.fragment(html).at_css("input[name='search[tags]']")

        assert_equal("w-full max-w-360px string required custom-class", input[:class])
      end
    end

    context "with boolean inputs" do
      should "add the toggle-switch class to the <input>" do
        html = simple_form_for(:post, url: "/posts") do |form|
          form.input(:is_pending, as: :boolean)
        end

        input = Nokogiri::HTML5.fragment(html).at_css("input[type='checkbox'][name='post[is_pending]']")

        assert_equal("toggle-switch boolean optional", input[:class])
      end
    end
  end
end
