require 'test_helper'

class TagSetPresenterTest < ActiveSupport::TestCase
  context "TagSetPresenter" do
    setup do
      FactoryBot.create(:tag, name: "bkub", category: Tag.categories.artist)
      FactoryBot.create(:tag, name: "chen", category: Tag.categories.character)
      FactoryBot.create(:tag, name: "cirno", category: Tag.categories.character)
      FactoryBot.create(:tag, name: "solo", category: Tag.categories.general)
      FactoryBot.create(:tag, name: "touhou", category: Tag.categories.copyright)

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
  end
end
