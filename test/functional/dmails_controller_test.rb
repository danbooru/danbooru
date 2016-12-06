require 'test_helper'

class DmailsControllerTest < ActionController::TestCase
  context "The dmails controller" do
    setup do
      @user = FactoryGirl.create(:user)
      @unrelated_user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @dmail = FactoryGirl.create(:dmail, :owner => @user)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "new action" do
      should "get the page" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end

      context "with a respond_to_id" do
        should "check privileges" do
          @user2 = FactoryGirl.create(:user)
          get :new, {:respond_to_id => @dmail}, {:user_id => @user2.id}
          assert_response 403
        end

        should "prefill the fields" do
          get :new, {:respond_to_id => @dmail}, {:user_id => @user.id}
          assert_response :success
          assert_not_nil assigns(:dmail)
          assert_equal(@dmail.from_id, assigns(:dmail).to_id)
        end

        context "and a forward flag" do
          should "not populate the to field" do
            get :new, {:respond_to_id => @dmail, :forward => true}, {:user_id => @user.id}
            assert_response :success
            assert_not_nil assigns(:dmail)
            assert_nil(assigns(:dmail).to_id)
          end
        end
      end
    end

    context "index action" do
      should "show dmails owned by the current user" do
        get :index, {:owner_id_equals => @dmail.owner_id, :folder => "sent"}, {:user_id => @dmail.owner_id}
        assert_response :success
        assert_equal(1, assigns[:dmails].size)

        get :index, {:owner_id_equals => @dmail.owner_id, :folder => "received"}, {:user_id => @dmail.owner_id}
        assert_response :success
        assert_equal(1, assigns[:dmails].size)
      end

      should "not show dmails not owned by the current user" do
        get :index, {:owner_id_equals => @dmail.owner_id}, {:user_id => @unrelated_user.id}
        assert_response :success
        assert_equal(0, assigns[:dmails].size)
      end
    end

    context "show action" do
      should "show dmails owned by the current user" do
        get :show, {:id => @dmail.id}, {:user_id => @dmail.owner_id}
        assert_response :success
      end

      should "not show dmails not owned by the current user" do
        get :show, {:id => @dmail.id}, {:user_id => @unrelated_user.id}
        assert_response(403)
      end
    end

    context "create action" do
      setup do
        @user_2 = FactoryGirl.create(:user)
      end

      should "create two messages, one for the sender and one for the recipient" do
        assert_difference("Dmail.count", 2) do
          dmail_attribs = {:to_id => @user_2.id, :title => "abc", :body => "abc"}
          post :create, {:dmail => dmail_attribs}, {:user_id => @user.id}
          assert_redirected_to dmail_path(Dmail.last)
        end
      end
    end

    context "destroy action" do
      should "allow deletion if the dmail is owned by the current user" do
        assert_difference("Dmail.count", -1) do
          post :destroy, {:id => @dmail.id}, {:user_id => @dmail.owner_id}
          assert_redirected_to dmails_path
        end
      end

      should "not allow deletion if the dmail is not owned by the current user" do
        assert_difference("Dmail.count", 0) do
          post :destroy, {:id => @dmail.id}, {:user_id => @unrelated_user.id}
        end
      end
    end
  end
end
