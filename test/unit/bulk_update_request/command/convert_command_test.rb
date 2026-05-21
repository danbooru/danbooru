require "test_helper"

class ConvertCommandTest < ActiveSupport::TestCase
  setup do
    @admin = create(:admin_user)
    CurrentUser.user = @admin
  end

  teardown do
    CurrentUser.user = nil
  end

  context "the convert command" do
    context "on creation" do
      should "refuse to convert a tag without wiki to a new pool" do
        @post = create(:post, tag_string: "bar cute")
        @wiki = create(:wiki_page, title: "cute", body: "", is_deleted: true)

        assert_invalid_bur(
          script: "convert cute -> pool:cute",
          errors: ["Can't convert [[cute]] -> {{pool:cute}} (either the tag or the pool must have a description)"],
        )
      end

      should "refuse to convert a pool to another pool" do
        @pool = create(:pool, name: "cute", description: "asd")
        assert_invalid_bur(
          script: "convert pool:cute -> pool:cute2",
          errors: ["Can't convert {{pool:cute}} -> {{pool:cute2}} (convert takes exactly one pool and one tag)"],
        )
      end

      should "refuse to convert a tag to another tag" do
        assert_invalid_bur(
          script: "convert tag1 -> tag2",
          errors: ["Can't convert {{tag1}} -> {{tag2}} (convert takes exactly one pool and one tag)"],
        )
      end

      should "refuse to accept too many arguments on the right side" do
        assert_invalid_bur(
          script: "convert tag1 -> tag2 pool:1",
          errors: ["Can't convert {{tag1}} -> {{tag2 pool:1}} (convert takes exactly one pool and one tag)"],
        )
      end

      should "refuse to accept too many arguments on the left side" do
        assert_invalid_bur(
          script: "convert tag1 pool:1 -> tag2",
          errors: ["Can't convert {{tag1 pool:1}} -> {{tag2}} (convert takes exactly one pool and one tag)"],
        )
      end
    end

    context "on approval" do
      should "convert a pool to a new tag" do
        description = "foo [[aaa]] bar"
        @pool = create(:pool, name: "cute", description: description)
        @post = create(:post, tag_string: "bar pool:cute")

        @bur = create_bur!("convert pool:cute -> cute", @admin)

        wiki = WikiPage.find_by_title("cute")
        assert_equal(true, @pool.reload.is_deleted?)
        assert_equal(description, wiki.body)
        assert_equal("bar cute", @post.reload.tag_string)
        assert_equal("This pool has been moved to [[cute]].", @pool.description)
      end

      should "convert a pool to an existing tag" do
        description = "foo [[aaa]] bar"
        @pool = create(:pool, name: "cute", description: description)
        @post = create(:post, tag_string: "bar pool:cute")
        @wiki = create(:wiki_page, title: "cute", body: "Exists.")

        @bur = create_bur!("convert pool:cute -> cute", @admin)

        assert_equal(true, @pool.reload.is_deleted?)
        assert_equal("Exists.", @wiki.body)
        assert_equal("bar cute", @post.reload.tag_string)
        assert_equal("This pool has been moved to [[cute]].", @pool.description)
      end

      should "convert a pool to a deleted tag and undelete it" do
        description = "foo [[aaa]] bar"
        @pool = create(:pool, name: "cute", description: description)
        @post = create(:post, tag_string: "bar pool:cute")
        @wiki = create(:wiki_page, title: "cute", body: "", is_deleted: true)

        @bur = create_bur!("convert pool:cute -> cute", @admin)

        assert_equal(true, @pool.reload.is_deleted?)
        assert_equal(false, @wiki.reload.is_deleted?)
        assert_equal(description, @wiki.body)
        assert_equal("bar cute", @post.reload.tag_string)
        assert_equal("This pool has been moved to [[cute]].", @pool.description)
      end

      should "convert a tag to a new pool" do
        description = "foo [[aaa]] bar"
        @post = create(:post, tag_string: "bar cute")
        @wiki = create(:wiki_page, title: "cute", body: description)

        @bur = create_bur!("convert cute -> pool:cute", @admin)

        pool = Pool.find_by_name("cute")
        assert_equal(description, pool.description)
        assert_equal("bar", @post.reload.tag_string)
        assert_equal([@post.id], pool.post_ids)
        assert_equal("This tag has been moved to {{pool:cute}}.", @wiki.reload.body)
      end

      should "convert a tag to an existing pool" do
        @post = create(:post, tag_string: "bar cute")
        @wiki = create(:wiki_page, title: "cute", body: "a b c")
        other_post = create(:post)
        @pool = create(:pool, name: "cute", description: "d e f", is_deleted: true, post_ids: [other_post.id])

        @bur = create_bur!("convert cute -> pool:cute", @admin)

        assert_equal("d e f", @pool.reload.description)
        assert_equal(false, @pool.is_deleted?)
        assert_equal("bar", @post.reload.tag_string)
        assert_equal([other_post.id, @post.id], @pool.post_ids)
        assert_equal("This tag has been moved to {{pool:cute}}.", @wiki.reload.body)
      end
    end
  end
end
