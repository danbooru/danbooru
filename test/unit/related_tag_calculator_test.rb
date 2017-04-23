require 'test_helper'

class RelatedTagCalculatorTest < ActiveSupport::TestCase
  setup do
    user = FactoryGirl.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
  end

  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "A related tag calculator" do
    context "for a post set" do
      setup do
        FactoryGirl.create(:post, :tag_string => "aaa bbb ccc ddd")
        FactoryGirl.create(:post, :tag_string => "aaa bbb ccc")
        FactoryGirl.create(:post, :tag_string => "aaa bbb")
        @posts = Post.tag_match("aaa")
      end

      should "calculate the related tags" do
        assert_equal({"aaa"=>3, "bbb"=>3, "ccc"=>2, "ddd"=>1}, RelatedTagCalculator.calculate_from_posts(@posts))
      end
    end

    should "calculate related tags for a tag" do
      posts = []
      posts << FactoryGirl.create(:post, :tag_string => "aaa bbb ccc ddd")
      posts << FactoryGirl.create(:post, :tag_string => "aaa bbb ccc")
      posts << FactoryGirl.create(:post, :tag_string => "aaa bbb")

      assert_equal({"aaa" => 3, "bbb" => 3, "ccc" => 2, "ddd" => 1}, RelatedTagCalculator.calculate_from_sample("aaa", 10))
    end

    should "calculate related tags for multiple tag" do
      posts = []
      posts << FactoryGirl.create(:post, :tag_string => "aaa bbb ccc")
      posts << FactoryGirl.create(:post, :tag_string => "aaa bbb ccc ddd")
      posts << FactoryGirl.create(:post, :tag_string => "aaa eee fff")

      assert_equal({"aaa"=>2, "bbb"=>2, "ddd"=>1, "ccc"=>2}, RelatedTagCalculator.calculate_from_sample("aaa bbb", 10))
    end

    should "calculate typed related tags for a tag" do
      posts = []
      posts << FactoryGirl.create(:post, :tag_string => "aaa bbb art:ccc copy:ddd")
      posts << FactoryGirl.create(:post, :tag_string => "aaa bbb art:ccc")
      posts << FactoryGirl.create(:post, :tag_string => "aaa bbb")

      assert_equal({"ccc" => 2}, RelatedTagCalculator.calculate_from_sample("aaa", 10, Tag.categories.artist))
      assert_equal({"ddd" => 1}, RelatedTagCalculator.calculate_from_sample("aaa", 10, Tag.categories.copyright))
    end

    should "convert a hash into string format" do
      posts = []
      posts << FactoryGirl.create(:post, :tag_string => "aaa bbb ccc ddd")
      posts << FactoryGirl.create(:post, :tag_string => "aaa bbb ccc")
      posts << FactoryGirl.create(:post, :tag_string => "aaa bbb")

      tag = Tag.find_by_name("aaa")
      counts = RelatedTagCalculator.calculate_from_sample("aaa", 10)
      assert_equal("aaa 3 bbb 3 ccc 2 ddd 1", RelatedTagCalculator.convert_hash_to_string(counts))
    end
  end
end
