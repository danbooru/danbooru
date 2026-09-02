require "application_system_test_case"

class TagScriptChromeTest < ChromeSystemTestCase
  def tag_script_field
    find("#tag-script-field")
  end

  def switch_mode(mode)
    select mode, from: "mode"
  end

  # Click something that isn't a form field, to blur the tag script field without navigating away.
  def blur_tag_script_field
    find("#mode-box h2").click
  end

  def current_tag_script_slot
    page.evaluate_script("localStorage.getItem('current_tag_script_id')")
  end

  def saved_tag_script(slot)
    page.evaluate_script("localStorage.getItem('tag-script-#{slot}')")
  end

  def click_post(post)
    within(post_selector(post)) { find(".post-preview-link").click }
  end

  # Wait for the post's tag update to complete the AJAX request
  def assert_post_tags(post, tag_string)
    assert_selector "#{post_selector(post)}[data-tags='#{tag_string}']"
    assert_equal tag_string, post.reload.tag_string
  end

  # Mock Danbooru.Notice.info so we can check whether a notice was shown without
  # relying on matching its (possibly unchanged) text against whatever notice was already on screen.
  def spy_on_notices
    page.execute_script(<<~JS)
      window.__notices = [];
      Danbooru.Notice.info = (message) => window.__notices.push(message);
    JS
  end

  def notices_shown
    page.evaluate_script("window.__notices")
  end

  context "Tag script:" do
    setup do
      @user = create(:gold_user)
      @post = create(:post, tag_string: "1girl tagme")
      @other_post = create(:post, tag_string: "2girls")
    end

    context "for a non-gold user" do
      should "not show the mode menu" do
        fast_signin create(:user)
        visit posts_path

        assert_no_selector "#mode-box"
      end
    end

    context "for a gold user" do
      setup do
        fast_signin @user
        visit posts_path
      end

      should "show the tag script field and a notice when switching to tag script mode" do
        switch_mode "Tag script"

        assert_visible "#tag-script-field"
        assert_notice "Switched to tag script #1. To switch tag scripts, use the number keys."
        assert_equal "1", current_tag_script_slot
      end

      should "hide the tag script field when switching to a different mode" do
        switch_mode "Tag script"
        assert_visible "#tag-script-field"

        switch_mode "View"
        assert_hidden "#tag-script-field"
      end

      should "save the script to local storage when the field loses focus" do
        switch_mode "Tag script"

        tag_script_field.set("solo -tagme")
        blur_tag_script_field

        assert_equal "solo -tagme", saved_tag_script("1")
      end

      should "switch back to view mode when the field is emptied and loses focus" do
        switch_mode "Tag script"
        tag_script_field.set("solo")
        blur_tag_script_field
        assert_equal "solo", saved_tag_script("1")

        tag_script_field.set("")
        blur_tag_script_field

        assert_equal "view", find("select[name=mode]").value
        assert_hidden "#tag-script-field"
      end

      should "apply the script to every post clicked while the mode is active" do
        switch_mode "Tag script"
        tag_script_field.set("solo")
        blur_tag_script_field

        click_post(@post)
        click_post(@other_post)

        assert_post_tags(@post, "1girl solo tagme")
        assert_post_tags(@other_post, "2girls solo")
      end

      should "switch between numbered script slots with the number keys and remember all scripts" do
        switch_mode "Tag script"
        tag_script_field.set("solo -tagme")
        blur_tag_script_field

        send_global_key("2")

        assert_notice "Switched to tag script #2. To switch tag scripts, use the number keys."
        assert_equal "2", current_tag_script_slot
        assert_equal "", tag_script_field.value

        tag_script_field.set("1boy")
        blur_tag_script_field
        assert_equal "1boy", saved_tag_script("2")

        send_global_key("1")
        assert_notice "Switched to tag script #1. To switch tag scripts, use the number keys."
        assert_equal "1", current_tag_script_slot
        assert_equal "solo -tagme", tag_script_field.value

        click_post(@other_post)
        assert_post_tags(@other_post, "2girls solo")
      end

      should "ignore the number key shortcuts while not in tag script mode" do
        send_global_key("2")

        assert_equal "view", find("select[name=mode]").value
        assert_hidden "#tag-script-field"
        assert_no_selector "#notice span.prose", text: /Switched to tag script/
      end
    end
  end
end
