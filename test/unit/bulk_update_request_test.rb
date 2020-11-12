require 'test_helper'

class BulkUpdateRequestTest < ActiveSupport::TestCase
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
          @bur = create(:bulk_update_request, script: "category hello -> artist")
          @bur.approve!(@admin)

          assert_equal(true, @bur.valid?)
          assert_equal(true, @tag.reload.artist?)
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
          @bur = create(:bulk_update_request, script: "create alias foo -> bar")

          @bur.approve!(@admin)
          perform_enqueued_jobs
        end

        should "create an alias" do
          @alias = TagAlias.find_by(antecedent_name: "foo", consequent_name: "bar")
          assert_equal(true, @alias.present?)
          assert_equal(true, @alias.is_active?)
        end

        should "rename the aliased tag's artist entry and wiki page" do
          assert_equal("bar", @artist.reload.name)
          assert_equal("bar", @wiki.reload.title)
        end

        should "fail if the alias is invalid" do
          create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb")
          @bur = build(:bulk_update_request, script: "create alias bbb -> aaa")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't create alias bbb -> aaa (A tag alias for aaa already exists)"], @bur.errors.full_messages)
        end

        should "be case-insensitive" do
          @bur = create(:bulk_update_request, script: "CREATE ALIAS AAA -> BBB")
          @bur.approve!(@admin)
          perform_enqueued_jobs

          @alias = TagAlias.find_by(antecedent_name: "aaa", consequent_name: "bbb")
          assert_equal(true, @alias.present?)
          assert_equal(true, @alias.is_active?)
        end
      end

      context "the create implication command" do
        should "create an implication" do
          @bur = create(:bulk_update_request, script: "create implication foo -> bar")
          @bur.approve!(@admin)
          perform_enqueued_jobs

          @implication = TagImplication.find_by(antecedent_name: "foo", consequent_name: "bar")
          assert_equal(true, @implication.present?)
          assert_equal(true, @implication.is_active?)
        end

        should "fail for an implication that is redundant with an existing implication" do
          create(:tag_implication, antecedent_name: "a", consequent_name: "b")
          create(:tag_implication, antecedent_name: "b", consequent_name: "c")
          @bur = build(:bulk_update_request, script: "imply a -> c")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't create implication a -> c (a already implies c through another implication)"], @bur.errors.full_messages)
        end

        should_eventually "fail for an implication that is redundant with another implication in the same BUR" do
          create(:tag_implication, antecedent_name: "b", consequent_name: "c")
          @bur = build(:bulk_update_request, script: "imply a -> b\nimply a -> c")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't create implication a -> c (a already implies c through another implication)"], @bur.errors.full_messages)
        end
      end

      context "the remove alias command" do
        should "remove an alias" do
          create(:tag_alias, antecedent_name: "foo", consequent_name: "bar")
          @bur = create(:bulk_update_request, script: "remove alias foo -> bar")
          @bur.approve!(@admin)

          @alias = TagAlias.find_by(antecedent_name: "foo", consequent_name: "bar")
          assert_equal(true, @alias.present?)
          assert_equal(true, @alias.is_deleted?)
        end

        should "fail if the alias isn't active" do
          create(:tag_alias, antecedent_name: "foo", consequent_name: "bar", status: "pending")
          @bur = build(:bulk_update_request, script: "remove alias foo -> bar")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't remove alias foo -> bar (alias doesn't exist)"], @bur.errors[:base])
        end

        should "fail if the alias doesn't already exist" do
          @bur = build(:bulk_update_request, script: "remove alias foo -> bar")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't remove alias foo -> bar (alias doesn't exist)"], @bur.errors[:base])
        end
      end

      context "the remove implication command" do
        should "remove an implication" do
          create(:tag_implication, antecedent_name: "foo", consequent_name: "bar", status: "active")
          @bur = create(:bulk_update_request, script: "remove implication foo -> bar")
          @bur.approve!(@admin)

          @implication = TagImplication.find_by(antecedent_name: "foo", consequent_name: "bar")
          assert_equal(true, @implication.present?)
          assert_equal(true, @implication.is_deleted?)
        end

        should "fail if the implication isn't active" do
          create(:tag_implication, antecedent_name: "foo", consequent_name: "bar", status: "pending")
          @bur = build(:bulk_update_request, script: "remove implication foo -> bar")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't remove implication foo -> bar (implication doesn't exist)"], @bur.errors[:base])
        end

        should "fail if the implication doesn't already exist" do
          @bur = build(:bulk_update_request, script: "remove implication foo -> bar")

          assert_equal(false, @bur.valid?)
          assert_equal(["Can't remove implication foo -> bar (implication doesn't exist)"], @bur.errors[:base])
        end
      end

      context "the mass update command" do
        setup do
          @post = create(:post, tag_string: "foo")
          @bur = create(:bulk_update_request, script: "mass update foo -> bar")
          @bur.approve!(@admin)
          perform_enqueued_jobs
        end

        should "update the tags" do
          assert_equal("bar", @post.reload.tag_string)
        end

        should "be case-sensitive" do
          @post = create(:post, source: "imageboard")
          @bur = create(:bulk_update_request, script: "mass update source:imageboard -> source:Imageboard")

          @bur.approve!(@admin)
          perform_enqueued_jobs

          assert_equal("Imageboard", @post.reload.source)
        end
      end

      context "the rename command" do
        setup do
          @artist = create(:artist, name: "foo")
          @wiki = create(:wiki_page, title: "foo", body: "[[foo]]")
          @post = create(:post, tag_string: "foo blah")
          @bur = create(:bulk_update_request, script: "rename foo -> bar")
          @bur.approve!(@admin)
          perform_enqueued_jobs
        end

        should "rename the tags" do
          assert_equal("approved", @bur.status)
          assert_equal("bar blah", @post.reload.tag_string)
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

        context "when renaming a character tag with a *_(cosplay) tag" do
          should "move the *_(cosplay) tag as well" do
            @post = create(:post, tag_string: "toosaka_rin_(cosplay)")
            @wiki = create(:wiki_page, title: "toosaka_rin_(cosplay)")
            @ta = create(:tag_alias, antecedent_name: "toosaka_rin", consequent_name: "tohsaka_rin")

            @bur = create(:bulk_update_request, script: "rename toosaka_rin -> tohsaka_rin")
            @bur.approve!(@admin)
            perform_enqueued_jobs

            assert_equal("cosplay tohsaka_rin tohsaka_rin_(cosplay)", @post.reload.tag_string)
            assert_equal("tohsaka_rin_(cosplay)", @wiki.reload.title)
          end
        end
      end

      context "that contains a mass update followed by an alias" do
        should "make the alias take effect after the mass update" do
          @bur = create(:bulk_update_request, script: "mass update maid_dress -> maid dress\nalias maid_dress -> maid")
          @p1 = create(:post, tag_string: "maid_dress")
          @p2 = create(:post, tag_string: "maid")

          @bur.approve!(@admin)
          perform_enqueued_jobs

          assert_equal("dress maid", @p1.reload.tag_string)
          assert_equal("maid", @p2.reload.tag_string)
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
          mass update aaa -> bbb
        '

        @bur = create(:bulk_update_request, script: @script, user: @admin)
        @bur.approve!(@admin)

        assert_enqueued_jobs(3)
        perform_enqueued_jobs

        @ta = TagAlias.where(:antecedent_name => "foo", :consequent_name => "bar").first
        @ti = TagImplication.where(:antecedent_name => "bar", :consequent_name => "baz").first
      end

      should "reference the approver in the automated message" do
        assert_match(Regexp.compile(@admin.name), @bur.forum_post.body)
      end

      should "set the BUR approver" do
        assert_equal(@admin.id, @bur.approver.id)
      end

      should "create aliases/implications" do
        assert_equal("active", @ta.status)
        assert_equal("active", @ti.status)
      end

      should "process mass updates" do
        assert_equal("bar baz bbb", @post.reload.tag_string)
      end

      should "set the alias/implication approvers" do
        assert_equal(@admin.id, @ta.approver.id)
        assert_equal(@admin.id, @ti.approver.id)
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

      should "gracefully handle validation errors during approval" do
        @req.stubs(:update!).raises(BulkUpdateRequestProcessor::Error.new("blah"))
        assert_difference("ForumPost.count", 1) do
          @req.approve!(@admin)
        end

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

      should "update the topic when processed" do
        assert_difference("ForumPost.count") do
          @req.approve!(@admin)
        end

        assert_match(/approved/, @post.reload.body)
      end

      should "update the topic when rejected" do
        @req.approver_id = @admin.id

        assert_difference("ForumPost.count") do
          @req.reject!(@admin)
        end

        assert_match(/rejected/, @post.reload.body)
      end

      should "reference the rejector in the automated message" do
        @req.reject!(@admin)
        assert_match(Regexp.compile(@admin.name), @req.forum_post.body)
      end

      should "not send @mention dmails to the approver" do
        assert_no_difference("Dmail.count") do
          @req.approve!(@admin)
        end
      end
    end

    context "when searching" do
      setup do
        @bur1 = FactoryBot.create(:bulk_update_request, title: "foo", script: "create alias aaa -> bbb", user_id: @admin.id)
        @bur2 = FactoryBot.create(:bulk_update_request, title: "bar", script: "create implication bbb -> ccc", user_id: @admin.id)
        @bur1.approve!(@admin)
      end

      should "work" do
        assert_equal([@bur2.id, @bur1.id], BulkUpdateRequest.search.map(&:id))
        assert_equal([@bur1.id], BulkUpdateRequest.search(user_name: @admin.name, approver_name: @admin.name, status: "approved").map(&:id))
      end
    end
  end
end
