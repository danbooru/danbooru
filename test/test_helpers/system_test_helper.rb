module SystemTestHelper
  def signup(name, password: "password")
    visit new_user_path
    fill_in "Name", with: name
    fill_in "Password", with: password
    fill_in "Password confirmation", with: password
    click_button "Sign up"
  end

  def signin(user)
    visit new_session_path
    fill_in "Name", with: user.name
    fill_in "Password", with: user.password
    click_button "Submit"
  end
end
