require 'test_helper'

class TagAliasesControllerTest < ActionDispatch::IntegrationTest
  context "The tag aliases controller" do
    setup do
      @tag_alias = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb")
    end

    context "index action" do
      should "list all tag alias" do
        get tag_aliases_path
        assert_response :success
      end

      should "list all tag_alias (with search)" do
        get tag_aliases_path, params: {:search => {:antecedent_name => "aaa"}}
        assert_response :success
      end
    end

    context "show action" do
      should "work" do
        get tag_alias_path(@tag_alias)
        assert_response :success
      end
    end

    context "destroy action" do
      should "allow admins to delete aliases" do
        delete_auth tag_alias_path(@tag_alias), create(:admin_user)

        assert_response :redirect
        assert_equal("deleted", @tag_alias.reload.status)
      end

      should "not allow members to delete aliases" do
        delete_auth tag_alias_path(@tag_alias), create(:user)

        assert_response 403
        assert_equal("active", @tag_alias.reload.status)
      end
    end
  end
end
