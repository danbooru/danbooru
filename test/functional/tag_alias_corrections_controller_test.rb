require 'test_helper'

class TagAliasCorrectionsControllerTest < ActionController::TestCase
  context "The tag alias correction controller" do
    setup do
      @admin = FactoryGirl.create(:admin_user)
      CurrentUser.user = @admin
      CurrentUser.ip_addr = "127.0.0.1"
      @tag_alias = FactoryGirl.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "show action" do
      should "render" do
        get :show, {:tag_alias_id => @tag_alias.id}, {:user_id => @admin.id}
        assert_response :success
      end
    end

    context "create action" do
      should "render" do
        post :create, {:tag_alias_id => @tag_alias.id, :commit => "Fix"}, {:user_id => @admin.id}
        assert_redirected_to(tag_alias_correction_path(:tag_alias_id => @tag_alias.id))
      end
    end
  end
end
