require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  context "in all cases a user" do
    setup do
      @user = FactoryGirl.create(:user, :name => "abcdef")
      @api_key = ApiKey.generate!(@user)
      @user.name.mb_chars.downcase
    end

    should "authenticate via api key" do
      assert_not_nil(User.authenticate_api_key(@user.name, @api_key.key))
    end

    should "not authenticate with the wrong api key" do
      assert_nil(User.authenticate_api_key(@user.name, "xxx"))
    end

    should "not authenticate with the wrong name" do
      assert_nil(User.authenticate_api_key("xxx", @api_key.key))
    end
  end
end
