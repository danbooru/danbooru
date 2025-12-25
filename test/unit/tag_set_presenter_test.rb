require "test_helper"

class TagSetPresenterTest < ActiveSupport::TestCase
  context "TagSetPresenter" do
    setup do
      FactoryBot.create(:tag, name: "bkub", category: Tag.categories.artist)
      FactoryBot.create(:tag, name: "chen", category: Tag.categories.character)
      FactoryBot.create(:tag, name: "cirno", category: Tag.categories.character)
      FactoryBot.create(:tag, name: "cirno_(tanned)", category: Tag.categories.character)
      FactoryBot.create(:tag, name: "solo", category: Tag.categories.general)
      FactoryBot.create(:tag, name: "touhou", category: Tag.categories.copyright)
      FactoryBot.create(:tag, name: "touhou_(pc-98)", category: Tag.categories.copyright)

      @categories = %w[copyright character artist meta general]
    end

    context "#split_tag_list_text method" do
      should "list all categories in order" do
        text = TagSetPresenter.new(%w[bkub chen cirno solo touhou]).split_tag_list_text(category_list: @categories)
        assert_equal("touhou \nchen cirno \nbkub \nsolo", text)
      end

      should "skip empty categories" do
        text = TagSetPresenter.new(%w[bkub solo]).split_tag_list_text(category_list: @categories)
        assert_equal("bkub \nsolo", text)
      end
    end

    context "the post page title" do
      should "work" do
        post_title = TagSetPresenter.new(%w[bkub cirno chen touhou]).humanized_essential_tag_string
        assert_equal("chen and cirno (touhou) drawn by bkub", post_title)
      end

      should "not display duplicate chartags" do
        post_title = TagSetPresenter.new(%w[bkub cirno cirno_(tanned) touhou]).humanized_essential_tag_string
        assert_equal("cirno (touhou) drawn by bkub", post_title)
      end

      should "not display duplicate copytags" do
        post_title = TagSetPresenter.new(%w[bkub cirno touhou_(pc-98) touhou]).humanized_essential_tag_string
        assert_equal("cirno (touhou) drawn by bkub", post_title)
      end

      should "work without a copyright tag" do
        post_title = TagSetPresenter.new(%w[bkub cirno cirno_(tanned)]).humanized_essential_tag_string
        assert_equal("cirno drawn by bkub", post_title)
      end

      should "work without an artist tag" do
        post_title = TagSetPresenter.new(%w[touhou cirno cirno_(tanned)]).humanized_essential_tag_string
        assert_equal("cirno (touhou)", post_title)
      end

      should "work without a chartag tag" do
        post_title = TagSetPresenter.new(%w[touhou bkub]).humanized_essential_tag_string
        assert_equal("touhou drawn by bkub", post_title)
      end

      should "work with only an artist tag" do
        post_title = TagSetPresenter.new(%w[bkub]).humanized_essential_tag_string
        assert_equal("drawn by bkub", post_title)
      end

      should "work with no relevant tags" do
        post_title = TagSetPresenter.new(%w[tagme]).humanized_essential_tag_string
        assert_equal("", post_title)
      end
    end
  end
end
