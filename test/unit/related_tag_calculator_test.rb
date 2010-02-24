require File.dirname(__FILE__) + '/../test_helper'

class RelatedTagCalculatorTest < ActiveSupport::TestCase
  context "A related tag calculator" do
    should "calculate related tags for a tag" do
      posts = []
      posts << Factory.create(:post, :tag_string => "aaa bbb ccc ddd")
      posts << Factory.create(:post, :tag_string => "aaa bbb ccc")
      posts << Factory.create(:post, :tag_string => "aaa bbb")
      
      tag = Tag.find_by_name("aaa")
      calculator = RelatedTagCalculator.new
      assert_equal({"bbb" => 3, "ccc" => 2, "ddd" => 1}, calculator.calculate_from_sample("aaa"))
    end

    should "calculate related tags for a tag" do
      posts = []
      posts << Factory.create(:post, :tag_string => "aaa bbb art:ccc copy:ddd")
      posts << Factory.create(:post, :tag_string => "aaa bbb art:ccc")
      posts << Factory.create(:post, :tag_string => "aaa bbb")
      
      tag = Tag.find_by_name("aaa")
      calculator = RelatedTagCalculator.new
      assert_equal({"ccc" => 2}, calculator.calculate_from_sample("aaa", Tag.categories.artist))
      calculator = RelatedTagCalculator.new
      assert_equal({"ddd" => 1}, calculator.calculate_from_sample("aaa", Tag.categories.copyright))
    end
    
    should "convert a hash into string format" do
      posts = []
      posts << Factory.create(:post, :tag_string => "aaa bbb ccc ddd")
      posts << Factory.create(:post, :tag_string => "aaa bbb ccc")
      posts << Factory.create(:post, :tag_string => "aaa bbb")
      
      tag = Tag.find_by_name("aaa")
      calculator = RelatedTagCalculator.new
      counts = calculator.calculate_from_sample("aaa")
      assert_equal("bbb 3 ccc 2 ddd 1", calculator.convert_hash_to_string(counts))
    end
  end
end
