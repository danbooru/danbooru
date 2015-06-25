require 'test_helper'

class UserUpgradesControllerTest < ActionController::TestCase
  if Danbooru.config.coinbase_secret
    setup do
      @admin = FactoryGirl.create(:admin_user)
      @user = FactoryGirl.create(:user)
    end

    context "#create" do
      setup do
        @encrypted = ActiveSupport::MessageEncryptor.new(Danbooru.config.coinbase_secret).encrypt_and_sign("#{@user.id},#{User::Levels::GOLD}")
      end

      context "for basic -> gold" do
        should "promote the account" do
          post :create, {:order => {:status => "completed", :custom => @encrypted}}
          assert_response :success
          @user.reload
          assert_equal(User::Levels::GOLD, @user.level)
        end
      end
    end

    context "#new" do
      setup do
        Coinbase::Client.any_instance.stubs(:create_button).returns(OpenStruct.new)
      end

      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end
    end
  end
end
