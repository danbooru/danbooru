require 'test_helper'

class TagAliasesControllerTest < ActionController::TestCase
  context "The tag aliases controller" do
    setup do
      @user = Factory.create(:admin_user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
      Delayed::Worker.delay_jobs = false
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "index action" do
      setup do
        @tag_alias = Factory.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
      end
      
      should "list all tag aliass" do
        get :index
        assert_response :success
      end
      
      should "list all tag_aliass (with search)" do
        get :index, {:search => {:antecedent_name_matches => "aaa"}}
        assert_response :success
      end
    end
    
    context "create action" do
      should "create a tag alias" do
        assert_difference("TagAlias.count", 1) do
          post :create, {:tag_alias => {:antecedent_name => "xxx", :consequent_name => "yyy"}}, {:user_id => @user.id}
        end
      end
    end

    context "destroy action" do
      setup do
        @tag_alias = Factory.create(:tag_alias)
      end
      
      should "destroy a tag_alias" do
        assert_difference("TagAlias.count", -1) do
          post :destroy, {:id => @tag_alias.id}, {:user_id => @user.id}
        end
      end
    end
    
    context "destroy_cache action" do
      setup do
        @tag_alias = Factory.create(:tag_alias, :antecedent_name => "aaa")
      end
      
      should "reset the cache" do
        post :cache, {:id => @tag_alias.id}, {:user_id => @user.id}
        assert_nil(Cache.get("ta:aaa"))
      end
    end
  end
end
