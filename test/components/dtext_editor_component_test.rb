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

    should "show the character counter for inline dtext fields with a max length" do
      vc_test_view_context.simple_form_for(build(:post_flag, reason: "xxx"), url: "/post_flags") do |form|
        render_inline(DtextEditorComponent.new(input_name: :reason, form: form, input_html: { maxlength: 140 }))

        assert_no_css("input[name='post_flag[reason]'][maxlength]")
        assert_css(".dtext-input-counter-text", text: "3/140")
      end
    end

    should "not show the character counter for inline dtext fields without a max length" do
      vc_test_view_context.simple_form_for(build(:moderation_report, reason: "xxx"), url: "/moderation_reports") do |form|
        render_inline(DtextEditorComponent.new(input_name: :reason, form: form))

        assert_css("input[name='moderation_report[reason]']")
        assert_no_css(".dtext-input-counter-text")
      end
    end

    should "show the character counter for multiline dtext fields once near the max length" do
      vc_test_view_context.simple_form_for(build(:comment, body: "x" * 12_000), url: "/comments") do |form|
        render_inline(DtextEditorComponent.new(input_name: :body, form: form, input_html: { maxlength: 15_000 }))

        assert_no_css("textarea[name='comment[body]'][maxlength]")
        assert_css(".dtext-editor-menu .dtext-input-counter-text", text: "12000/15000")
      end
    end

    should "not show the character counter for multiline dtext fields without a max length" do
      vc_test_view_context.simple_form_for(build(:pool_version), url: "/pool_versions") do |form|
        render_inline(DtextEditorComponent.new(input_name: :description, form: form))

        assert_no_css(".dtext-input-counter-text")
      end
    end
  end
end
