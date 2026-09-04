require "test_helper"

class DtextEditorComponentTest < ViewComponent::TestCase
  context "The DtextEditorComponent" do
    should "render a textarea editor for multiline dtext fields" do
      vc_test_view_context.simple_form_for(build(:comment), url: "/comments") do |form|
        render_inline(DtextEditorComponent.new(input_name: :body, form: form))

        assert_css(".dtext-editor")
        assert_css("textarea[name='comment[body]']")
      end
    end

    should "render an input for inline dtext fields" do
      vc_test_view_context.simple_form_for(build(:ban), url: "/bans") do |form|
        render_inline(DtextEditorComponent.new(input_name: :reason, form: form))

        assert_css("input[name='ban[reason]']")
        assert_no_css(".dtext-editor")
      end
    end

    should "enable media embeds when configured" do
      vc_test_view_context.simple_form_for(build(:comment), url: "/comments") do |form|
        render_inline(DtextEditorComponent.new(input_name: :body, form: form))

        assert_css(".dtext-editor")
        assert_css("[title='Insert image']")
      end
    end
  end
end
