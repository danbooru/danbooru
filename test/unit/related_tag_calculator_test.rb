require 'test_helper'

class RelatedTagCalculatorTest < ActiveSupport::TestCase
  setup do
    user = FactoryBot.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
  end

  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "RelatedTagCalculator" do
    context "#frequent_tags_for_posts" do
      should "calculate the most frequent tags for a set of posts" do
        create(:post, tag_string: "aaa bbb ccc ddd")
        create(:post, tag_string: "aaa bbb ccc")
        create(:post, tag_string: "aaa bbb")
        posts = Post.tag_match("aaa")

        assert_equal(%w[aaa bbb ccc ddd], RelatedTagCalculator.frequent_tags_for_posts(posts))
      end
    end

    context "#frequent_tags_for_search" do
      should "calculate the most frequent tags for a single tag search" do
        create(:post, tag_string: "aaa bbb ccc ddd")
        create(:post, tag_string: "aaa bbb ccc")
        create(:post, tag_string: "aaa bbb")

        assert_equal(%w[aaa bbb ccc ddd], RelatedTagCalculator.frequent_tags_for_search("aaa").pluck(:name))
      end

      should "calculate the most frequent tags for a multiple tag search" do
        create(:post, tag_string: "aaa bbb ccc")
        create(:post, tag_string: "aaa bbb ccc ddd")
        create(:post, tag_string: "aaa eee fff")

        assert_equal(%w[aaa bbb ccc ddd], RelatedTagCalculator.frequent_tags_for_search("aaa bbb").pluck(:name))
      end

      should "calculate the most frequent tags with a category constraint" do
        create(:post, tag_string: "aaa bbb art:ccc copy:ddd")
        create(:post, tag_string: "aaa bbb art:ccc")
        create(:post, tag_string: "aaa bbb")

        assert_equal(%w[aaa bbb], RelatedTagCalculator.frequent_tags_for_search("aaa", category: Tag.categories.general).pluck(:name))
        assert_equal(%w[ccc], RelatedTagCalculator.frequent_tags_for_search("aaa", category: Tag.categories.artist).pluck(:name))
      end
    end

    context "#similar_tags_for_search" do
      should "calculate the most similar tags for a search" do
        create(:post, tag_string: "1girl solo", rating: "s")
        create(:post, tag_string: "1girl solo", rating: "q")
        create(:post, tag_string: "1girl 1boy", rating: "q")

        assert_equal(%w[1girl solo 1boy], RelatedTagCalculator.similar_tags_for_search("1girl").pluck(:name))
        assert_equal(%w[1girl 1boy solo], RelatedTagCalculator.similar_tags_for_search("rating:q").pluck(:name))
        assert_equal(%w[solo 1girl], RelatedTagCalculator.similar_tags_for_search("solo").pluck(:name))
      end
    end
  end
end
