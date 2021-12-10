require 'test_helper'

class BulkUpdateRequestTest < ActiveSupport::TestCase
  def create_bur!(script, approver)
    bur = create(:bulk_update_request, script: script)
    bur.approve!(approver)
    perform_enqueued_jobs
    bur
  end

  context "a bulk update request" do
    setup do
      @admin = FactoryBot.create(:admin_user)
      CurrentUser.user = @admin
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should_eventually "parse tags with tag type prefixes inside the script" do
      @bur = create(:bulk_update_request, script: "mass update aaa -> artist:bbb")
      assert_equal(%w[aaa bbb], @bur.tags)
    end

    context "when approving a BUR" do
      context "the category command" do
        should "change the tag's category" do
          @tag = create(:tag, name: "hello")
          @bur = create_bur!("category hello -> artist", @admin)

          assert_equal(true, @bur.valid?)
          assert_equal(true, @tag.reload.artist?)
          assert_equal("approved", @bur.reload.status)
        end

        should "fail if the tag doesn't already exist" do
          @bur = build(:bulk_update_request, script: "category hello -> artist")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't change category hello -> artist (the 'hello' tag doesn't exist)"], @bur.errors[:base])
        end
      end

      context "the create alias command" do
        setup do
          @wiki = create(:wiki_page, title: "foo")
          @artist = create(:artist, name: "foo")
          @bur = create_bur!("create alias foo -> bar", @admin)
        end

        should "create an alias" do
          @alias = TagAlias.find_by(antecedent_name: "foo", consequent_name: "bar")
          assert_equal(true, @alias.present?)
          assert_equal(true, @alias.is_active?)
          assert_equal("approved", @bur.reload.status)
        end

        should "rename the aliased tag's artist entry and wiki page" do
          assert_equal("bar", @artist.reload.name)
          assert_equal("bar", @wiki.reload.title)
        end

        should "move any active aliases from the old tag to the new tag" do
          @bur1 = create_bur!("alias aaa -> bbb", @admin)
          @bur2 = create_bur!("alias bbb -> ccc", @admin)

          assert_equal(false, TagAlias.where(antecedent_name: "aaa", consequent_name: "bbb", status: "active").exists?)
          assert_equal(true, TagAlias.where(antecedent_name: "bbb", consequent_name: "ccc", status: "active").exists?)
          assert_equal(true, TagAlias.where(antecedent_name: "aaa", consequent_name: "ccc", status: "active").exists?)
        end

        should "move any active implications from the old tag to the new tag" do
          @bur1 = create_bur!("imply aaa -> bbb", @admin)
          @bur2 = create_bur!("alias bbb -> ccc", @admin)

          assert_equal(false, TagImplication.active.exists?(antecedent_name: "aaa", consequent_name: "bbb", status: "active"))
          assert_equal(true, TagImplication.active.exists?(antecedent_name: "aaa", consequent_name: "ccc", status: "active"))

          @bur3 = create_bur!("alias aaa -> ddd", @admin)

          assert_equal(false, TagImplication.active.exists?(antecedent_name: "aaa", consequent_name: "ccc", status: "active"))
          assert_equal(true, TagImplication.active.exists?(antecedent_name: "ddd", consequent_name: "ccc", status: "active"))
        end

        should "not fail when merging two tags that imply the same parent tag" do
          @ta1 = create(:tag_implication, antecedent_name: "bird_on_finger", consequent_name: "bird")
          @ta2 = create(:tag_implication, antecedent_name: "bird_on_hand", consequent_name: "bird")

          @bur = create_bur!("alias bird_on_finger -> bird_on_hand", @admin)

          assert_equal(false, TagImplication.active.exists?(antecedent_name: "bird_on_finger", consequent_name: "bird"))
          assert_equal(true, TagImplication.deleted.exists?(antecedent_name: "bird_on_finger", consequent_name: "bird"))
          assert_equal(true, TagImplication.active.exists?(antecedent_name: "bird_on_hand", consequent_name: "bird"))
          assert_equal(true, TagAlias.active.exists?(antecedent_name: "bird_on_finger", consequent_name: "bird_on_hand"))
        end

        should "not fail when merging two tags implied by the same child tag" do
          @ta1 = create(:tag_implication, antecedent_name: "spider", consequent_name: "insect")
          @ta2 = create(:tag_implication, antecedent_name: "spider", consequent_name: "bug")

          @bur = create_bur!("alias insect -> bug", @admin)

          assert_equal(false, TagImplication.active.exists?(antecedent_name: "spider", consequent_name: "insect"))
          assert_equal(true, TagImplication.deleted.exists?(antecedent_name: "spider", consequent_name: "insect"))
          assert_equal(true, TagImplication.active.exists?(antecedent_name: "spider", consequent_name: "bug"))
          assert_equal(true, TagAlias.active.exists?(antecedent_name: "insect", consequent_name: "bug"))
        end

        should "allow moving a copyright tag that implies another copyright tag" do
          @t1 = create(:tag, name: "komeiji_koishi's_heart_throbbing_adventure", category: Tag.categories.general)
          @t2 = create(:tag, name: "komeiji_koishi_no_dokidoki_daibouken", category: Tag.categories.copyright)
          @t3 = create(:tag, name: "touhou", category: Tag.categories.copyright)
          create(:tag_implication, antecedent_name: "komeiji_koishi_no_dokidoki_daibouken", consequent_name: "touhou")

          create_bur!("alias komeiji_koishi_no_dokidoki_daibouken -> komeiji_koishi's_heart_throbbing_adventure", @admin)

          assert_equal(true, @t1.reload.copyright?)
          assert_equal(true, TagImplication.active.exists?(antecedent_name: "komeiji_koishi's_heart_throbbing_adventure", consequent_name: "touhou"))
        end

        should "allow aliases to be reversed in one step" do
          @alias = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb")
          @bur = create_bur!("create alias bbb -> aaa", @admin)

          assert_equal(true, @alias.reload.is_deleted?)
          assert_equal(true, TagAlias.active.exists?(antecedent_name: "bbb", consequent_name: "aaa"))
        end

        should "fail if the alias is invalid" do
          @alias = create(:tag_alias, antecedent_name: "bbb", consequent_name: "ccc")
          @bur = build(:bulk_update_request, script: "create alias aaa -> bbb")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't create alias aaa -> bbb (bbb is already aliased to ccc)"], @bur.errors.full_messages)
        end

        should "be case-insensitive" do
          @bur = create_bur!("CREATE ALIAS AAA -> BBB", @admin)

          @alias = TagAlias.find_by(antecedent_name: "aaa", consequent_name: "bbb")
          assert_equal(true, @alias.present?)
          assert_equal(true, @alias.is_active?)
        end
      end

      context "the create implication command" do
        should "create an implication" do
          @bur = create_bur!("create implication foo -> bar", @admin)

          @implication = TagImplication.find_by(antecedent_name: "foo", consequent_name: "bar")
          assert_equal(true, @implication.present?)
          assert_equal(true, @implication.is_active?)
          assert_equal("approved", @bur.reload.status)
        end

        should "fail for an implication that is redundant with an existing implication" do
          create(:tag_implication, antecedent_name: "a", consequent_name: "b")
          create(:tag_implication, antecedent_name: "b", consequent_name: "c")
          @bur = build(:bulk_update_request, script: "imply a -> c")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't create implication a -> c (a already implies c through another implication)"], @bur.errors.full_messages)
        end

        should "fail for an implication that is a duplicate of an existing implication" do
          create(:tag_implication, antecedent_name: "a", consequent_name: "b")
          @bur = build(:bulk_update_request, script: "imply a -> b")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't create implication a -> b (Implication already exists)"], @bur.errors.full_messages)
        end

        should "fail for an implication that is redundant with another implication in the same BUR" do
          create(:tag_implication, antecedent_name: "b", consequent_name: "c")
          @bur = build(:bulk_update_request, script: "imply a -> b\nimply a -> c")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't create implication a -> c (a already implies c through another implication)"], @bur.errors.full_messages)
        end

        should "fail for an implication between tags of different categories" do
          create(:tag, name: "hatsune_miku", category: Tag.categories.character)
          create(:tag, name: "vocaloid", category: Tag.categories.copyright)
          create(:wiki_page, title: "hatsune_miku")
          create(:wiki_page, title: "vocaloid")

          @bur = build(:bulk_update_request, script: "imply hatsune_miku -> vocaloid")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't create implication hatsune_miku -> vocaloid (Can't imply a character tag to a copyright tag)"], @bur.errors.full_messages)
        end

        should "fail for a child tag that is too small" do
          @t1 = create(:tag, name: "white_shirt", post_count: 9)
          @t2 = create(:tag, name: "shirt", post_count: 1000000)
          create(:wiki_page, title: "white_shirt")
          create(:wiki_page, title: "shirt")
          @bur = build(:bulk_update_request, script: "imply white_shirt -> shirt")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't create implication white_shirt -> shirt ('white_shirt' must have at least 10 posts)"], @bur.errors.full_messages)

          @t1.update!(post_count: 99)
          assert_equal(false, @bur.valid?)
          assert_equal(["Can't create implication white_shirt -> shirt ('white_shirt' must have at least 100 posts)"], @bur.errors.full_messages)
        end
      end

      context "the remove alias command" do
        should "remove an alias" do
          create(:tag_alias, antecedent_name: "foo", consequent_name: "bar")
          @bur = create_bur!("remove alias foo -> bar", @admin)

          @alias = TagAlias.find_by(antecedent_name: "foo", consequent_name: "bar")
          assert_equal(true, @alias.present?)
          assert_equal(true, @alias.is_deleted?)
          assert_equal("approved", @bur.reload.status)
        end

        should "fail to validate if the alias isn't active" do
          create(:tag_alias, antecedent_name: "foo", consequent_name: "bar", status: "deleted")
          @bur = build(:bulk_update_request, script: "remove alias foo -> bar")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't remove alias foo -> bar (alias doesn't exist)"], @bur.errors[:base])
        end

        should "fail to validate if the alias doesn't already exist" do
          @bur = build(:bulk_update_request, script: "remove alias foo -> bar")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't remove alias foo -> bar (alias doesn't exist)"], @bur.errors[:base])
        end

        should "allow reapproving a failed BUR when the alias has already been removed" do
          @alias = create(:tag_alias, antecedent_name: "foo", consequent_name: "bar")
          @bur = create(:bulk_update_request, script: "unalias foo -> bar", status: "failed")
          @alias.reject!

          @bur.approve!(@admin)
          perform_enqueued_jobs

          assert_equal(true, @alias.reload.is_deleted?)
          assert_equal("approved", @bur.reload.status)
        end

        should "be processed sequentially after the create alias command" do
          @bur = create_bur!("create alias foo -> bar\nremove alias foo -> bar", @admin)

          @alias = TagAlias.find_by(antecedent_name: "foo", consequent_name: "bar")
          assert_equal(true, @alias.present?)
          assert_equal(true, @alias.is_deleted?)
          assert_equal("approved", @bur.reload.status)
        end
      end

      context "the remove implication command" do
        should "remove an implication" do
          create(:tag_implication, antecedent_name: "foo", consequent_name: "bar", status: "active")
          @bur = create_bur!("remove implication foo -> bar", @admin)

          @implication = TagImplication.find_by(antecedent_name: "foo", consequent_name: "bar")
          assert_equal(true, @implication.present?)
          assert_equal(true, @implication.is_deleted?)
          assert_equal("approved", @bur.reload.status)
        end

        should "fail to validate if the implication isn't active" do
          create(:tag_implication, antecedent_name: "foo", consequent_name: "bar", status: "deleted")
          @bur = build(:bulk_update_request, script: "remove implication foo -> bar")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't remove implication foo -> bar (implication doesn't exist)"], @bur.errors[:base])
        end

        should "fail to validate if the implication doesn't already exist" do
          @bur = build(:bulk_update_request, script: "remove implication foo -> bar")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't remove implication foo -> bar (implication doesn't exist)"], @bur.errors[:base])
        end

        should "allow reapproving a failed BUR when the implication has already been removed" do
          @implication = create(:tag_implication, antecedent_name: "foo", consequent_name: "bar")
          @bur = create(:bulk_update_request, script: "unimply foo -> bar", status: "failed")
          @implication.reject!

          @bur.approve!(@admin)
          perform_enqueued_jobs

          assert_equal(true, @implication.reload.is_deleted?)
          assert_equal("approved", @bur.reload.status)
        end

        should "be processed sequentially after the create implication command" do
          @bur = create_bur!("imply foo -> bar\nunimply foo -> bar", @admin)

          @ti = TagImplication.find_by(antecedent_name: "foo", consequent_name: "bar")
          assert_equal(true, @ti.present?)
          assert_equal(true, @ti.is_deleted?)
          assert_equal("approved", @bur.reload.status)
        end
      end

      context "the mass update command" do
        setup do
          @post = create(:post, tag_string: "foo")
          @bur = create_bur!("mass update foo -> bar baz", @admin)
        end

        should "update the tags" do
          assert_equal("bar baz", @post.reload.tag_string)
          assert_equal("approved", @bur.reload.status)
          assert_equal(User.system, @post.versions.last.updater)
        end

        should "be case-sensitive" do
          @post = create(:post, source: "imageboard")
          @bur = create_bur!("mass update source:imageboard -> source:Imageboard", @admin)

          assert_equal("Imageboard", @post.reload.source)
          assert_equal("approved", @bur.reload.status)
        end

        should "not allow mass update for simple A -> B moves" do
          @bur = build(:bulk_update_request, script: "mass update bunny -> rabbit")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't mass update bunny -> rabbit (use an alias or a rename instead for tag moves)"], @bur.errors.full_messages)
        end
      end

      context "the rename command" do
        setup do
          @artist = create(:artist, name: "foo")
          @wiki = create(:wiki_page, title: "foo", body: "[[foo]]")
          @post = create(:post, tag_string: "foo blah")
          @bur = create_bur!("rename foo -> bar", @admin)
        end

        should "rename the tags" do
          assert_equal("bar blah", @post.reload.tag_string)
          assert_equal("approved", @bur.reload.status)
          assert_equal(User.system, @post.versions.last.updater)
        end

        should "move the tag's artist entry and wiki page" do
          assert_equal("bar", @artist.reload.name)
          assert_equal("bar", @wiki.reload.title)
          assert_equal("[[bar]]", @wiki.body)
        end

        should "fail if the old tag doesn't exist" do
          @bur = build(:bulk_update_request, script: "rename aaa -> bbb")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't rename aaa -> bbb (the 'aaa' tag doesn't exist)"], @bur.errors.full_messages)
        end

        should "fail if the old tag has more than 200 posts" do
          create(:tag, name: "aaa", post_count: 1000)
          @bur = build(:bulk_update_request, script: "rename aaa -> bbb")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't rename aaa -> bbb ('aaa' has more than 200 posts, use an alias instead)"], @bur.errors.full_messages)
        end

        context "when moving an artist" do
          should "add the artist's old tag name to their other names" do
            assert_equal(["foo"], @artist.reload.other_names)
          end
        end

        context "when renaming a character tag with a *_(cosplay) tag" do
          should "move the *_(cosplay) tag as well" do
            @post = create(:post, tag_string: "toosaka_rin_(cosplay)")
            @wiki = create(:wiki_page, title: "toosaka_rin_(cosplay)")
            @ta = create(:tag_alias, antecedent_name: "toosaka_rin", consequent_name: "tohsaka_rin")

            create_bur!("rename toosaka_rin -> tohsaka_rin", @admin)

            assert_equal("cosplay tohsaka_rin tohsaka_rin_(cosplay)", @post.reload.tag_string)
            assert_equal("tohsaka_rin_(cosplay)", @wiki.reload.title)
          end
        end

        context "when renaming an artist tag with a *_(style) tag" do
          should "move the *_(style) tag as well" do
            create(:tag, name: "tanaka_takayuki", category: Tag.categories.artist)
            @post = create(:post, tag_string: "tanaka_takayuki_(style)")
            @wiki = create(:wiki_page, title: "tanaka_takayuki_(style)")

            create_bur!("rename tanaka_takayuki -> tony_taka", @admin)

            assert_equal("tony_taka_(style)", @post.reload.tag_string)
            assert_equal("tony_taka_(style)", @wiki.reload.title)
          end
        end
      end

      context "the nuke command" do
        should "remove tags" do
          @post = create(:post, tag_string: "foo bar")
          @bur = create_bur!("nuke bar", @admin)

          assert_equal("foo", @post.reload.tag_string)
          assert_equal("approved", @bur.reload.status)
          assert_equal(User.system, @post.versions.last.updater)
        end

        should "remove implications" do
          @ti1 = create(:tag_implication, antecedent_name: "fly", consequent_name: "insect")
          @ti2 = create(:tag_implication, antecedent_name: "insect", consequent_name: "bug")
          @bur = create_bur!("nuke insect", @admin)

          assert_equal("deleted", @ti1.reload.status)
          assert_equal("deleted", @ti2.reload.status)
          assert_equal("approved", @bur.reload.status)
        end

        should "remove pools" do
          @pool = create(:pool)
          @post = create(:post, tag_string: "bar pool:#{@pool.id}")
          @bur = create_bur!("nuke pool:#{@pool.id}", @admin)

          assert_equal([], @pool.post_ids)
          assert_equal("approved", @bur.reload.status)
          assert_equal(User.system, @pool.versions.last.updater)
        end
      end

      context "that contains a mass update followed by an alias" do
        should "make the alias take effect after the mass update" do
          @p1 = create(:post, tag_string: "maid_dress")
          @p2 = create(:post, tag_string: "maid")

          @bur = create_bur!("mass update maid_dress -> maid dress\nalias maid_dress -> maid", @admin)

          assert_equal("dress maid", @p1.reload.tag_string)
          assert_equal("maid", @p2.reload.tag_string)
          assert_equal("approved", @bur.reload.status)
        end
      end

      context "that reverses an alias by removing and recreating it" do
        should "not fail with an alias conflict" do
          @ta = create(:tag_alias, antecedent_name: "rabbit", consequent_name: "bunny")
          @bur = create_bur!("unalias rabbit -> bunny\nalias bunny -> rabbit", @admin)

          assert_equal("deleted", @ta.reload.status)
          assert_equal("active", TagAlias.find_by(antecedent_name: "bunny", consequent_name: "rabbit").status)
          assert_equal("approved", @bur.reload.status)
        end
      end
    end

    context "when validating a script" do
      context "an unparseable script" do
        should "fail validation" do
          @script = <<~EOS
            create alias aaa -> 000
            create alias bbb > 111
            create alias ccc -> 222
          EOS

          @bur = build(:bulk_update_request, script: @script)
          assert_equal(false, @bur.valid?)
          assert_equal(["Invalid line: create alias bbb > 111"], @bur.errors[:base])
        end
      end

      context "a script with extra whitespace" do
        should "validate" do
          @script = %{
            create alias aaa -> 000

            create alias bbb -> 111
          }

          @bur = create(:bulk_update_request, script: @script)
          assert_equal(true, @bur.valid?)
        end
      end

      context "requesting an implication for an empty tag without a wiki" do
        should "succeed" do
          @bur = create(:bulk_update_request, script: "imply a -> b")
          assert_equal(true, @bur.valid?)
        end
      end

      context "requesting an implication for a populated tag without a wiki" do
        should "fail" do
          create(:tag, name: "a", post_count: 10)
          create(:tag, name: "b", post_count: 100)
          @bur = build(:bulk_update_request, script: "imply a -> b")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't create implication a -> b ('a' must have a wiki page; 'b' must have a wiki page)"], @bur.errors.full_messages)
        end
      end

      context "a bulk update request that is too long" do
        should "fail" do
          @bur = build(:bulk_update_request, script: "nuke touhou\n" * 200)

          assert_equal(false, @bur.valid?)
          assert_equal(["Bulk update request is too long (maximum size: 100 lines). Split your request into smaller chunks and try again."], @bur.errors.full_messages)
        end
      end
    end

    context "when the script is updated" do
      should "update the BUR's list of affected tags" do
        create(:tag_alias, antecedent_name: "ccc", consequent_name: "222")
        create(:tag_implication, antecedent_name: "ddd", consequent_name: "333")
        create(:tag, name: "iii")

        @script = <<~EOS
          create alias aaa -> 000
          create implication bbb -> 111
          remove alias ccc -> 222
          remove implication ddd -> 333
          mass update eee id:1 -fff ~ggg hhh* -> 444 -555
          category iii -> meta
        EOS

        @bur = create(:bulk_update_request, script: "create alias aaa -> bbb")
        assert_equal(%w[aaa bbb], @bur.tags)

        @bur.update!(script: @script)
        assert_equal(%w(000 111 222 333 444 aaa bbb ccc ddd eee iii), @bur.tags)
      end
    end

    context "on approval" do
      setup do
        @post = create(:post, tag_string: "foo aaa")
        @script = '
          create alias foo -> bar
          create implication bar -> baz
          mass update aaa -> bbb blah
        '

        @bur = create_bur!(@script, @admin)

        @ta = TagAlias.where(:antecedent_name => "foo", :consequent_name => "bar").first
        @ti = TagImplication.where(:antecedent_name => "bar", :consequent_name => "baz").first
      end

      should "set the BUR approver" do
        assert_equal(@admin.id, @bur.approver.id)
      end

      should "create aliases/implications" do
        assert_equal("active", @ta.status)
        assert_equal("active", @ti.status)
      end

      should "process mass updates" do
        assert_equal("bar baz bbb blah", @post.reload.tag_string)
      end

      should "set the alias/implication approvers" do
        assert_equal(@admin.id, @ta.approver.id)
        assert_equal(@admin.id, @ti.approver.id)
      end

      should "set the BUR as approved" do
        assert_equal("approved", @bur.reload.status)
      end

      should "update the post as DanbooruBot" do
        assert_equal(User.system, @post.versions.last.updater)
      end

      should "set the BUR as failed if there is an unexpected error during processing" do
        @bur = create(:bulk_update_request, script: "alias one -> two")
        TagAlias.any_instance.stubs(:process!).raises(RuntimeError.new("oh no"))

        assert_equal("pending", @bur.status)
        @bur.approve!(@admin)
        assert_equal("processing", @bur.status)

        assert_raises(RuntimeError) { perform_enqueued_jobs }
        assert_equal("failed", @bur.reload.status)

        assert_equal("active", TagAlias.find_by!(antecedent_name: "one", consequent_name: "two").status)
        assert_equal("alias one -> two", @bur.script)
        assert_equal(@admin, @bur.approver)
      end
    end

    context "when a bulk update request fails" do
      should "allow it to be approved again" do
        @post = create(:post, tag_string: "foo aaa")
        @bur = create(:bulk_update_request, script: "alias foo -> bar")

        TagAlias.any_instance.stubs(:process!).raises(RuntimeError.new("oh no"))
        @bur.approve!(@admin)
        assert_raises(RuntimeError) { perform_enqueued_jobs }

        assert_equal("aaa foo", @post.reload.tag_string)

        assert_equal("failed", @bur.reload.status)
        assert_not_nil(@bur.forum_topic)
        assert_equal(@admin, @bur.approver)

        @ta = TagAlias.find_by!(antecedent_name: "foo", consequent_name: "bar")
        assert_equal("active", @ta.status)
        assert_equal(@admin, @ta.approver)
        assert_equal(@bur.forum_topic, @ta.forum_topic)

        TagAlias.any_instance.unstub(:process!)
        @bur.approve!(@admin)
        perform_enqueued_jobs

        assert_equal("aaa bar", @post.reload.tag_string)

        assert_equal("approved", @bur.reload.status)
        assert_not_nil(@bur.forum_topic)
        assert_equal(@admin, @bur.approver)

        assert_equal("active", @ta.reload.status)
        assert_equal(@admin, @ta.approver)
        assert_equal(@bur.forum_topic, @ta.forum_topic)
      end
    end

    should "create a forum topic" do
      bur = create(:bulk_update_request, reason: "zzz", script: "create alias aaa -> bbb")

      assert_equal(true, bur.forum_post.present?)
      assert_match(/\[bur:#{bur.id}\]/, bur.forum_post.body)
      assert_match(/zzz/, bur.forum_post.body)
    end

    context "with an associated forum topic" do
      setup do
        @topic = create(:forum_topic, title: "[bulk] hoge", creator: @admin)
        @post = create(:forum_post, topic: @topic, creator: @admin)
        @req = FactoryBot.create(:bulk_update_request, :script => "create alias AAA -> BBB", :forum_topic_id => @topic.id, :forum_post_id => @post.id, :title => "[bulk] hoge")
      end

      should "leave the BUR pending if there is a validation error during approval" do
        @req.stubs(:update!).raises(BulkUpdateRequestProcessor::Error.new("blah"))
        assert_equal("pending", @req.reload.status)
      end

      should "leave the BUR pending if there is an unexpected error during approval" do
        @req.forum_updater.stubs(:update).raises(RuntimeError.new("blah"))
        assert_raises(RuntimeError) { @req.approve!(@admin) }

        # XXX Raises "Couldn't find BulkUpdateRequest without an ID". Possible
        # rails bug? (cf rails #34637, #34504, #30167, #15018).
        # @req.reload

        @req = BulkUpdateRequest.find(@req.id)
        assert_equal("pending", @req.status)
      end

      should "not send @mention dmails to the approver" do
        assert_no_difference("Dmail.count") do
          @req.approve!(@admin)
        end
      end
    end

    context "when searching" do
      setup do
        @bur1 = create(:bulk_update_request, title: "foo", script: "create alias aaa -> bbb", user: @admin, approver: @admin, status: "approved")
        @bur2 = create(:bulk_update_request, title: "bar", script: "create implication bbb -> ccc", user: @admin)
      end

      should "work" do
        assert_equal([@bur2.id, @bur1.id], BulkUpdateRequest.search.map(&:id))
        assert_equal([@bur1.id], BulkUpdateRequest.search(user_name: @admin.name, approver_name: @admin.name, status: "approved").map(&:id))
      end
    end
  end
end
