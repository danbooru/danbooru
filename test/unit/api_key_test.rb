require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  context "ApiKey:" do
    setup do
      @user = create(:user)
      @api_key = create(:api_key, user: @user)
    end

    context "During validation" do
      subject { build(:api_key) }

      context "of permissions" do
        should allow_value([]).for(:permissions)
        should allow_value(["posts:index"]).for(:permissions)
        should allow_value(["posts:index", "posts:show"]).for(:permissions)

        should_not allow_value(["blah"]).for(:permissions)
        should_not allow_value(["posts:blah"]).for(:permissions)
        should_not allow_value(["blah:index"]).for(:permissions)
      end

      context "of IP addresses" do
        should allow_value([]).for(:permitted_ip_addresses)
        should allow_value(["1.2.3.4"]).for(:permitted_ip_addresses)
        should allow_value(["1.2.3.4/24"]).for(:permitted_ip_addresses)
        should allow_value(["0.0.0.0/0"]).for(:permitted_ip_addresses)
        should allow_value(["2600::1/64"]).for(:permitted_ip_addresses)

        #should allow_value(["1.2.3.4/24 4.5.6.7/24"]).for(:permitted_ip_addresses)
        #should_not allow_value(["blah"]).for(:permitted_ip_addresses)
        #should_not allow_value(["1.2.3.4/64"]).for(:permitted_ip_addresses)
      end
    end

    should "generate a unique key" do
      assert_not_nil(@api_key.key)
    end

    should "authenticate via api key" do
      assert_equal([@user, @api_key], @user.authenticate_api_key(@api_key.key))
    end

    should "not authenticate with the wrong api key" do
      assert_equal(false, @user.authenticate_api_key("xxx"))
    end

    should "not authenticate with the wrong name" do
      assert_equal(false, create(:user).authenticate_api_key(@api_key.key))
    end

    should "have the same limits whether or not they have an api key" do
      assert_no_difference(["@user.reload.api_regen_multiplier", "@user.reload.api_burst_limit"]) do
        @api_key.destroy
      end
    end
  end
end
