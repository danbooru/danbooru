require "application_system_test_case"

module DtextEditorTests
  extend ActiveSupport::Concern

  def click_dtext_button(title)
    selector = ".dtext-editor a[title^='#{title}']"

    all(".dtext-editor-menu .popup-menu-button").last.click unless page.has_selector?(selector, wait: 0)

    find(selector).click
  end

  def full_editor_field
    find(".new-comment textarea.dtext")
  end

  def select_dtext(start, finish)
    page.execute_script(<<~JS)
      var el = document.querySelector(".new-comment textarea.dtext");
      el.focus();
      el.setSelectionRange(#{start}, #{finish});
    JS
  end

  included do
    context "#{browser_name}:" do
      context "DText:" do
        context "the full editor" do
          setup do
            @user = create(:user, created_at: 1.month.ago)
            @post = create(:post)

            signin @user
            visit post_path(@post)
            find(".new-comment .expand-comment-response").click
          end

          should "wrap the selected word in the right markup when clicking each toolbar button" do
            {
              "Bold (Ctrl+B)" => "hello [b]world[/b]",
              "Italics (Ctrl+I)" => "hello [i]world[/i]",
              "Wiki link (Ctrl+K)" => "hello [[world]]",
              "Strikethrough (Ctrl+S)" => "hello [s]world[/s]",
              "Underline (Ctrl+U)" => "hello [u]world[/u]",
              "External link (Ctrl+L)" => 'hello "world":[https://www.example.com]',
              "Search link (Ctrl+{)" => "hello {{world}}",
              "Spoiler (Ctrl+/)" => "hello [spoiler]world[/spoiler]",
              "Expand (Ctrl+E)" => "hello \n[expand]\nworld\n[/expand]\n",
              "Quote (Ctrl+Q)" => "hello \n[quote]\nworld\n[/quote]\n",
              "Code (Ctrl+M)" => "hello \n[code]\nworld\n[/code]\n",
              "Horizontal rule" => "hello \n[hr]\nworld",
              "No formatting" => "hello \n[nodtext]\nworld\n[/nodtext]\n",
            }.each do |title, expected_markup|
              full_editor_field.set("hello world")
              select_dtext(6, 11)

              click_dtext_button(title)

              assert_equal expected_markup, full_editor_field.value, "clicking #{title} should wrap the selected word in #{expected_markup.inspect}"
            end
          end

          context "keyboard shortcuts" do
            should "wrap the selected word the same way the toolbar buttons do" do
              {
                "b" => "hello [b]world[/b]",
                "i" => "hello [i]world[/i]",
                "k" => "hello [[world]]",
                "s" => "hello [s]world[/s]",
                "u" => "hello [u]world[/u]",
                "l" => 'hello "world":[https://www.example.com]',
                # "{" => "hello {{world}}", # XXX: broken; needs shift key, which is explicitly ignored
                "/" => "hello [spoiler]world[/spoiler]",
                "e" => "hello \n[expand]\nworld\n[/expand]\n",
                "q" => "hello \n[quote]\nworld\n[/quote]\n",
                "m" => "hello \n[code]\nworld\n[/code]\n",
              }.each do |key, expected_markup|
                full_editor_field.set("hello world")
                select_dtext(6, 11)

                full_editor_field.send_keys([:control, key])

                assert_equal expected_markup, full_editor_field.value, "Ctrl+#{key} should wrap the selected word in #{expected_markup.inspect}"
              end
            end
          end

          context "the edit/preview toggle" do
            should "work" do
              full_editor_field.set("[[1girl]]")

              find(".new-comment a[title^='Preview']").click

              assert_hidden ".new-comment textarea.dtext"
              assert_selector ".new-comment .dtext-preview .dtext-wiki-link", text: "1girl"

              find(".new-comment a", text: "Edit").click

              assert_visible ".new-comment textarea.dtext"
              assert_equal "[[1girl]]", full_editor_field.value
            end
          end

          context "the length counter" do
            should "update as text is typed, and turn red past the max length" do
              full_editor_field.set("x" * 5000)
              assert_hidden ".new-comment .dtext-input-counter-text"

              full_editor_field.set("x" * 12_001)
              assert_visible ".new-comment .dtext-input-counter-text", text: "12001/15000"
              assert_no_selector ".new-comment .dtext-input-counter-text.text-error"

              full_editor_field.set("x" * 15_001)
              assert_selector ".new-comment .dtext-input-counter-text.text-error", text: "15001/15000"
            end
          end
        end

        context "the inline editor" do
          setup do
            @moderator = create(:moderator_user)

            signin @moderator
            visit new_ban_path
          end

          should "update the counter as text is typed, and turn red past the max length" do
            assert_selector ".dtext-input-counter-text", text: "0/600"
            assert_no_selector ".dtext-input-counter-text.text-error"

            fill_in "Reason", with: "x" * 500
            assert_selector ".dtext-input-counter-text", text: "500/600"
            assert_no_selector ".dtext-input-counter-text.text-error"

            fill_in "Reason", with: "x" * 601
            assert_selector ".dtext-input-counter-text.text-error", text: "601/600"
          end
        end
      end
    end
  end
end

class DtextEditorChromeTest < ChromeSystemTestCase
  include DtextEditorTests
end

class DtextEditorFirefoxTest < FirefoxSystemTestCase
  include DtextEditorTests
end

class DtextEditorWebkitTest < WebkitSystemTestCase
  include DtextEditorTests
end
