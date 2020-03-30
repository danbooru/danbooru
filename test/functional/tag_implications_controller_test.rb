require 'test_helper'

class TagImplicationsControllerTest < ActionDispatch::IntegrationTest
  context "The tag implications controller" do
    setup do
      @tag_implication = create(:tag_implication, antecedent_name: "aaa", consequent_name: "bbb")
    end

    context "index action" do
      should "list all tag implications" do
        get tag_implications_path
        assert_response :success
      end

      should "list all tag_implications (with search)" do
        get tag_implications_path, params: {:search => {:antecedent_name => "aaa"}}
        assert_response :success
      end
    end

    context "show action" do
      should "work" do
        get tag_implication_path(@tag_implication)
        assert_response :success
      end
    end

    context "destroy action" do
      should "allow admins to delete implications" do
        delete_auth tag_implication_path(@tag_implication), create(:admin_user)

        assert_response :redirect
        assert_equal("deleted", @tag_implication.reload.status)
      end

      should "not allow members to delete aliases" do
        delete_auth tag_implication_path(@tag_implication), create(:user)

        assert_response 403
        assert_equal("active", @tag_implication.reload.status)
      end
    end
  end
end
