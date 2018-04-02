require "test_helper"

module MetaSearches
  class TagTest < ActionMailer::TestCase
    context "The tag metasearch" do
      setup do
        CurrentUser.user = FactoryBot.create(:user)
        CurrentUser.ip_addr = "127.0.0.1"
        FactoryBot.create(:post, :tag_string => "xxx")
        FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
        FactoryBot.create(:tag_implication, :antecedent_name => "ccc", :consequent_name => "ddd")
      end

      should "find the tag" do
        meta_search = MetaSearches::Tag.new(:name => "xxx")
        meta_search.load_all
        assert_equal(1, meta_search.tags.size)
        assert_equal("xxx", meta_search.tags.first.name)
      end

      should "find the alias" do
        meta_search = MetaSearches::Tag.new(:name => "aaa")
        meta_search.load_all
        assert_equal(1, meta_search.tag_aliases.size)
        assert_equal("aaa", meta_search.tag_aliases.first.antecedent_name)
      end

      should "find the implication" do
        meta_search = MetaSearches::Tag.new(:name => "ccc")
        meta_search.load_all
        assert_equal(1, meta_search.tag_implications.size)
        assert_equal("ccc", meta_search.tag_implications.first.antecedent_name)
      end
    end
  end
end
