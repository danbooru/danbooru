require "test_helper"

class TagNormalizerTest < ActiveSupport::TestCase
  def assert_normalizes(terms, tag)
    assert_equal(terms.sort, TagNormalizer.normalize(tag))
  end

  context "normalize_tag" do
    should "work" do
      assert_normalizes(["アークナイツ", "版深夜の真剣お絵かき60分一本勝負", "アークナイツ版深夜の真剣お絵かき60分一本勝負"], "アークナイツ版深夜の真剣お絵かき60分一本勝負")
      assert_normalizes(["アークナイツ"], "アークナイツ10000users入り")
      assert_normalizes(["アークナイツ"], "アークナイツ")
    end
  end
end
