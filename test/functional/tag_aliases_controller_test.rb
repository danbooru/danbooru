require 'test_helper'

class TagAliasesControllerTest < ActionDispatch::IntegrationTest
  context "The tag aliases controller" do
    setup do
      @tag_alias = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb")
    end

    context "index action" do
      setup do
        @user = create(:builder_user, name: "sakuya")
        as (@user) do
          @forum_topic = create(:forum_topic, title: "Touhou BUR")
          @forum_post = create(:forum_post, topic: @forum_topic, body: "because")
        end
        @antecedent_tag = create(:copyright_tag, name: "touhou", post_count: 1000)
        @consequent_tag = create(:copyright_tag, name: "touhou_project", post_count: 10)
        @antecedent_wiki = create(:wiki_page, title: "touhou", body: "zun project")
        @consequent_wiki = create(:wiki_page, title: "touhou_project")

        @other_alias = create(:tag_alias, antecedent_name: "touhou", consequent_name: "touhou_project", creator: @user, status: "pending", forum_topic: @forum_topic, forum_post: @forum_post)
        @unrelated_alias = create(:tag_alias)
      end

      should "render" do
        get tag_aliases_path
        assert_response :success
      end

      should respond_to_search({}).with { [@unrelated_alias, @other_alias, @tag_alias] }
      should respond_to_search(antecedent_name: "aaa").with { @tag_alias }
      should respond_to_search(consequent_name: "bbb").with { @tag_alias }
      should respond_to_search(status: "pending").with { @other_alias }

      context "using includes" do
        should respond_to_search(antecedent_tag: {post_count: 1000}).with { @other_alias }
        should respond_to_search(consequent_tag: {category: Tag.categories.copyright}).with { @other_alias }
        should respond_to_search(has_antecedent_tag: "true").with { @other_alias }
        should respond_to_search(has_consequent_tag: "false").with { [@unrelated_alias, @tag_alias] }
        should respond_to_search(antecedent_wiki: {body_matches: "zun project"}).with { @other_alias }
        should respond_to_search(has_consequent_wiki: "true").with { @other_alias }
        should respond_to_search(forum_topic: {title_matches: "Touhou BUR"}).with { @other_alias }
        should respond_to_search(forum_post: {body: "because"}).with { @other_alias }
        should respond_to_search(creator_name: "sakuya").with { @other_alias }
        should respond_to_search(creator: {level: User::Levels::BUILDER}).with { @other_alias }
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
