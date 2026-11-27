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
      setup do
        @pool = create(:pool, name: "cute_pool", description: "asd")
        @favgroup = create(:favorite_group)
      end

      should "refuse to convert to a pool or favgroup" do
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

      should "allow converting to a tag with a category prefix" do
        pool_bur = create(:bulk_update_request, script: "convert pool:cute_pool -> COPY:Cute_Series")
        favgroup_bur = create(:bulk_update_request, script: "convert favgroup:#{@favgroup.id} -> meta:cute_tag")

        assert_equal("convert {{pool:cute_pool}} -> [[cute_series|copyright:cute_series]]", pool_bur.processor.to_dtext)
        assert_equal(["cute_series"], pool_bur.tags)
        assert_equal("convert {{favgroup:#{@favgroup.id}}} -> [[cute_tag|meta:cute_tag]]", favgroup_bur.processor.to_dtext)
        assert_equal(["cute_tag"], favgroup_bur.tags)
      end

      should "refuse malformed or invalid tags with a category prefix" do
        create(:tag, name: "old_tag", is_deprecated: true)
        create(:artist, name: "some_artist")

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
        assert_invalid_bur(
          script: "convert pool:cute_pool -> meta:",
          errors: ["Can't convert {{pool:cute_pool}} -> {{meta:}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: "convert pool:cute_pool -> meta:foo bar",
          errors: ["Can't convert {{pool:cute_pool}} -> {{meta:foo bar}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: 'convert pool:cute_pool -> meta:"foo',
          errors: ['Can\'t convert {{pool:cute_pool}} -> {{meta:"foo}} (must convert a pool or favgroup to a tag)'],
        )
        assert_invalid_bur(
          script: "convert pool:cute_pool -> meta:pool:cute_pool",
          errors: ["Can't convert {{pool:cute_pool}} -> {{meta:pool:cute_pool}} (must convert a pool or favgroup to a tag)"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{@favgroup.id} -> meta:foo,bar",
          errors: ["Can't convert {{favgroup:#{@favgroup.id}}} -> [[foo,bar|meta:foo,bar]] ('foo,bar' cannot contain commas (','))"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{@favgroup.id} -> meta:old_tag",
          errors: ["Can't convert {{favgroup:#{@favgroup.id}}} -> [[old_tag|meta:old_tag]] ([[old_tag]] is deprecated)"],
        )
        assert_invalid_bur(
          script: "convert pool:cute_pool -> meta:some_artist",
          errors: ["Can't convert {{pool:cute_pool}} -> [[some_artist|meta:some_artist]] ([[some_artist]] has an artist entry)"],
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
        create(:tag, name: "old_tag", is_deprecated: true)

        assert_invalid_bur(
          script: "convert favgroup:#{@favgroup.id} -> foo,bar",
          errors: ["Can't convert {{favgroup:#{@favgroup.id}}} -> [[foo,bar]] ('foo,bar' cannot contain commas (','))"],
        )
        assert_invalid_bur(
          script: "convert favgroup:#{@favgroup.id} -> old_tag",
          errors: ["Can't convert {{favgroup:#{@favgroup.id}}} -> [[old_tag]] ([[old_tag]] is deprecated)"],
        )
      end
    end

    context "on approval" do
      context "for a pool" do
        setup do
          @description = "foo [[aaa]] bar"
          @pool = create(:pool, name: "cute_pool", description: @description)
          @post = create(:post, tag_string: "bar pool:cute_pool")
        end

        should "convert a pool to a new tag" do
          create_bur!("convert pool:cute_pool -> cute", @admin)

          assert_equal(true, @pool.reload.is_deleted?)
          assert_equal(@description, WikiPage.find_by_title("cute").body)
          assert_equal("bar cute", @post.reload.tag_string)
          assert_equal("This pool has been moved to [[cute]].", @pool.description)
        end

        should "convert a pool to an existing tag" do
          wiki = create(:wiki_page, title: "cute", body: "Exists.")

          create_bur!("convert pool:cute_pool -> cute", @admin)

          assert_equal(true, @pool.reload.is_deleted?)
          assert_equal("Exists.", wiki.reload.body)
          assert_equal("bar cute", @post.reload.tag_string)
          assert_equal("This pool has been moved to [[cute]].", @pool.description)
        end

        should "convert a pool to a deleted tag and undelete it" do
          wiki = create(:wiki_page, title: "cute", body: "", is_deleted: true)

          create_bur!("convert pool:cute_pool -> cute", @admin)

          assert_equal(true, @pool.reload.is_deleted?)
          assert_equal(false, wiki.reload.is_deleted?)
          assert_equal(@description, wiki.body)
          assert_equal("bar cute", @post.reload.tag_string)
          assert_equal("This pool has been moved to [[cute]].", @pool.description)
        end

        should "convert a pool to a new tag with a category prefix" do
          create_bur!("convert pool:cute_pool -> meta:cute", @admin)

          assert_equal(true, @pool.reload.is_deleted?)
          assert_equal(@description, WikiPage.find_by_title("cute").body)
          assert_nil(WikiPage.find_by_title("meta:cute"))
          assert_equal("bar cute", @post.reload.tag_string)
          assert_equal(true, Tag.find_by_name("cute").meta?)
          assert_equal("This pool has been moved to [[cute]].", @pool.description)
        end

        should "convert a pool to an existing tag and change its category" do
          tag = create(:tag, name: "cute", category: Tag.categories.general)

          create_bur!("convert pool:cute_pool -> meta:cute", @admin)

          assert_equal(true, @pool.reload.is_deleted?)
          assert_equal("bar cute", @post.reload.tag_string)
          assert_equal(true, tag.reload.meta?)
          assert_equal("This pool has been moved to [[cute]].", @pool.description)
        end

        should "not allow moderators to approve pool conversions" do
          assert_cannot_approve_bur("convert pool:cute_pool -> cute", create(:mod_user), "Can't approve convert {{pool:cute_pool}} -> [[cute]] (requires Admin)")
        end

        should "fail if the pool was modified after approval" do
          other_post = create(:post, tag_string: "bar")
          bur = assert_can_approve_bur("convert pool:cute_pool -> cute", @admin)

          travel(1.second) { @pool.update!(post_ids: [other_post.id]) }

          error = assert_raises(BulkUpdateRequest::Processor::Error) { bur.processor.process! }
          assert_equal("{{pool:cute_pool}} was modified after approval", error.message)
          assert_equal("failed", bur.reload.status)
          assert_equal("The #{bur.bulk_update_request_link} (forum ##{bur.forum_post.id}) failed: #{error.message}.", bur.forum_topic.forum_posts.last.body)
          assert_equal(false, @pool.reload.is_deleted?)
          assert_equal("bar", @post.reload.tag_string)
          assert_equal("bar", other_post.reload.tag_string)
        end
      end

      context "for a favgroup" do
        setup do
          @mod = create(:mod_user)
          @post = create(:post, tag_string: "bar")
          @favgroup = create(:favorite_group, creator: create(:gold_user), post_ids: [@post.id])
        end

        should "allow moderators to convert a favgroup to a tag" do
          create_bur!("convert favgroup:#{@favgroup.id} -> cute", @mod)

          assert_equal("bar cute", @post.reload.tag_string)
          assert_equal([@post.id], @favgroup.reload.post_ids)
        end

        should "allow moderators to convert a favgroup to a tag with a category prefix" do
          create_bur!("convert favgroup:#{@favgroup.id} -> meta:cute", @mod)

          assert_equal("bar cute", @post.reload.tag_string)
          assert_equal(true, Tag.find_by_name("cute").meta?)
          assert_equal([@post.id], @favgroup.reload.post_ids)
        end

        should "allow moderators to convert a favgroup to a large tag already in that category" do
          create(:tag, name: "large_meta", category: Tag.categories.meta, post_count: Tag::SMALL_TAG_THRESHOLD + 1)

          create_bur!("convert favgroup:#{@favgroup.id} -> meta:large_meta", @mod)

          assert_equal("bar large_meta", @post.reload.tag_string)
        end

        should "not allow moderators to change a large tag's category via favgroup conversion" do
          large_tag = create(:tag, name: "large_tag", category: Tag.categories.general, post_count: Tag::SMALL_TAG_THRESHOLD + 1)

          bur = assert_cannot_approve_bur("convert favgroup:#{@favgroup.id} -> meta:large_tag", @mod, "Can't approve convert {{favgroup:#{@favgroup.id}}} -> [[large_tag|meta:large_tag]] (requires Admin)")
          assert_equal(true, large_tag.reload.general?)

          assert_can_approve_bur(bur, @admin)
        end

        should "not allow moderators to alias a newly categorized tag from a favgroup conversion to a large general tag" do
          large_tag = create(:tag, name: "large_general", category: Tag.categories.general, post_count: Tag::SMALL_TAG_THRESHOLD + 1)
          bur = create(:bulk_update_request, script: "convert favgroup:#{@favgroup.id} -> char:new_char\nalias new_char -> large_general")

          %i[write write_multi delete delete_multi increment decrement].each { |method| Rails.cache.expects(method).never }
          assert_no_enqueued_jobs { assert_cannot_approve_bur(bur, @mod, "Can't approve create alias [[new_char]] -> [[large_general]] (requires Admin)") }

          assert_equal(true, large_tag.reload.general?)
          assert_nil(Tag.find_by_name("new_char"))
        end

        should "not allow moderators to approve large favgroup conversions" do
          favgroup = build(:favorite_group, post_ids: (1..(Tag::SMALL_TAG_THRESHOLD + 1)).to_a)
          favgroup.save!(validate: false)

          bur = assert_cannot_approve_bur("convert favgroup:#{favgroup.id} -> cute", @mod, "Can't approve convert {{favgroup:#{favgroup.id}}} -> [[cute]] ({{favgroup:#{favgroup.id}}} is too large; requires Admin)")
          assert_can_approve_bur(bur, @admin)
        end

        should "fail if the favgroup was modified after approval" do
          other_post = create(:post, tag_string: "bar")
          bur = assert_can_approve_bur("convert favgroup:#{@favgroup.id} -> cute", @mod)

          travel(1.second) { @favgroup.update!(post_ids: [other_post.id]) }

          error = assert_raises(BulkUpdateRequest::Processor::Error) { bur.processor.process! }
          assert_equal("{{favgroup:#{@favgroup.id}}} was modified after approval", error.message)
          assert_equal("failed", bur.reload.status)
          assert_equal("The #{bur.bulk_update_request_link} (forum ##{bur.forum_post.id}) failed: #{error.message}.", bur.forum_topic.forum_posts.last.body)
          assert_equal("bar", @post.reload.tag_string)
          assert_equal("bar", other_post.reload.tag_string)
        end

        should "fail if the favgroup was made private after approval" do
          bur = assert_can_approve_bur("convert favgroup:#{@favgroup.id} -> cute", @mod)

          @favgroup.update!(is_public: false)

          error = assert_raises(BulkUpdateRequest::Processor::Error) { bur.processor.process! }
          assert_equal("Can't convert {{favgroup:#{@favgroup.id}}} -> [[cute]] ({{favgroup:#{@favgroup.id}}} does not exist)", error.message)
          assert_equal("failed", bur.reload.status)
          assert_equal("The #{bur.bulk_update_request_link} (forum ##{bur.forum_post.id}) failed: #{error.message}.", bur.forum_topic.forum_posts.last.body)
          assert_equal("bar", @post.reload.tag_string)
        end
      end
    end
  end
end
