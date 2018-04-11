require 'test_helper'

class TagAliasCorrectionsControllerTest < ActionDispatch::IntegrationTest
  context "The tag alias correction controller" do
    setup do
      @admin = create(:admin_user)
      as(@admin) do
        @tag_alias = create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
      end
    end

    context "show action" do
      should "render" do
        get_auth tag_alias_correction_path(tag_alias_id: @tag_alias.id), @admin
        assert_response :success
      end
    end

    context "create action" do
      should "render" do
        post_auth tag_alias_correction_path(tag_alias_id: @tag_alias.id), @admin, params: {:commit => "Fix"}
        assert_redirected_to(tag_alias_correction_path(:tag_alias_id => @tag_alias.id))
      end
    end
  end
end
