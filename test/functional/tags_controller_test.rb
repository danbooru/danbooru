require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  context "The tags controller" do
    setup do
      @user = FactoryGirl.create(:builder_user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "edit action" do
      setup do
        @tag = FactoryGirl.create(:tag, :name => "aaa")
      end

      should "render" do
        get :edit, {:id => @tag.id}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "index action" do
      setup do
        @tag = FactoryGirl.create(:tag, name: "aaa", post_count: 1)
      end

      should "render" do
        get :index
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get :index, {:search => {:name_matches => "aaa"}}
          assert_response :success
        end
      end
    end

    context "autocomplete action" do
      should "render" do
        FactoryGirl.create(:tag, name: "touhou", post_count: 1)

        get :autocomplete, { search: { name_matches: "t" }, format: :json }
        assert_response :success
      end
    end

    context "show action" do
      setup do
        @tag = FactoryGirl.create(:tag)
      end

      should "render" do
        get :show, {:id => @tag.id}
        assert_response :success
      end
    end

    context "update action" do
      setup do
        @tag = FactoryGirl.create(:tag)
      end

      should "update the tag" do
        post :update, {:id => @tag.id, :tag => {:category => "1"}}, {:user_id => @user.id}
        assert_redirected_to tag_path(@tag)
        @tag.reload
        assert_equal(1, @tag.category)
      end
    end
  end
end
