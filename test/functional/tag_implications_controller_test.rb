require 'test_helper'

class TagImplicationsControllerTest < ActionDispatch::IntegrationTest
  context "The tag implications controller" do
    setup do
      @tag_implication = create(:tag_implication, antecedent_name: "aaa", consequent_name: "bbb")
    end

    context "index action" do
      setup do
        @user = create(:builder_user, name: "sakuya")
        as (@user) do
          @forum_topic = create(:forum_topic, title: "Weapon BUR")
          @forum_post = create(:forum_post, topic: @forum_topic, body: "because")
        end
        @antecedent_tag = create(:copyright_tag, name: "cannon", post_count: 10)
        @consequent_tag = create(:copyright_tag, name: "weapon", post_count: 1000)
        @antecedent_wiki = create(:wiki_page, title: "cannon", body: "made of fun")
        @consequent_wiki = create(:wiki_page, title: "weapon")

        @other_implication = create(:tag_implication, antecedent_name: "cannon", consequent_name: "weapon", creator: @user, status: "pending", forum_topic: @forum_topic, forum_post: @forum_post)
        @unrelated_implication = create(:tag_implication)
      end

      should "render" do
        get tag_implications_path
        assert_response :success
      end

      should respond_to_search({}).with { [@unrelated_implication, @other_implication, @tag_implication] }
      should respond_to_search(antecedent_name: "aaa").with { @tag_implication }
      should respond_to_search(consequent_name: "bbb").with { @tag_implication }
      should respond_to_search(status: "pending").with { @other_implication }

      context "using includes" do
        should respond_to_search(antecedent_tag: {post_count: 10}).with { @other_implication }
        should respond_to_search(consequent_tag: {category: Tag.categories.copyright}).with { @other_implication }
        should respond_to_search(has_antecedent_tag: "true").with { @other_implication }
        should respond_to_search(has_consequent_tag: "false").with { [@unrelated_implication, @tag_implication] }
        should respond_to_search(antecedent_wiki: {body_matches: "made of fun"}).with { @other_implication }
        should respond_to_search(has_consequent_wiki: "true").with { @other_implication }
        should respond_to_search(forum_topic: {title_matches: "Weapon BUR"}).with { @other_implication }
        should respond_to_search(forum_post: {body: "because"}).with { @other_implication }
        should respond_to_search(creator_name: "sakuya").with { @other_implication }
        should respond_to_search(creator: {level: User::Levels::BUILDER}).with { @other_implication }
      end

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
