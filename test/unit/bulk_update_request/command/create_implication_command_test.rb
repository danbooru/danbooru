require "test_helper"

class CreateImplicationCommandTest < ActiveSupport::TestCase
  setup do
    @admin = create(:admin_user)
    CurrentUser.user = @admin
  end

  teardown do
    CurrentUser.user = nil
  end

  context "the create implication command" do
    context "on creation" do
      should "succeed for an empty tag without a wiki" do
        @bur = create(:bulk_update_request, script: "imply a -> b")
        assert_equal(true, @bur.valid?)
      end

      should "fail for a populated tag without a wiki" do
        create(:tag, name: "a", post_count: 10)
        create(:tag, name: "b", post_count: 100)

        assert_invalid_bur(
          script: "imply a -> b",
          errors: ["Can't create implication [[a]] -> [[b]] ([[a]] must have a wiki page; [[b]] must have a wiki page)"],
        )
      end

      should "fail for an implication that is redundant with an existing implication" do
        create(:tag_implication, antecedent_name: "a", consequent_name: "b")
        create(:tag_implication, antecedent_name: "b", consequent_name: "c")

        assert_invalid_bur(
          script: "imply a -> c",
          errors: ["Can't create implication [[a]] -> [[c]] (a already implies c through another implication)"],
        )
      end

      should "fail for an implication that is a duplicate of an existing implication" do
        create(:tag_implication, antecedent_name: "a", consequent_name: "b")

        assert_invalid_bur(
          script: "imply a -> b",
          errors: ["Can't create implication [[a]] -> [[b]] (Implication already exists)"],
        )
      end

      should "fail for an implication that is redundant with another implication in the same BUR" do
        create(:tag_implication, antecedent_name: "b", consequent_name: "c")

        assert_invalid_bur(
          script: "imply a -> b\nimply a -> c",
          errors: ["Can't create implication [[a]] -> [[c]] (a already implies c through another implication)"],
        )
      end

      should "fail for an implication between tags of different categories" do
        create(:tag, name: "hatsune_miku", category: Tag.categories.character)
        create(:tag, name: "vocaloid", category: Tag.categories.copyright)
        create(:wiki_page, title: "hatsune_miku")
        create(:wiki_page, title: "vocaloid")

        assert_invalid_bur(
          script: "imply hatsune_miku -> vocaloid",
          errors: ["Can't create implication [[hatsune_miku]] -> [[vocaloid]] (Can't imply a character tag to a copyright tag)"],
        )
      end

      should "fail for a child tag that is too small" do
        @t1 = create(:tag, name: "white_shirt", post_count: 9)
        create(:tag, name: "shirt", post_count: 1_000_000)
        create(:wiki_page, title: "white_shirt")
        create(:wiki_page, title: "shirt")

        assert_invalid_bur(
          script: "imply white_shirt -> shirt",
          errors: ["Can't create implication [[white_shirt]] -> [[shirt]] ([[white_shirt]] must have at least 10 posts)"],
        )

        @t1.update!(post_count: 99)
        assert_invalid_bur(
          script: "imply white_shirt -> shirt",
          errors: ["Can't create implication [[white_shirt]] -> [[shirt]] ([[white_shirt]] must have at least 100 posts)"],
        )
      end

      should "display the correct amount of required posts" do
        create(:tag, name: "speech_bubble_censor", post_count: 20)
        create(:wiki_page, title: "speech_bubble_censor")
        create(:tag, name: "speech_bubble", post_count: 202_174)
        create(:wiki_page, title: "speech_bubble")

        assert_invalid_bur(
          script: "imply speech_bubble_censor -> speech_bubble",
          errors: ["Can't create implication [[speech_bubble_censor]] -> [[speech_bubble]] ([[speech_bubble_censor]] must have at least 21 posts)"],
        )
      end

      should "fail if the antecedent name is invalid" do
        assert_invalid_bur(
          script: "imply tag_ -> tag",
          errors: ["Can't create implication [[tag_]] -> [[tag]] ('tag_' cannot end with an underscore)"],
        )
      end

      should "fail if the consequent name is invalid" do
        assert_invalid_bur(
          script: "imply tag -> tag_",
          errors: ["Can't create implication [[tag]] -> [[tag_]] ('tag_' cannot end with an underscore)"],
        )
      end
    end

    context "on approval" do
      should "create an implication" do
        @bur = create_bur!("create implication foo -> bar", @admin)

        @implication = TagImplication.find_by(antecedent_name: "foo", consequent_name: "bar")
        assert_equal(true, @implication.present?)
        assert_equal(true, @implication.is_active?)
        assert_equal("approved", @bur.reload.status)
      end

      should "assign the right category to a new umbrella tag" do
        create(:tag, name: "daniel_booru_(bald)", category: Tag.categories.character)
        create(:wiki_page, title: "daniel_booru_(bald)")
        create(:wiki_page, title: "daniel_booru")
        @bur = create_bur!("create implication daniel_booru_(bald) -> daniel_booru", @admin)

        @implication = TagImplication.find_by(antecedent_name: "daniel_booru_(bald)", consequent_name: "daniel_booru")
        assert_equal(true, @implication.present?)
        assert_equal(true, @implication.is_active?)
        assert_equal("approved", @bur.reload.status)
        assert_equal(Tag.categories.character, Tag.find_by_name("daniel_booru").category)
      end
    end
  end
end
