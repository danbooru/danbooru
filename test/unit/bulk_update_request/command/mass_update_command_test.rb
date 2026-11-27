require "test_helper"

class MassUpdateCommandTest < ActiveSupport::TestCase
  setup do
    @admin = create(:admin_user)
    CurrentUser.user = @admin
  end

  teardown do
    CurrentUser.user = nil
  end

  context "the mass update command" do
    context "on creation" do
      should "not allow invalid searches in mass updates" do
        assert_invalid_bur(
          script: "mass update (foo -> bar",
          errors: ["Can't mass update {{(foo}} -> {{bar}} (the search {{(foo}} has a syntax error)"],
        )
      end

      should "not allow disallowed metatags in mass update destinations" do
        assert_invalid_bur(
          script: "update xyz -> favgroup:xyz",
          errors: ["Can't mass update [[xyz]] -> {{favgroup:xyz}} ('favgroup:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> -favgroup:xyz",
          errors: ["Can't mass update [[xyz]] -> {{-favgroup:xyz}} ('-favgroup:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> newfavgroup:xyz",
          errors: ["Can't mass update [[xyz]] -> {{newfavgroup:xyz}} ('newfavgroup:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> status:banned",
          errors: ["Can't mass update [[xyz]] -> {{status:banned}} ('status:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> score:5",
          errors: ["Can't mass update [[xyz]] -> {{score:5}} ('score:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> -rating:s",
          errors: ["Can't mass update [[xyz]] -> {{-rating:s}} ('-rating:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> -newpool:xyz",
          errors: ["Can't mass update [[xyz]] -> {{-newpool:xyz}} ('-newpool:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> -newfavgroup:xyz",
          errors: ["Can't mass update [[xyz]] -> {{-newfavgroup:xyz}} ('-newfavgroup:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> -char:",
          errors: ["Can't mass update [[xyz]] -> {{-char:}} ('-char:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> -char:newfavgroup:xyz",
          errors: ["Can't mass update [[xyz]] -> {{-char:newfavgroup:xyz}} ('-newfavgroup:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> -char:pool:xyz",
          errors: ["Can't mass update [[xyz]] -> {{-char:pool:xyz}} ('-pool:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> --pool:xyz",
          errors: ["Can't mass update [[xyz]] -> {{--pool:xyz}} ('--pool:' metatag is not allowed)"],
        )
      end

      should "not allow unclosed quotes on metatags in mass update destinations" do
        assert_invalid_bur(
          script: 'update xyz -> pool:"foo',
          errors: ["Can't mass update [[xyz]] -> {{pool:\"foo}} ('pool:' metatag has an unclosed quote)"],
        )
        assert_invalid_bur(
          script: 'update xyz -> -pool:"foo',
          errors: ["Can't mass update [[xyz]] -> {{-pool:\"foo}} ('-pool:' metatag has an unclosed quote)"],
        )
        assert_invalid_bur(
          script: 'update xyz -> newpool:"foo',
          errors: ["Can't mass update [[xyz]] -> {{newpool:\"foo}} ('newpool:' metatag has an unclosed quote)"],
        )
        assert_invalid_bur(
          script: 'update xyz -> newfavgroup:"foo',
          errors: ["Can't mass update [[xyz]] -> {{newfavgroup:\"foo}} ('newfavgroup:' metatag has an unclosed quote)"],
        )
        assert_invalid_bur(
          script: 'update xyz -> char:"foo',
          errors: ["Can't mass update [[xyz]] -> {{char:\"foo}} ('char:' metatag has an unclosed quote)"],
        )
      end

      should "not allow searches for pools that don't exist" do
        create(:pool, name: "cute_pool")

        assert_invalid_bur(
          script: "update pool:nonexistent -> foo",
          errors: ["Can't mass update {{pool:nonexistent}} -> [[foo]] ({{pool:nonexistent}} does not exist)"],
        )
        assert_invalid_bur(
          script: "update pool:cute_* -> foo",
          errors: ["Can't mass update {{pool:cute_*}} -> [[foo]] ({{pool:cute_*}} does not exist)"],
        )
        assert_invalid_bur(
          script: "update pool:any -> foo",
          errors: ["Can't mass update {{pool:any}} -> [[foo]] ({{pool:any}} does not exist)"],
        )
      end

      should "not allow searches for favgroups that don't exist or aren't public" do
        private_favgroup = create(:favorite_group, creator: create(:gold_user), is_public: false)

        assert_invalid_bur(
          script: "update favgroup:any -> foo",
          errors: ["Can't mass update {{favgroup:any}} -> [[foo]] ({{favgroup:any}} does not exist)"],
        )
        assert_invalid_bur(
          script: "update favgroup:#{private_favgroup.id} -> foo",
          errors: ["Can't mass update {{favgroup:#{private_favgroup.id}}} -> [[foo]] ({{favgroup:#{private_favgroup.id}}} does not exist)"],
        )
      end

      should "not allow order, limit, or random metatags in mass update searches" do
        pool = create(:pool, name: "cute_pool")

        assert_invalid_bur(
          script: "update bar order:score -> foo",
          errors: ["Can't mass update {{bar order:score}} -> [[foo]] ('order:' metatag is not allowed in the search)"],
        )
        assert_invalid_bur(
          script: "update ordpool:#{pool.name} -> foo",
          errors: ["Can't mass update {{ordpool:#{pool.name}}} -> [[foo]] ('ordpool:' metatag is not allowed in the search)"],
        )
        assert_invalid_bur(
          script: "update bar limit:5 -> foo",
          errors: ["Can't mass update {{bar limit:5}} -> [[foo]] ('limit:' metatag is not allowed in the search)"],
        )
      end

      should "not allow adding posts to or removing posts from pools that don't exist" do
        create(:pool, name: "cute_pool")

        assert_invalid_bur(
          script: "update xyz -> pool:cute_*",
          errors: ["Can't mass update [[xyz]] -> {{pool:cute_*}} ({{pool:cute_*}} does not exist)"],
        )
        assert_invalid_bur(
          script: "update xyz -> pool:none",
          errors: ["Can't mass update [[xyz]] -> {{pool:none}} ({{pool:none}} does not exist)"],
        )
        assert_invalid_bur(
          script: "update xyz -> newpool:cute_*",
          errors: ["Can't mass update [[xyz]] -> {{newpool:cute_*}} (pool names can't contain asterisks)"],
        )
      end

      should "allow searches for pools and favgroups that exist" do
        pool = create(:pool, name: "Cute_Pool")
        favgroup = create(:favorite_group)

        assert_equal(true, build(:bulk_update_request, script: "update pool:cute_pool -> foo").valid?)
        assert_equal(true, build(:bulk_update_request, script: "update pool:#{pool.id} -> foo").valid?)
        assert_equal(true, build(:bulk_update_request, script: "update bar -pool:cute_pool -> foo").valid?)
        assert_equal(true, build(:bulk_update_request, script: "update favgroup:#{favgroup.id} -> foo").valid?)
      end

      should "not allow changing the pool being searched" do
        pool = create(:pool, name: "cute_pool")

        assert_invalid_bur(
          script: "update pool:cute_pool -> -pool:#{pool.id}",
          errors: ["Can't mass update {{pool:cute_pool}} -> {{-pool:#{pool.id}}} (can't change the pool being searched; use convert instead to move a pool to a tag)"],
        )
      end

      should "allow safe post-edit metatags and regular tags with colons in mass update destinations" do
        create(:pool, name: "foo")
        create(:pool, name: "bar")

        assert_equal(true, build(:bulk_update_request, script: "update xyz -> rating:s source:https://example.com pool:foo -pool:bar newpool:baz parent:1 -parent:2 child:3 -child:4 char:a -char:b re:zero").valid?)
      end

      should "render simple tags as wiki links in dtext" do
        @bur = build(:bulk_update_request, script: "mass update bunny_ears -> rabbit_ears")
        create(:tag_alias, consequent_name: "bunny_ears", antecedent_name: "rabbit_ears")

        assert_equal("mass update [[bunny_ears]] -> [[rabbit_ears]]", @bur.processor.to_dtext)
      end

      should "link tags with category prefixes to the tag's wiki in dtext" do
        @bur = build(:bulk_update_request, script: "mass update aaa -> char:bbb")

        assert_equal("mass update [[aaa]] -> [[bbb|char:bbb]]", @bur.processor.to_dtext)
      end

      should "render complex queries as search links in dtext" do
        @bur = build(:bulk_update_request, script: "mass update source:imageboard -> source:Imageboard")

        assert_equal("mass update {{source:imageboard}} -> {{source:Imageboard}}", @bur.processor.to_dtext)
      end

      should "strip category prefixes from tags in the list of affected tags" do
        @bur = create(:bulk_update_request, script: "mass update aaa -> char:bbb ccc -ddd COPY:Eee rating:s")

        assert_equal(%w[aaa bbb ccc ddd eee], @bur.tags)
      end

      should "simulate category changes for subsequent lines without modifying the database or cache" do
        existing_tag = create(:tag, name: "existing_tag", category: Tag.categories.general, post_count: 10)
        create(:tag, name: "char_tag", category: Tag.categories.character, post_count: 10)
        create(:wiki_page, title: "existing_tag")
        create(:wiki_page, title: "char_tag")
        seq_before = Tag.connection.select_value("SELECT last_value FROM tags_id_seq")

        %i[write write_multi delete delete_multi increment decrement].each { |method| Rails.cache.expects(method).never }
        assert_no_enqueued_jobs do
          bur = build(:bulk_update_request, script: "mass update aaa -> char:existing_tag char:new_tag char:new_tag2\nimply existing_tag -> char_tag\ncategory new_tag -> copyright\ncategory new_tag2 -> meta")
          assert_equal(true, bur.valid?, bur.errors.full_messages.join(", "))
        end

        assert_equal(seq_before, Tag.connection.select_value("SELECT last_value FROM tags_id_seq"))
        assert_equal(true, existing_tag.reload.general?)
        assert_nil(Tag.find_by_name("new_tag"))
        assert_nil(Tag.find_by_name("new_tag2"))
      end

      should "safely ignore empty, invalid, or oversized tag names when simulating category changes" do
        bur = build(:bulk_update_request, script: "mass update aaa -> char: char:foo,bar char:#{"a" * 3000}")

        assert_equal(true, bur.valid?, bur.errors.full_messages.join(", "))
        assert_nil(Tag.find_by_name(""))
        assert_nil(Tag.find_by_name("foo,bar"))
      end
    end

    context "on approval" do
      should "update the tags" do
        @post = create(:post, tag_string: "foo")
        create_bur!("mass update foo -> bar baz", @admin)

        assert_equal("bar baz foo", @post.reload.tag_string)
        assert_equal(User.system, @post.versions.last.updater)
      end

      should "be case-sensitive" do
        @post = create(:post, source: "imageboard")
        create_bur!("mass update source:imageboard -> source:Imageboard", @admin)

        assert_equal("Imageboard", @post.reload.source)
      end

      context "with a pool" do
        setup do
          @post1 = create(:post, tag_string: "bar")
          @post2 = create(:post, tag_string: "bar")
          @pool = create(:pool, name: "cute_pool", post_ids: [@post1.id])
        end

        should "fail if a referenced pool or favgroup was modified after approval" do
          favgroup = create(:favorite_group, post_ids: [@post1.id])
          pool_bur = assert_can_approve_bur("update pool:cute_pool -> foo", @admin)
          favgroup_bur = assert_can_approve_bur("update favgroup:#{favgroup.id} -> baz", @admin)

          travel 1.second do
            @pool.update!(post_ids: [@post2.id])
            favgroup.update!(post_ids: [@post2.id])
          end

          pool_error = assert_raises(BulkUpdateRequest::Processor::Error) { pool_bur.processor.process! }
          assert_equal("{{pool:cute_pool}} was modified after approval", pool_error.message)
          assert_equal("failed", pool_bur.reload.status)

          favgroup_error = assert_raises(BulkUpdateRequest::Processor::Error) { favgroup_bur.processor.process! }
          assert_equal("{{favgroup:#{favgroup.id}}} was modified after approval", favgroup_error.message)
          assert_equal("failed", favgroup_bur.reload.status)

          assert_equal("bar", @post1.reload.tag_string)
          assert_equal("bar", @post2.reload.tag_string)
        end

        should "compare against the approval time when processing a BUR that isn't marked as processing" do
          bur = assert_can_approve_bur("update pool:cute_pool -> foo", @admin)
          bur.update!(status: "failed")
          travel(1.second) { @pool.update!(description: "changed") }

          travel(2.seconds) do
            error = assert_raises(BulkUpdateRequest::Processor::Error) { bur.processor.process! }
            assert_equal("{{pool:cute_pool}} was modified after approval", error.message)
          end
          assert_equal("bar", @post1.reload.tag_string)
        end

        should "not update posts added to the pool after the pool was checked" do
          bur = assert_can_approve_bur("update pool:cute_pool -> foo", @admin)

          # Simulate a user adding a post to the pool right after the pool is checked for modifications. update_columns
          # is used so the edit is invisible to the updated_at check, as if it happened after the check.
          Pool.stubs(:find_by_name).with { @pool.update_columns(post_ids: [@post1.id, @post2.id]) }.returns(@pool) # rubocop:disable Rails/SkipsModelValidations
          bur.processor.process!

          assert_equal("approved", bur.reload.status)
          assert_equal("bar foo", @post1.reload.tag_string)
          assert_equal("bar", @post2.reload.tag_string)
        end
      end

      context "by a moderator" do
        setup do
          @mod = create(:mod_user)
          @post = create(:post, tag_string: "bar")
        end

        should "allow adding a tag to a list of post IDs" do
          other_post = create(:post, tag_string: "bar")
          unchanged_post = create(:post, tag_string: "bar")
          create(:tag, name: "large_tag", post_count: Tag::SMALL_TAG_THRESHOLD + 1)

          create_bur!("mass update id:#{@post.id},#{other_post.id} -> large_tag", @mod)

          assert_equal("bar large_tag", @post.reload.tag_string)
          assert_equal("bar large_tag", other_post.reload.tag_string)
          assert_equal("bar", unchanged_post.reload.tag_string)
        end

        should "allow adding a tag with a category prefix to a list of post IDs" do
          create_bur!("mass update id:#{@post.id} -> char:new_char", @mod)

          assert_equal("bar new_char", @post.reload.tag_string)
          assert_equal(true, Tag.find_by_name("new_char").character?)
        end

        should "not allow changing a large tag's category through a list of post IDs" do
          create(:tag, name: "large_tag", category: Tag.categories.general, post_count: Tag::SMALL_TAG_THRESHOLD + 1)

          bur = assert_cannot_approve_bur("mass update id:#{@post.id} -> char:large_tag", @mod, "Can't approve mass update {{id:#{@post.id}}} -> [[large_tag|char:large_tag]] (requires Admin)")
          assert_can_approve_bur(bur, @admin)
        end

        should "not allow approving other mass updates" do
          too_many_ids = (1..(Tag::SMALL_TAG_THRESHOLD + 1)).to_a.join(",")

          assert_cannot_approve_bur("mass update bar -> foo", @mod, /requires Admin/)
          assert_cannot_approve_bur("mass update id:#{@post.id} bar -> foo", @mod, /requires Admin/)
          assert_cannot_approve_bur("mass update -id:#{@post.id} -> foo", @mod, /requires Admin/)
          assert_cannot_approve_bur("mass update id:>#{@post.id} -> foo", @mod, /requires Admin/)
          assert_cannot_approve_bur("mass update id:#{@post.id}..#{@post.id + 10} -> foo", @mod, /requires Admin/)
          assert_cannot_approve_bur("mass update id:#{too_many_ids} -> foo", @mod, /requires Admin/)
          assert_cannot_approve_bur("mass update id:#{@post.id} -> foo baz", @mod, /requires Admin/)
          assert_cannot_approve_bur("mass update id:#{@post.id} -> -bar", @mod, /requires Admin/)
          assert_cannot_approve_bur("mass update id:#{@post.id} -> rating:e", @mod, /requires Admin/)
          assert_cannot_approve_bur("mass update id:#{@post.id} -> parent:#{@post.id}", @mod, /requires Admin/)
        end
      end
    end
  end
end
