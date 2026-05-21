require "test_helper"

class CategoryCommandTest < ActiveSupport::TestCase
  setup do
    @admin = create(:admin_user)
    CurrentUser.user = @admin
  end

  teardown do
    CurrentUser.user = nil
  end

  context "the category command" do
    context "on creation" do
      should "fail if the tag doesn't already exist" do
        assert_invalid_bur(
          script: "category hello -> artist",
          errors: ["Can't change the category of [[hello]] to artist ([[hello]] doesn't exist)"],
        )
      end

      should "not allow changing a tag to an invalid category" do
        create(:tag, name: "foo")

        assert_invalid_bur(
          script: "category foo -> bar",
          errors: ["Can't change the category of [[foo]] to bar (bar is not a valid category)"],
        )
      end

      should "not allow changing a tag to its own category" do
        create(:tag, name: "touhou", category: Tag.categories.copyright)

        assert_invalid_bur(
          script: "category touhou -> copyright",
          errors: ["Can't change the category of [[touhou]] to copyright ([[touhou]] is already in that category)"],
        )
      end

      should "not allow changing an artist tag's category" do
        @tag = create(:tag, name: "noizave", category: Tag.categories.artist)
        create(:artist, name: @tag.name)

        assert_invalid_bur(
          script: "category noizave -> general",
          errors: ["Can't change the category of [[noizave]] to general ([[noizave]] must be an Artist tag)"],
        )
      end
    end

    context "on approval" do
      should "change the tag's category" do
        @tag = create(:tag, name: "hello")
        @bur = create_bur!("category hello -> artist", @admin)

        assert_equal(true, @bur.valid?)
        assert_equal(true, @tag.reload.artist?)
        assert_equal("approved", @bur.reload.status)
      end

      should "update the tag category counts for all posts with the tag" do
        post1 = create(:post, tag_string: "chen")
        post2 = create(:post, tag_string: "chen")

        assert_equal(1, post1.tag_count_general)
        assert_equal(0, post1.tag_count_character)
        assert_equal(1, post2.tag_count_general)
        assert_equal(0, post2.tag_count_character)

        create_bur!("category chen -> character", @admin)
        post1.reload
        post2.reload

        assert_equal(0, post1.tag_count_general)
        assert_equal(1, post1.tag_count_character)
        assert_equal(0, post2.tag_count_general)
        assert_equal(1, post2.tag_count_character)
      end
    end
  end
end
