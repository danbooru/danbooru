require 'test_helper'

class RelatedTagCalculatorTest < ActiveSupport::TestCase
  def frequent_tags_for_search(tag_search, user = CurrentUser.user, **options)
    post_query = PostQueryBuilder.new(tag_search, user)
    RelatedTagCalculator.frequent_tags_for_search(post_query, **options).pluck(:name)
  end

  def similar_tags_for_search(tag_search, user = CurrentUser.user, **options)
    post_query = PostQueryBuilder.new(tag_search, user).normalized_query
    RelatedTagCalculator.similar_tags_for_search(post_query, **options).pluck(:name)
  end

  setup do
    @user = create(:user)
  end

  context "RelatedTagCalculator" do
    context "#frequent_tags_for_post_array" do
      should "calculate the most frequent tags for a set of posts" do
        create(:post, tag_string: "aaa bbb ccc ddd")
        create(:post, tag_string: "aaa bbb ccc")
        create(:post, tag_string: "aaa bbb")
        posts = Post.user_tag_match("aaa", @user)

        assert_equal(%w[aaa bbb ccc ddd], RelatedTagCalculator.frequent_tags_for_post_array(posts))
      end
    end

    context "#frequent_tags_for_search" do
      should "calculate the most frequent tags for a single tag search" do
        create(:post, tag_string: "aaa bbb ccc ddd")
        create(:post, tag_string: "aaa bbb ccc")
        create(:post, tag_string: "aaa bbb")

        assert_equal(%w[aaa bbb ccc ddd], frequent_tags_for_search("aaa", @user))
      end

      should "calculate the most frequent tags for a multiple tag search" do
        create(:post, tag_string: "aaa bbb ccc")
        create(:post, tag_string: "aaa bbb ccc ddd")
        create(:post, tag_string: "aaa eee fff")

        assert_equal(%w[aaa bbb ccc ddd], frequent_tags_for_search("aaa bbb", @user))
      end

      should "calculate the most frequent tags with a category constraint" do
        create(:post, tag_string: "aaa bbb art:ccc copy:ddd")
        create(:post, tag_string: "aaa bbb ccc")
        create(:post, tag_string: "aaa bbb")

        assert_equal(%w[aaa bbb], frequent_tags_for_search("aaa", @user, category: Tag.categories.general))
        assert_equal(%w[ccc], frequent_tags_for_search("aaa", @user, category: Tag.categories.artist))
      end
    end

    context "#similar_tags_for_search" do
      should "calculate the most similar tags for a search" do
        create(:post, tag_string: "1girl solo", rating: "s", score: 1)
        create(:post, tag_string: "1girl solo", rating: "q", score: 2)
        create(:post, tag_string: "1girl 1boy", rating: "q", score: 2)

        assert_equal(%w[1girl solo 1boy], similar_tags_for_search("1girl", @user))
        assert_equal(%w[1girl 1boy solo], similar_tags_for_search("score:2", @user))
        assert_equal(%w[solo 1girl], similar_tags_for_search("solo", @user))
      end

      should "calculate the similar tags for an aliased tag" do
        create(:tag_alias, antecedent_name: "rabbit", consequent_name: "bunny")
        create(:post, tag_string: "bunny dog")
        create(:post, tag_string: "bunny cat")

        assert_equal(%w[bunny cat dog], similar_tags_for_search("rabbit", @user))
      end
    end
  end
end
