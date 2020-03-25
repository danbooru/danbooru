require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  context "in all cases a user" do
    setup do
      @user = FactoryBot.create(:gold_user, :name => "abcdef")
      @api_key = ApiKey.generate!(@user)
    end

    should "regenerate the key" do
      assert_changes(-> { @api_key.key }) do
        @api_key.regenerate!
      end
    end

    should "generate a unique key" do
      assert_not_nil(@api_key.key)
    end

    should "authenticate via api key" do
      assert_equal(@user, @user.authenticate_api_key(@api_key.key))
    end

    should "not authenticate with the wrong api key" do
      assert_equal(false, @user.authenticate_api_key("xxx"))
    end

    should "not authenticate with the wrong name" do
      assert_equal(false, create(:user).authenticate_api_key(@api_key.key))
    end

    should "have the same limits whether or not they have an api key" do
      assert_no_difference(["@user.reload.api_regen_multiplier", "@user.reload.api_burst_limit"]) do
        @user.api_key.destroy
      end
    end
  end
end
