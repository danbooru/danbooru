module SystemTestHelper
  def signup(name, password: "password")
    visit new_user_path
    fill_in "Username", with: name
    fill_in "Password", with: password
    fill_in "Confirm password", with: password
    click_button "Sign up"
  end

  def signin(user)
    visit new_session_path
    fill_in "Name", with: user.name
    fill_in "Password", with: user.password
    click_button "Login"
  end

  def assert_visible(selector, **options)
    assert_selector selector, visible: :visible, **options
  end

  def assert_hidden(selector, **options)
    assert_selector selector, visible: :hidden, **options
  end

  def post_selector(post)
    ".post-preview[data-id='#{post.id}']"
  end
end
