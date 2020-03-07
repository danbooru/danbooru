require 'test_helper'

class TagAliasesControllerTest < ActionDispatch::IntegrationTest
  context "The tag aliases controller" do
    setup do
      @user = create(:admin_user)
      @tag_alias = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb")
    end

    context "index action" do
      should "list all tag alias" do
        get_auth tag_aliases_path, @user
        assert_response :success
      end

      should "list all tag_alias (with search)" do
        get_auth tag_aliases_path, @user, params: {:search => {:antecedent_name => "aaa"}}
        assert_response :success
      end
    end

    context "destroy action" do
      should "mark the alias as deleted" do
        assert_difference("TagAlias.count", 0) do
          delete_auth tag_alias_path(@tag_alias), @user
          assert_equal("deleted", @tag_alias.reload.status)
        end
      end
    end
  end
end
