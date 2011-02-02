require 'test_helper'

class UnapprovalsControllerTest < ActionController::TestCase
  context "The unapprovals controller" do
    setup do
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end
    end
    
    context "index action" do
      setup do
        @unapproval = Factory.create(:unapproval)
      end
      
      should "render" do
        get :index, {}, {:user_id => @user.id}
        assert_response :success
      end
      
      context "with search parameters" do
        should "render" do
          get :index, {:search => {:post_id_equals => @unapproval.post_id}}, {:user_id => @user.id}
          assert_response :success
        end
      end
    end
    
    context "create action" do
      setup do 
        @post = Factory.create(:post)
      end
      
      should "create a new unapproval" do
        assert_difference("Unapproval.count", 1) do
          post :create, {:unapproval => {:post_id => @post.id, :reason => "xxx"}}, {:user_id => @user.id}
          assert_not_nil(assigns(:unapproval))
          assert_equal([], assigns(:unapproval).errors.full_messages)
        end
      end
    end
    
    context "destroy action" do
      setup do
        @unapproval = Factory.create(:unapproval)
      end
      
      should "delete an unapproval" do
        assert_difference "Unapproval.count", -1 do
          post :destroy, {:id => @unapproval.id}, {:user_id => @user.id}
        end
      end
    end
  end
end
