module SystemTestHelper
  extend ActiveSupport::Concern

  # XXX: hack. Browsers are annoying about letting us read the clipboard for tests.
  def stub_clipboard
    page.driver.with_playwright_page do |playwright_page|
      playwright_page.context.add_init_script(script: <<~JS)
        Object.defineProperty(navigator, "clipboard", {
          value: {
            writeText: (text) => { window.__clipboardText = text; return Promise.resolve(); },
            readText: () => Promise.resolve(window.__clipboardText),
          },
          configurable: true,
        });
      JS
    end
  end

  # This function requires stub_clipboard above to have been run at the start of the test.
  def clipboard_text
    page.evaluate_script("navigator.clipboard.readText()")
  end

  # This function requires stub_clipboard above to have been run at the start of the test.
  # @param value [String, Regexp] exact string to match, or a pattern to match against.
  def assert_clipboard(value)
    if value.is_a?(Regexp)
      assert_match value, clipboard_text
    else
      assert_equal value, clipboard_text
    end
  end

  # @param text [String, Regexp, nil] exact string to match, a pattern to match against, or nil to just check the notice is showing.
  def assert_notice(text = nil)
    return assert_selector "#notice span.prose" if text.nil?

    if text.is_a?(Regexp)
      assert_selector "#notice span.prose", text: text
    else
      assert_selector "#notice span.prose", text: text, exact_text: true
    end
  end

  # @param name [String] the username.
  # @param password [String] the password.
  def signup(name, password: "password")
    visit new_user_path
    fill_in "Username", with: name
    fill_in "Password", with: password
    fill_in "Confirm password", with: password
    click_button "Sign up"
  end

  # @param user [User] the user to log in as.
  def signin(user)
    visit new_session_path
    fill_in "Name", with: user.name
    fill_in "Password", with: user.password
    click_button "Login"
  end

  # Send a key press to whatever is currently focused in the page (the <body>, by default).
  # @param key [String] the key to send, e.g. "Escape".
  def send_global_key(key)
    page.driver.with_playwright_page { |playwright_page| playwright_page.keyboard.press(key) }
  end

  # @param selector [String] a CSS selector for the element.
  def assert_visible(selector, **options)
    assert_selector selector, visible: :visible, **options
  end

  # @param selector [String] a CSS selector for the element.
  def assert_hidden(selector, **options)
    assert_selector selector, visible: :hidden, **options
  end

  # @param post [Post] the post.
  def post_selector(post)
    ".post-preview[data-id='#{post.id}']"
  end

  # @param selector [String] a CSS selector for the field.
  # @param text [String] the text to type into the field.
  def autocomplete(selector, text)
    field = find(selector)
    field.set("")
    field.send_keys(text)
    field
  end

  # Check that all the autocomplete results we expect from typing something are actually shown.
  # @param expected_results [Array<String>] the autocomplete values expected to be shown.
  # @param text [String] the text to type into the field.
  # @param selector [String] a CSS selector for the field.
  def assert_autocomplete_results(expected_results, text, selector:)
    autocomplete(selector, text)

    assert_selector "ul.ui-autocomplete li", count: expected_results.size
    expected_results.each do |result|
      assert_selector "li[data-autocomplete-value='#{result}']", count: 1
    end
  end

  # Check that the text inserted after clicking the first autocomplete result equals what's expected.
  # @param expected_result [String] the field's value after clicking the first autocomplete result.
  # @param text [String] the text to type into the field.
  # @param selector [String] a CSS selector for the field.
  def assert_clicked_autocomplete_equals(expected_result, text, selector: "#tags")
    field = autocomplete(selector, text)

    first("ul.ui-autocomplete li").click
    assert_equal(expected_result, field.value)
  end
end
