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
        @bur = build(:bulk_update_request, script: "category hello -> artist")

        assert_equal(false, @bur.valid?)
        assert_equal(["Can't change the category of [[hello]] to artist ([[hello]] doesn't exist)"], @bur.errors[:base])
      end

      should "not allow changing a tag to an invalid category" do
        @tag = create(:tag, name: "foo")
        @bur = build(:bulk_update_request, script: "category foo -> bar")

        assert_not(@bur.valid?)
        assert_equal(["Can't change the category of [[foo]] to bar (bar is not a valid category)"], @bur.errors.full_messages)
      end

      should "not allow changing a tag to its own category" do
        @tag = create(:tag, name: "touhou", category: Tag.categories.copyright)
        @bur = build(:bulk_update_request, script: "category touhou -> copyright")

        assert_not(@bur.valid?)
        assert_equal(["Can't change the category of [[touhou]] to copyright ([[touhou]] is already in that category)"], @bur.errors.full_messages)
      end

      should "not allow changing an artist tag's category" do
        @tag = create(:tag, name: "noizave", category: Tag.categories.artist)
        @artist = create(:artist, name: @tag.name)
        @bur = build(:bulk_update_request, script: "category noizave -> general")

        assert_not(@bur.valid?)
        assert_equal(["Can't change the category of [[noizave]] to general ([[noizave]] must be an Artist tag)"], @bur.errors.full_messages)
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
