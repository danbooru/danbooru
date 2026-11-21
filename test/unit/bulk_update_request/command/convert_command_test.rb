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
      should "refuse to convert to a pool or favgroup" do
        @pool = create(:pool, name: "cute_pool", description: "asd")
        @favgroup = create(:favorite_group)

        assert_invalid_bur(
          script: "convert cute -> pool:cute_pool",
          errors: ["Can't convert {{cute}} -> {{pool:cute_pool}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: "convert pool:cute_pool -> pool:cute_pool2",
          errors: ["Can't convert {{pool:cute_pool}} -> {{pool:cute_pool2}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{@favgroup.id} -> pool:cute_pool",
          errors: ["Can't convert {{favgroup:#{@favgroup.id}}} -> {{pool:cute_pool}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: "convert tag1 -> favgroup:#{@favgroup.id}",
          errors: ["Can't convert {{tag1}} -> {{favgroup:#{@favgroup.id}}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{@favgroup.id} -> newpool:cute_pool2",
          errors: ["Can't convert {{favgroup:#{@favgroup.id}}} -> {{newpool:cute_pool2}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{@favgroup.id} -> newfavgroup:cute_fg",
          errors: ["Can't convert {{favgroup:#{@favgroup.id}}} -> {{newfavgroup:cute_fg}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: "convert pool:cute_pool -> newfavgroup:cute_fg",
          errors: ["Can't convert {{pool:cute_pool}} -> {{newfavgroup:cute_fg}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{@favgroup.id} -> newfavgroup:",
          errors: ["Can't convert {{favgroup:#{@favgroup.id}}} -> {{newfavgroup:}} (must convert a pool or favgroup to a tag)"],
        )
      end

      should "refuse to convert wildcard pools" do
        create(:pool, name: "cute_pool")

        assert_invalid_bur(
          script: "convert pool:cute_* -> cute",
          errors: ["Can't convert {{pool:cute_*}} -> [[cute]] ({{pool:cute_*}} does not exist)"],
        )
        assert_invalid_bur(
          script: "convert pool:any -> cute",
          errors: ["Can't convert {{pool:any}} -> [[cute]] ({{pool:any}} does not exist)"],
        )
      end

      should "refuse to convert a tag to another tag" do
        assert_invalid_bur(
          script: "convert tag1 -> tag2",
          errors: ["Can't convert {{tag1}} -> {{tag2}} (must convert a pool or favgroup to a tag)"],
        )
      end

      should "refuse to accept too many arguments" do
        assert_invalid_bur(
          script: "convert pool:1 -> tag2 pool:2",
          errors: ["Can't convert {{pool:1}} -> {{tag2 pool:2}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: "convert tag1 pool:1 -> tag2",
          errors: ["Can't convert {{tag1 pool:1}} -> {{tag2}} (must convert a pool or favgroup to a tag)"],
        )
      end

      should "refuse to convert to a tag with a category prefix" do
        @pool = create(:pool, name: "cute_pool", description: "asd")
        @favgroup = create(:favorite_group)

        assert_invalid_bur(
          script: "convert pool:cute_pool -> copy:cute_series",
          errors: ["Can't convert {{pool:cute_pool}} -> [[copy:cute_series]] (change the category in a separate line)"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{@favgroup.id} -> copy:cute_series",
          errors: ["Can't convert {{favgroup:#{@favgroup.id}}} -> [[copy:cute_series]] (change the category in a separate line)"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{@favgroup.id} -> (copy:cute_series)",
          errors: ["Can't convert {{favgroup:#{@favgroup.id}}} -> {{(copy:cute_series)}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{@favgroup.id} -> ~copy:cute_series",
          errors: ["Can't convert {{favgroup:#{@favgroup.id}}} -> {{~copy:cute_series}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: "convert pool:cute_pool -> (copy:cute_series)",
          errors: ["Can't convert {{pool:cute_pool}} -> {{(copy:cute_series)}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{@favgroup.id} -> (cute)",
          errors: ["Can't convert {{favgroup:#{@favgroup.id}}} -> [[(cute)]] ('(cute)' cannot begin with a '(')"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{@favgroup.id} -> ~cute",
          errors: ["Can't convert {{favgroup:#{@favgroup.id}}} -> [[~cute]] ('~cute' cannot begin with a '~')"],
        )
      end

      should "refuse to convert a nonexistent or private favgroup" do
        favgroup = create(:private_favorite_group)

        assert_invalid_bur(
          script: "convert favgroup:999999 -> cute",
          errors: ["Can't convert {{favgroup:999999}} -> [[cute]] ({{favgroup:999999}} does not exist)"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{favgroup.id} -> cute",
          errors: ["Can't convert {{favgroup:#{favgroup.id}}} -> [[cute]] ({{favgroup:#{favgroup.id}}} does not exist)"],
        )
      end

      should "refuse to convert to an invalid or deprecated tag" do
        favgroup = create(:favorite_group)
        create(:tag, name: "old_tag", is_deprecated: true)

        assert_invalid_bur(
          script: "convert favgroup:#{favgroup.id} -> foo,bar",
          errors: ["Can't convert {{favgroup:#{favgroup.id}}} -> [[foo,bar]] ('foo,bar' cannot contain commas (','))"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{favgroup.id} -> old_tag",
          errors: ["Can't convert {{favgroup:#{favgroup.id}}} -> [[old_tag]] ([[old_tag]] is deprecated)"],
        )
      end
    end

    context "on approval" do
      should "convert a pool to a new tag" do
        description = "foo [[aaa]] bar"
        @pool = create(:pool, name: "cute_pool", description: description)
        @post = create(:post, tag_string: "bar pool:cute_pool")

        @bur = create_bur!("convert pool:cute_pool -> cute", @admin)

        wiki = WikiPage.find_by_title("cute")
        assert_equal(true, @pool.reload.is_deleted?)
        assert_equal(description, wiki.body)
        assert_equal("bar cute", @post.reload.tag_string)
        assert_equal("This pool has been moved to [[cute]].", @pool.description)
      end

      should "convert a pool to an existing tag" do
        description = "foo [[aaa]] bar"
        @pool = create(:pool, name: "cute_pool", description: description)
        @post = create(:post, tag_string: "bar pool:cute_pool")
        @wiki = create(:wiki_page, title: "cute", body: "Exists.")

        @bur = create_bur!("convert pool:cute_pool -> cute", @admin)

        assert_equal(true, @pool.reload.is_deleted?)
        assert_equal("Exists.", @wiki.body)
        assert_equal("bar cute", @post.reload.tag_string)
        assert_equal("This pool has been moved to [[cute]].", @pool.description)
      end

      should "convert a pool to a deleted tag and undelete it" do
        description = "foo [[aaa]] bar"
        @pool = create(:pool, name: "cute_pool", description: description)
        @post = create(:post, tag_string: "bar pool:cute_pool")
        @wiki = create(:wiki_page, title: "cute", body: "", is_deleted: true)

        @bur = create_bur!("convert pool:cute_pool -> cute", @admin)

        assert_equal(true, @pool.reload.is_deleted?)
        assert_equal(false, @wiki.reload.is_deleted?)
        assert_equal(description, @wiki.body)
        assert_equal("bar cute", @post.reload.tag_string)
        assert_equal("This pool has been moved to [[cute]].", @pool.description)
      end

      should "allow moderators to convert a favgroup to a tag" do
        mod = create(:mod_user)
        post = create(:post, tag_string: "bar")
        favgroup = create(:favorite_group, post_ids: [post.id])

        create_bur!("convert favgroup:#{favgroup.id} -> cute", mod)

        assert_equal("bar cute", post.reload.tag_string)
        assert_equal([post.id], favgroup.reload.post_ids)
      end

      should "not allow moderators to approve pool conversions" do
        mod = create(:mod_user)
        create(:pool, name: "cute_pool", description: "asd")

        bur = create(:bulk_update_request, script: "convert pool:cute_pool -> cute")
        bur.approve!(mod)
        assert_includes(bur.errors.full_messages, "Can't approve convert {{pool:cute_pool}} -> [[cute]] (requires Admin)")
        assert_equal("pending", bur.reload.status)
      end

      should "not allow moderators to approve large favgroup conversions" do
        mod = create(:mod_user)
        favgroup = build(:favorite_group, post_ids: (1..(Tag::SMALL_TAG_THRESHOLD + 1)).to_a)
        favgroup.save!(validate: false)

        bur = create(:bulk_update_request, script: "convert favgroup:#{favgroup.id} -> cute")

        bur.approve!(mod)
        assert_includes(bur.errors.full_messages, "Can't approve convert {{favgroup:#{favgroup.id}}} -> [[cute]] ({{favgroup:#{favgroup.id}}} is too large; requires Admin)")
        assert_equal("pending", bur.reload.status)

        bur.approve!(@admin)
        assert_equal("processing", bur.reload.status)
      end
    end
  end
end
