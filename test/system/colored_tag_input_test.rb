require "application_system_test_case"

class ColoredTagInputChromeTest < ChromeSystemTestCase
  def overlay
    ".colored-tag-input-overlay"
  end

  # Check that the overlay has the same position, size, and scroll position as the tag box, and wraps its text at the
  # same places (so it has the same scroll height).
  def assert_overlay_matches_textarea
    # Capybara only retries StandardErrors, and Minitest::Assertion isn't one, so raise ExpectationNotMet instead.
    textarea, overlay = page.document.synchronize do
      textarea, overlay = page.evaluate_script(<<~JS)
        [document.querySelector("#post_tag_string"), document.querySelector(".colored-tag-input-overlay")].map(element => {
          let { top, left, width, height } = element.getBoundingClientRect();
          return [top, left, width, height, element.scrollTop, element.scrollHeight];
        })
      JS

      textarea == overlay or raise Capybara::ExpectationNotMet, "The overlay #{overlay} doesn't match the tag box #{textarea}"
      [textarea, overlay]
    end

    assert_equal textarea, overlay
  end

  # Replace the tag box's text at once, like pasting it. Faster than `fill_in`, which types each character.
  # @return [Integer] The number of tag lookups started by pasting. Lookups start as soon as the text changes, so this is
  #   0 if pasting didn't start one.
  def paste_tags(text)
    page.evaluate_script(<<~JS, text)
      (text => {
        let lookups = 0;
        $(document).on("ajaxSend.paste-tags", (event, xhr, options) => { lookups += options.url.startsWith("/tags.json") ? 1 : 0; });

        let textarea = document.querySelector("#post_tag_string");
        textarea.focus();
        textarea.value = text;
        textarea.dispatchEvent(new Event("input"));

        $(document).off("ajaxSend.paste-tags");
        return lookups;
      })(arguments[0])
    JS
  end

  # @return [Array<String>] The decoded URLs of the /tags.json requests made after this is called.
  def record_tag_lookups
    urls = []
    page.driver.with_playwright_page do |playwright_page|
      playwright_page.on("request", ->(request) { urls << CGI.unescape(request.url) if request.url.include?("/tags.json") })
    end
    urls
  end

  setup do
    create(:tag, name: "hatsune_miku", category: Tag.categories.character)
    create(:tag, name: "bkub", category: Tag.categories.artist, post_count: 42)
    create(:tag, name: "old_tag", post_count: 1, is_deprecated: true)
    @user = create(:user, favorite_tags: "1girl", created_at: 1.month.ago)
    Danbooru.config.stubs(:release_stage).returns("testbooru")
    set_beta_feature("colored_tag_input", true)
  end

  context "On the post page" do
    setup do
      @post = create(:post, tag_string: "hatsune_miku 1girl", source: "")
      fast_signin @user
      @lookups = record_tag_lookups
      visit post_path(@post)
      find("#post-edit-link").click
    end

    should "color the post's existing tags by category without looking them up" do
      assert_selector "#{overlay} span.tag-type-4", text: "hatsune_miku"
      assert_selector "#{overlay} span.tag-type-0", text: "1girl"
      assert_empty @lookups
    end

    should "color newly typed tags by category, in any case" do
      fill_in "post_tag_string", with: "Hatsune_Miku -BKUB nonexistent_tag "

      assert_selector "#{overlay} span.tag-type-4", exact_text: "Hatsune_Miku"
      assert_selector "#{overlay} span.tag-type-1", exact_text: "BKUB"
      assert_selector "#{overlay} span[class^='tag-type-']", count: 2
      assert_selector overlay, text: "Hatsune_Miku -BKUB nonexistent_tag"
    end

    should "color category prefixes in any case by the category they set, and tags by their current category" do
      fill_in "post_tag_string", with: "char:bkub ART:new_tag "

      assert_selector "#{overlay} span.tag-type-4", exact_text: "char:"
      assert_selector "#{overlay} span.tag-type-1", exact_text: "bkub"
      assert_selector "#{overlay} span.tag-type-1", exact_text: "ART:"
      assert_selector "#{overlay} span[class^='tag-type-']", count: 3
      assert_selector overlay, text: "char:bkub ART:new_tag"
    end

    should "not look up the word being typed until the caret leaves it" do
      lookups = record_tag_lookups
      fill_in "post_tag_string", with: "bkub hatsu"

      assert_selector "#{overlay} span.tag-type-1", exact_text: "bkub"
      assert(lookups.none? { |url| url.include?("hatsu") })

      page.execute_script("document.querySelector('#post_tag_string').blur()")
      page.document.synchronize { lookups.any? { |url| url.include?("hatsu") } or raise Capybara::ExpectationNotMet, "hatsu wasn't looked up" }
    end

    should "leave the tags uncolored when looking them up fails, and try again on the next edit" do
      failures = 0
      page.driver.with_playwright_page do |playwright_page|
        playwright_page.route("**/tags.json*", lambda { |route, _request|
          failures += 1
          route.fulfill(status: 500, body: "error")
        })
      end
      fill_in "post_tag_string", with: "bkub "

      page.document.synchronize { failures > 0 or raise Capybara::ExpectationNotMet, "The tags weren't looked up" }
      assert_selector overlay, text: "bkub"
      assert_no_selector "#{overlay} span.tag-type-1"

      page.driver.with_playwright_page { |playwright_page| playwright_page.unroute("**/tags.json*") }
      find_field("post_tag_string").send_keys("1girl ")

      assert_selector "#{overlay} span.tag-type-1", exact_text: "bkub"
    end

    should "leave category prefixes uncolored when they don't set the category" do
      fill_in "post_tag_string", with: "-char:bkub ~char:bkub (char:bkub "

      assert_selector "#{overlay} span.tag-type-1", exact_text: "bkub", count: 1
      assert_selector "#{overlay} span[class^='tag-type-']", count: 1
      assert_selector overlay, text: "-char:bkub ~char:bkub (char:bkub"
    end

    should "strike through newly typed deprecated tags" do
      fill_in "post_tag_string", with: "old_tag hatsune_miku "

      assert_selector "#{overlay} span.tag-type-0.line-through", exact_text: "old_tag"
      assert_equal "line-through", page.evaluate_script("getComputedStyle(document.querySelector('.colored-tag-input-overlay .line-through')).textDecorationLine")
      assert_selector "#{overlay} span.tag-type-4", exact_text: "hatsune_miku"
      assert_selector "#{overlay} .line-through", count: 1
    end

    should "strike through the post's existing deprecated tags without looking them up" do
      post = create(:post, tag_string: "legacy_tag", source: "")
      Tag.find_by_name("legacy_tag").update!(is_deprecated: true, updater: @user)
      visit post_path(post)
      find("#post-edit-link").click

      assert_selector "#{overlay} span.line-through", exact_text: "legacy_tag"
      assert_empty @lookups
    end

    should "color tags that come after many long nonexistent tags" do
      junk = Array.new(60) { |i| "#{i}_" + ("a" * 160) }
      paste_tags("#{junk.join(" ")} bkub ")

      assert_selector "#{overlay} span.tag-type-1", text: "bkub", wait: 10
    end

    should "leave metatags uncolored" do
      fill_in "post_tag_string", with: "rating:s parent:123 -pool:foo bkub "

      assert_selector "#{overlay} span.tag-type-1", exact_text: "bkub"
      assert_selector "#{overlay} span[class^='tag-type-']", count: 1
      assert_selector overlay, text: "rating:s parent:123 -pool:foo bkub"
    end

    should "not look up non-ASCII or overlong words" do
      lookups = record_tag_lookups
      fill_in "post_tag_string", with: "ünïcödé #{"a" * 171} bkub "

      assert_selector "#{overlay} span.tag-type-1", text: "bkub"
      assert_not_empty lookups
      lookups.each do |url|
        assert_no_match(/ünïcödé|aaa/, url)
      end
    end

    should "not look up the same tags again when they're pasted again" do
      lookups = record_tag_lookups
      paste_tags("bkub nonexistent_tag rating:s ")
      assert_selector "#{overlay} span.tag-type-1", text: "bkub"

      assert_equal 0, paste_tags("bkub nonexistent_tag rating:s bkub nonexistent_tag ")
      assert_equal 0, paste_tags("-bkub art:bkub -art:bkub BKUB -nonexistent_tag NONEXISTENT_TAG RATING:S ")
      assert_equal 1, lookups.size
    end

    should "stop looking up tags after looking up too many" do
      lookups = record_tag_lookups
      paste_tags("bkub #{Array.new(1_000) { |i| "n_#{i}" }.join(" ")}")
      assert_selector "#{overlay} span.tag-type-1", text: "bkub"

      names = lookups.flat_map { |url| url[/search\[name_space\]=([^&]*)/, 1].split }
      assert_equal 200, names.size
      assert_equal 200, names.uniq.size
      assert_equal 0, paste_tags("bkub new_tag #{Array.new(1_000) { |i| "n_#{i}" }.join(" ")}")
    end

    should "color aliases by the category of the tag they're aliased to" do
      create(:tag, name: "miku", category: Tag.categories.general)
      create(:tag_alias, antecedent_name: "miku", consequent_name: "hatsune_miku")
      create(:tag, name: "old_alias", category: Tag.categories.general)
      create(:tag_alias, antecedent_name: "old_alias", consequent_name: "old_tag")
      fill_in "post_tag_string", with: "miku old_alias "

      assert_selector "#{overlay} span.tag-type-4", exact_text: "miku"
      assert_selector "#{overlay} span.tag-type-0.line-through", exact_text: "old_alias"
    end

    should "turn off for text with more words than a post can have tags, without looking them up" do
      assert_equal 0, paste_tags(Array.new(1_251) { |i| "n_#{i}" }.join(" "))
      assert_selector ".colored-tag-input.colored-tag-input-disabled"
      assert_hidden overlay
      assert_not_equal "rgba(0, 0, 0, 0)", page.evaluate_script("getComputedStyle(document.querySelector('#post_tag_string')).color")

      paste_tags("bkub " * 1_250)
      assert_no_selector ".colored-tag-input-disabled"
      assert_selector "#{overlay} span.tag-type-1", text: "bkub"
    end

    should "ignore tags shown outside of the page's tag lists" do
      page.execute_script(<<~JS)
        let span = document.createElement("span");
        span.className = "tag-type-4";
        span.dataset.tagName = "bkub";
        span.dataset.isDeprecated = "true";
        document.querySelector("#page").append(span);
      JS
      fill_in "post_tag_string", with: "bkub "

      assert_selector "#{overlay} span.tag-type-1", exact_text: "bkub"
      assert_no_selector "#{overlay} .line-through"
    end

    should "show the plain tag box in forced colors mode" do
      page.driver.with_playwright_page { |playwright_page| playwright_page.emulate_media(forcedColors: "active") }

      assert_hidden overlay
      assert_not_equal "rgba(0, 0, 0, 0)", page.evaluate_script("getComputedStyle(document.querySelector('#post_tag_string')).color")
    end

    should "show HTML as plain text" do
      fill_in "post_tag_string", with: "<b>bold</b> bkub "

      assert_selector "#{overlay} span.tag-type-1", text: "bkub"
      assert_no_selector "#{overlay} b"
      assert_selector overlay, text: "<b>bold</b>"
    end

    should "show the selected text in the normal selection colors" do
      textarea_selection = page.evaluate_script("getComputedStyle(document.querySelector('#post_tag_string'), '::selection').color")
      page_selection = page.evaluate_script("getComputedStyle(document.body, '::selection').color")

      assert_equal page_selection, textarea_selection
      assert_not_equal "rgba(0, 0, 0, 0)", textarea_selection
    end

    # Headless Chrome hides scrollbars, so this can't check that the text wraps the same when the scrollbar appears.
    should "match the tag box's size, scroll position, and line wrapping" do
      lines = Array.new(300) { |i| "tag_#{i}" }.each_slice(20).map { |tags| tags.join(" ") }
      paste_tags("#{lines.join("\n")}\n")
      page.execute_script(<<~JS)
        let textarea = document.querySelector("#post_tag_string");
        textarea.scrollTop = textarea.scrollHeight;
        textarea.dispatchEvent(new Event("scroll"));
      JS

      assert_operator page.evaluate_script("document.querySelector('#post_tag_string').scrollTop"), :>, 0
      assert_overlay_matches_textarea
    end

    should "match the tag box's position when it's at a fractional pixel position" do
      page.execute_script(<<~JS)
        let textarea = document.querySelector("#post_tag_string");
        textarea.style.marginTop = "0.5px";
        textarea.style.width = "300.5px";
      JS

      assert_overlay_matches_textarea
    end

    should "color tags in the edit dialog" do
      find("#open-edit-dialog").click
      fill_in "post_tag_string", with: "bkub "

      assert_selector "#edit-dialog #{overlay} span.tag-type-1", text: "bkub"
      assert_overlay_matches_textarea
    end
  end

  context "On the upload page" do
    setup do
      create(:tag, name: "1girl")
      fast_signin @user
      @upload = create(:completed_file_upload, uploader: @user)
      @lookups = record_tag_lookups
      visit upload_path(@upload)
    end

    should "color tags picked from autocomplete without looking them up" do
      autocomplete("#post_tag_string", "bku")
      find("ul.ui-autocomplete li[data-autocomplete-value='bkub']").click
      find_field("post_tag_string").send_keys("old_t")
      find("ul.ui-autocomplete li[data-autocomplete-value='old_tag']").click

      assert_selector "#{overlay} span.tag-type-1", exact_text: "bkub"
      assert_selector "#{overlay} span.line-through", exact_text: "old_tag"
      assert_empty @lookups
    end

    should "not look up metatags picked from autocomplete" do
      autocomplete("#post_tag_string", "rating:g")
      find("ul.ui-autocomplete li[data-autocomplete-value='rating:general']").click
      find_field("post_tag_string").send_keys("bkub ")

      assert_selector "#{overlay} span.tag-type-1", text: "bkub"
      assert_not_empty @lookups
      assert(@lookups.none? { |url| url.include?("rating") })
    end

    should "color tags added from the related tags without looking them up" do
      find("#related-tags-container .frequent-related-tags-column a[data-tag-name='1girl']").click

      assert_selector "#{overlay} span.tag-type-0", text: "1girl"
      assert_empty @lookups
    end
  end

  context "When the beta feature is disabled" do
    should "not color the tags" do
      set_beta_feature("colored_tag_input", false)
      fast_signin @user
      visit post_path(create(:post, tag_string: "hatsune_miku", source: ""))
      find("#post-edit-link").click

      assert_field "post_tag_string", with: /hatsune_miku/
      assert_no_selector ".colored-tag-input"
    end
  end

  context "In the post index quick edit form" do
    should "color the tags of the post being edited" do
      post = create(:post, tag_string: "hatsune_miku", source: "")
      fast_signin create(:gold_user, blacklisted_tags: "")
      visit posts_path
      select "Edit", from: "mode"
      within(post_selector(post)) { find(".post-preview-link").click }

      assert_selector "#quick-edit-form #{overlay} span.tag-type-4", text: "hatsune_miku"
      assert_overlay_matches_textarea # The box has a label above it here.
    end
  end
end
