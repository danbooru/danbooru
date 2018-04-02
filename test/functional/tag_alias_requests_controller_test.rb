require 'test_helper'

class TagAliasRequestsControllerTest < ActionDispatch::IntegrationTest
  context "The tag alias request controller" do
    setup do
      @user = create(:user)
    end

    context "new action" do
      should "render" do
        get_auth new_tag_alias_request_path, @user
        assert_response :success
      end
    end

    context "create action" do
      should "render" do
        assert_difference("ForumTopic.count", 1) do
          post_auth tag_alias_request_path, @user, params: {:tag_alias_request => {:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "ccc", :skip_secondary_validations => true}}
        end
        assert_redirected_to(forum_topic_path(ForumTopic.last))
      end
    end
  end
end
