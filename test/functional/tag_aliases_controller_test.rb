require 'test_helper'

class TagAliasesControllerTest < ActionController::TestCase
  context "The tag aliases controller" do
    setup do
      @user = FactoryGirl.create(:admin_user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "edit action" do
      setup do
        @tag_alias = FactoryGirl.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
      end

      should "render" do
        get :edit, {:id => @tag_alias.id}
        assert_response :success
      end
    end

    context "update action" do
      setup do
        @tag_alias = FactoryGirl.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
      end

      context "for a pending alias" do
        setup do
          @tag_alias.update_attribute(:status, "pending")
        end

        should "succeed" do
          post :update, {:id => @tag_alias.id, :tag_alias => {:antecedent_name => "xxx"}}, {:user_id => @user.id}
          @tag_alias.reload
          assert_equal("xxx", @tag_alias.antecedent_name)
        end

        should "not allow changing the status" do
          post :update, {:id => @tag_alias.id, :tag_alias => {:status => "active"}}, {:user_id => @user.id}
          @tag_alias.reload
          assert_equal("pending", @tag_alias.status)
        end

        # TODO: Broken in shoulda-matchers 2.8.0. Need to upgrade to 3.1.1.
        # should_eventually permit(:antecedent_name, :consequent_name, :forum_topic_id).for(:update)
      end

      context "for an approved alias" do
        setup do
          @tag_alias.update_attribute(:status, "approved")
        end

        should "fail" do
          post :update, {:id => @tag_alias.id, :tag_alias => {:antecedent_name => "xxx"}}, {:user_id => @user.id}
          @tag_alias.reload
          assert_equal("aaa", @tag_alias.antecedent_name)
        end
      end
    end

    context "index action" do
      setup do
        @tag_alias = FactoryGirl.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
      end

      should "list all tag alias" do
        get :index, {}, {:user_id => @user.id}
        assert_response :success
      end

      should "list all tag_alias (with search)" do
        get :index, {:search => {:antecedent_name => "aaa"}}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "destroy action" do
      setup do
        @tag_alias = FactoryGirl.create(:tag_alias)
      end

      should "destroy a tag_alias" do
        assert_difference("TagAlias.count", -1) do
          post :destroy, {:id => @tag_alias.id}, {:user_id => @user.id}
        end
      end
    end
  end
end
