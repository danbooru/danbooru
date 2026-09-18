require "test_helper"

class DtextInputTest < ViewComponent::TestCase
  context "The DtextInput" do
    should "render a character counter, computing the max from the model's length validator, since simple_form's own maxlength calculation is opt-in in this app" do
      html = nil

      vc_test_view_context.simple_form_for(build(:post_flag, reason: "xxx"), url: "/post_flags") do |form|
        html = form.input(:reason, as: :dtext, inline: true)
      end

      assert_match(/dtext-input-counter-text/, html)
      assert_match(">3/140<", html)
    end

    should "not render a character counter when the model has no length validator" do
      html = nil

      vc_test_view_context.simple_form_for(build(:moderation_report, reason: "xxx"), url: "/moderation_reports") do |form|
        html = form.input(:reason, as: :dtext, inline: true)
      end

      assert_no_match(/dtext-input-counter-text/, html)
    end

    should "not set an html maxlength attribute, so pasted text isn't silently truncated" do
      html = nil

      vc_test_view_context.simple_form_for(build(:post_flag, reason: "xxx"), url: "/post_flags") do |form|
        html = form.input(:reason, as: :dtext, inline: true)
      end

      assert_no_match(/\smaxlength="/, html)
    end

    should "put the counter and label on the wrapper div, opposite each other above the input, like the tag editor's counter" do
      html = nil

      vc_test_view_context.simple_form_for(build(:post_flag, reason: "xxx"), url: "/post_flags") do |form|
        html = form.input(:reason, as: :dtext, inline: true)
      end

      assert_match(/class="[^"]*dtext-input-counter-wrapper[^"]*"[^>]*x-data="\{ length: 3 \}"/, html)
      # the label, then the counter, then the input, so the wrapper's flexbox lays them out as
      # label (top-left) / counter (top-right) / input (full width, wrapping to its own row).
      assert_match(/<label.*<span class="dtext-input-counter-text.*<input/m, html)
    end

    should "render a character counter for multiline (non-inline) dtext fields too, once near the max length" do
      html = nil

      vc_test_view_context.simple_form_for(build(:comment, body: "x" * 12_000), url: "/comments") do |form|
        html = form.input(:body, as: :dtext)
      end

      assert_match(/dtext-input-counter-text/, html)
      assert_match(">12000/15000<", html)
      assert_no_match(/\smaxlength="/, html)
    end

    should "gate the multiline counter's visibility on x-show/x-cloak, never a plain [hidden] attribute" do
      html = nil

      vc_test_view_context.simple_form_for(build(:comment, body: "xxx"), url: "/comments") do |form|
        html = form.input(:body, as: :dtext)
      end

      # A plain `hidden` attribute would stick forever, since Alpine's x-show only ever toggles
      # inline `style.display` and this app's CSS hides `[hidden]` with `!important`.
      assert_no_match(/\shidden[\s>]/, html)
      assert_match(%r{dtext-input-counter-text.*?x-cloak.*?>3/15000<}m, html)
    end
  end
end
