require 'test_helper'

class TagImplicationsControllerTest < ActionController::TestCase
  context "The tag implicationes controller" do
    setup do
      @user = Factory.create(:admin_user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "index action" do
      setup do
        @tag_implication = Factory.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb", :creator => @user)
      end
      
      should "list all tag implications" do
        get :index
        assert_response :success
      end
      
      should "list all tag_implications (with search)" do
        get :index, {:search => {:antecedent_name_matches => "aaa"}}
        assert_response :success
      end
    end

    context "create action" do
      should "create a tag implication" do
        assert_difference("TagImplication.count", 1) do
          post :create, {:tag_implication => {:antecedent_name => "xxx", :consequent_name => "yyy"}}, {:user_id => @user.id}
        end
      end
    end
    
    context "destroy action" do
      setup do
        @tag_implication = Factory.create(:tag_implication, :creator => @user)
      end
      
      should "destroy a tag_implication" do
        assert_difference("TagImplication.count", -1) do
          post :destroy, {:id => @tag_implication.id}, {:user_id => @user.id}
        end
      end
    end
  end
end
