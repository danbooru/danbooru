require "application_system_test_case"

class DtextEditorChromeTest < ChromeSystemTestCase
  def click_dtext_button(title)
    selector = ".dtext-editor a[title^='#{title}']"

    all(".dtext-editor-menu .popup-menu-button").last.click unless page.has_selector?(selector, wait: 0)

    find(selector).click
  end

  def select_dtext(start, finish, selector:)
    page.execute_script(<<~JS)
      var el = document.querySelector(#{selector.to_json});
      el.focus();
      el.setSelectionRange(#{start}, #{finish});
    JS
  end

  context "DText:" do
    context "the full editor" do
      setup do
        @user = create(:user)
        @post = create(:post)

        fast_signin @user
        visit post_path(@post)
        find(".new-comment .expand-comment-response").click

        @full_editor_selector = ".new-comment textarea.dtext"
        @full_editor_field = find(@full_editor_selector)
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
          @full_editor_field.set("hello world")
          select_dtext(6, 11, selector: @full_editor_selector)

          click_dtext_button(title)

          assert_equal expected_markup, @full_editor_field.value, "clicking #{title} should wrap the selected word in #{expected_markup.inspect}"
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
            @full_editor_field.set("hello world")
            select_dtext(6, 11, selector: @full_editor_selector)

            @full_editor_field.send_keys([:control, key])

            assert_equal expected_markup, @full_editor_field.value, "Ctrl+#{key} should wrap the selected word in #{expected_markup.inspect}"
          end
        end
      end

      context "the edit/preview toggle" do
        should "work" do
          @full_editor_field.set("[[1girl]]")

          find(".new-comment a[title^='Preview']").click

          assert_hidden @full_editor_selector
          assert_selector ".new-comment .dtext-preview .dtext-wiki-link", text: "1girl"

          find(".new-comment a", text: "Edit").click

          assert_visible @full_editor_selector
          assert_equal "[[1girl]]", @full_editor_field.value
        end
      end

      context "when the preview request times out" do
        should "show an error notice and revert to edit mode" do
          page.execute_script(<<~JS)
            $.ajax = function() {
              return $.Deferred().reject({ statusText: "timeout" }, "timeout").promise();
            };
          JS

          @full_editor_field.set("[[1girl]]")
          find(".new-comment a[title^='Preview']").click

          assert_notice "Failed to load preview"
          assert_visible @full_editor_selector
          assert_equal "[[1girl]]", @full_editor_field.value
        end
      end

      context "the length counter" do
        should "update as text is typed, and turn red past the max length" do
          @full_editor_field.native.fill("x" * 5000)
          assert_hidden ".new-comment .dtext-input-counter-text"

          @full_editor_field.native.fill("x" * 12_001)
          assert_visible ".new-comment .dtext-input-counter-text", text: "12001/15000"
          assert_no_selector ".new-comment .dtext-input-counter-text.text-error"

          @full_editor_field.native.fill("x" * 15_001)
          assert_selector ".new-comment .dtext-input-counter-text.text-error", text: "15001/15000"
        end
      end
    end

    context "the inline editor" do
      setup do
        @moderator = create(:moderator_user)

        fast_signin @moderator
        visit new_ban_path
      end

      should "update the counter as text is typed, and turn red past the max length" do
        assert_selector ".dtext-input-counter-text", text: "0/600"
        assert_no_selector ".dtext-input-counter-text.text-error"

        find_field("Reason").native.fill("x" * 500)
        assert_selector ".dtext-input-counter-text", text: "500/600"
        assert_no_selector ".dtext-input-counter-text.text-error"

        find_field("Reason").native.fill("x" * 601)
        assert_selector ".dtext-input-counter-text.text-error", text: "601/600"
      end

      should "toggle between edit and preview mode" do
        find_field("Reason").set("[[1girl]]")

        find("a[title^='Preview']").click

        assert_hidden "input#ban_reason"
        assert_selector ".dtext-preview .dtext-wiki-link", text: "1girl"

        find("a[title^='Edit']").click

        assert_visible "input#ban_reason"
        assert_equal "[[1girl]]", find_field("Reason").value
      end

      should "vertically center the preview toggle icon in the input" do
        input_box = find("input#ban_reason").native.bounding_box
        icon_box = find("a[title^='Preview'] svg").native.bounding_box

        assert_in_delta input_box["y"] + (input_box["height"] / 2), icon_box["y"] + (icon_box["height"] / 2), 0.5
      end

      should "not show long previews under the toggle icon" do
        find_field("Reason").set("[[1girl]] #{"word " * 100}")
        find("a[title^='Preview']").click
        assert_selector ".dtext-preview .dtext-wiki-link"

        text_right = find(".dtext-preview-content").native.bounding_box.then { it["x"] + it["width"] }
        icon_left = find("a[title^='Edit'] svg").native.bounding_box["x"]

        assert_operator text_right, :<=, icon_left
      end

      should "keep the scroll position of long text when previewing" do
        find_field("Reason").send_keys("[[1girl]] #{"word " * 40}end")
        assert_operator page.evaluate_script("document.querySelector('#ban_reason').scrollLeft"), :>, 0

        find("a[title^='Preview']").click
        assert_selector ".dtext-preview .dtext-wiki-link"

        scroll_left, max_scroll = page.evaluate_script("(el => [el.scrollLeft, el.scrollWidth - el.clientWidth])(document.querySelector('.dtext-preview-content'))")
        assert_in_delta max_scroll, scroll_left, 2, "the preview should be scrolled to the end, like the input"
      end

      should "keep the same size when previewing an empty field" do
        input_height = find("input#ban_reason").native.bounding_box["height"]

        find("a[title^='Preview']").click
        assert_selector ".dtext-preview", visible: :visible

        assert_in_delta input_height, find(".dtext-preview").native.bounding_box["height"], 1
      end

      should "toggle preview mode with Ctrl+P" do
        find_field("Reason").set("[[1girl]]")
        find_field("Reason").send_keys([:control, "p"])

        assert_selector ".dtext-preview .dtext-wiki-link", text: "1girl"

        send_global_key("Control+p")

        assert_visible "input#ban_reason"
        assert_equal "[[1girl]]", find_field("Reason").value
      end
    end
  end
end

class DtextEditorFirefoxTest < FirefoxSystemTestCase
  context "The inline DText editor" do
    should "not cut off the bottom of the text in previews" do
      fast_signin create(:moderator_user)
      visit new_ban_path
      find_field("Reason").set("asd [[1girl]]")
      find("a[title^='Preview']").click

      link_bottom = find(".dtext-preview .dtext-wiki-link").native.bounding_box.then { it["y"] + it["height"] }
      content_bottom = find(".dtext-preview-content").native.bounding_box.then { it["y"] + it["height"] }

      assert_operator link_bottom, :<=, content_bottom
    end

    # Firefox doesn't let inputs have a line height below `normal`, so the preview has to copy it.
    should "use the same line height in the preview as in the input" do
      fast_signin create(:moderator_user)
      visit new_ban_path
      find_field("Reason").set("asd test")
      input_line_height = page.evaluate_script("getComputedStyle(document.querySelector('#ban_reason')).lineHeight")

      find("a[title^='Preview']").click
      assert_selector ".dtext-preview-content", text: "asd test"

      assert_equal input_line_height, page.evaluate_script("getComputedStyle(document.querySelector('.dtext-preview-content')).lineHeight")
    end
  end
end
