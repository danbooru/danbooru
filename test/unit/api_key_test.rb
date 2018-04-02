require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  context "in all cases a user" do
    setup do
      @user = FactoryBot.create(:gold_user, :name => "abcdef")
      @api_key = ApiKey.generate!(@user)
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

    should "have the same limits whether or not they have an api key" do
      assert_no_difference(["@user.reload.api_regen_multiplier", "@user.reload.api_burst_limit"]) do
        @user.api_key.destroy
      end
    end
  end
end
