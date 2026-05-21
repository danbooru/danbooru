require "test_helper"

class DeprecateCommandTest < ActiveSupport::TestCase
  setup do
    @admin = create(:admin_user)
    CurrentUser.user = @admin
  end

  teardown do
    CurrentUser.user = nil
  end

  context "the deprecate command" do
    context "on creation" do
      should "not work for tags without a wiki page" do
        create(:tag, name: "no_wiki")

        assert_invalid_bur(
          script: "deprecate no_wiki",
          errors: ["Can't deprecate [[no_wiki]] (tag must have a wiki page)"],
        )
      end

      should "not work for tags with a deleted wiki page" do
        create(:tag, name: "deleted_wiki")
        create(:wiki_page, title: "deleted_wiki", is_deleted: true)

        assert_invalid_bur(
          script: "deprecate deleted_wiki",
          errors: ["Can't deprecate [[deleted_wiki]] (wiki page is deleted)"],
        )
      end
    end

    context "on approval" do
      should "deprecate the tag" do
        @tag = create(:tag, name: "bad_tag")
        create(:wiki_page, title: "bad_tag")
        @bur = create_bur!("deprecate bad_tag", @admin)

        assert_equal(true, @tag.reload.is_deprecated?)
      end

      should "remove implications and aliases" do
        @ti1 = create(:tag_implication, antecedent_name: "grey_hair", consequent_name: "old_woman")
        @ti2 = create(:tag_implication, antecedent_name: "my_literal_dog", consequent_name: "grey_hair")
        @ta = create(:tag_alias, antecedent_name: "silver_hair", consequent_name: "grey_hair")
        @wiki = create(:wiki_page, title: "grey_hair")
        @bur = create_bur!("deprecate grey_hair", @admin)

        assert_equal("deleted", @ti1.reload.status)
        assert_equal("deleted", @ti2.reload.status)
        assert_equal("deleted", @ta.reload.status)
        assert_equal("approved", @bur.reload.status)
      end
    end
  end
end
