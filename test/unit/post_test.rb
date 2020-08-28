require 'test_helper'

class PostTest < ActiveSupport::TestCase
  def self.assert_invalid_tag(tag_name)
    should "not allow '#{tag_name}' to be tagged" do
      post = build(:post, tag_string: "touhou #{tag_name}")

      assert(post.valid?)
      assert_equal("touhou", post.tag_string)
      assert_equal(1, post.warnings[:base].grep(/Couldn't add tag/).count)
    end
  end

  def setup
    super

    travel_to(2.weeks.ago) do
      @user = FactoryBot.create(:user)
    end
    CurrentUser.user = @user
    CurrentUser.ip_addr = "127.0.0.1"
  end

  def teardown
    super

    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "Deletion:" do
    context "Expunging a post" do
      setup do
        @upload = UploadService.new(FactoryBot.attributes_for(:jpg_upload)).start!
        @post = @upload.post
        Favorite.add(post: @post, user: @user)
        create(:favorite_group, post_ids: [@post.id])
      end

      should "delete the files" do
        assert_nothing_raised { @post.file(:preview) }
        assert_nothing_raised { @post.file(:original) }

        @post.expunge!

        assert_raise(StandardError) { @post.file(:preview) }
        assert_raise(StandardError) { @post.file(:original) }
      end

      should "remove all favorites" do
        @post.expunge!

        assert_equal(0, Favorite.for_user(@user.id).where("post_id = ?", @post.id).count)
      end

      should "remove all favgroups" do
        assert_equal(1, FavoriteGroup.for_post(@post.id).count)
        @post.expunge!
        assert_equal(0, FavoriteGroup.for_post(@post.id).count)
      end

      should "decrement the uploader's upload count" do
        assert_difference("@post.uploader.reload.post_upload_count", -1) do
          @post.expunge!
        end
      end

      should "decrement the user's note update count" do
        FactoryBot.create(:note, post: @post)
        assert_difference(["@post.uploader.reload.note_update_count"], -1) do
          @post.expunge!
        end
      end

      should "decrement the user's post update count" do
        assert_difference(["@post.uploader.reload.post_update_count"], -1) do
          @post.expunge!
        end
      end

      should "decrement the user's favorite count" do
        assert_difference(["@post.uploader.reload.favorite_count"], -1) do
          @post.expunge!
        end
      end

      should "remove the post from iqdb" do
        mock_iqdb_service!
        Post.iqdb_sqs_service.expects(:send_message).with("remove\n#{@post.id}")

        @post.expunge!
      end

      context "that is status locked" do
        setup do
          @post.update(is_status_locked: true)
        end

        should "not destroy the record" do
          @post.expunge!
          assert_equal(1, Post.where("id = ?", @post.id).count)
        end
      end

      context "that belongs to a pool" do
        setup do
          # must be a builder to update deleted pools. must be >1 week old to remove posts from pools.
          CurrentUser.user = FactoryBot.create(:builder_user, created_at: 1.month.ago)

          SqsService.any_instance.stubs(:send_message)
          @pool = FactoryBot.create(:pool)
          @pool.add!(@post)

          @deleted_pool = FactoryBot.create(:pool)
          @deleted_pool.add!(@post)
          @deleted_pool.update_columns(is_deleted: true)

          @post.expunge!
          @pool.reload
          @deleted_pool.reload
        end

        should "remove the post from all pools" do
          assert_equal([], @pool.post_ids)
        end

        should "remove the post from deleted pools" do
          assert_equal([], @deleted_pool.post_ids)
        end

        should "destroy the record" do
          assert_equal([], @post.errors.full_messages)
          assert_equal(0, Post.where("id = ?", @post.id).count)
        end
      end
    end

    context "Deleting a post" do
      context "that is status locked" do
        setup do
          @post = FactoryBot.create(:post, is_status_locked: true)
        end

        should "fail" do
          assert_raise(ActiveRecord::RecordInvalid) do
            @post.delete!("test")
          end

          assert_equal(false, @post.reload.is_deleted?)
        end
      end

      context "that is pending" do
        setup do
          @post = FactoryBot.create(:post, is_pending: true)
        end

        should "succeed" do
          @post.delete!("test")

          assert_equal(true, @post.is_deleted)
          assert_equal(1, @post.flags.size)
          assert_match(/test/, @post.flags.last.reason)
        end
      end

      context "with the banned_artist tag" do
        should "also ban the post" do
          post = FactoryBot.create(:post, :tag_string => "banned_artist")
          post.delete!("test")
          post.reload
          assert(post.is_banned?)
        end
      end

      context "that is still in cooldown after being flagged" do
        should "succeed" do
          post = FactoryBot.create(:post)
          post.flag!("test flag")
          post.delete!("test deletion")

          assert_equal(true, post.is_deleted)
          assert_equal(2, post.flags.size)
        end
      end

      should "toggle the is_deleted flag" do
        post = FactoryBot.create(:post)
        assert_equal(false, post.is_deleted?)
        post.delete!("test")
        assert_equal(true, post.is_deleted?)
      end
    end
  end

  context "Parenting:" do
    context "Assigning a parent to a post" do
      should "update the has_children flag on the parent" do
        p1 = FactoryBot.create(:post)
        assert(!p1.has_children?, "Parent should not have any children")
        c1 = FactoryBot.create(:post, :parent_id => p1.id)
        p1.reload
        assert(p1.has_children?, "Parent not updated after child was added")
      end

      should "update the has_children flag on the old parent" do
        p1 = FactoryBot.create(:post)
        p2 = FactoryBot.create(:post)
        c1 = FactoryBot.create(:post, :parent_id => p1.id)
        c1.parent_id = p2.id
        c1.save
        p1.reload
        p2.reload
        assert(!p1.has_children?, "Old parent should not have a child")
        assert(p2.has_children?, "New parent should have a child")
      end
    end

    context "Expunging a post with" do
      context "a parent" do
        should "reset the has_children flag of the parent" do
          p1 = FactoryBot.create(:post)
          c1 = FactoryBot.create(:post, :parent_id => p1.id)
          c1.expunge!
          p1.reload
          assert_equal(false, p1.has_children?)
        end

        should "update the parent's has_children flag" do
          p1 = FactoryBot.create(:post)
          c1 = FactoryBot.create(:post, :parent_id => p1.id)
          c1.expunge!
          p1.reload
          assert(!p1.has_children?, "Parent should not have children")
        end
      end

      context "one child" do
        should "remove the parent of that child" do
          p1 = FactoryBot.create(:post)
          c1 = FactoryBot.create(:post, :parent_id => p1.id)
          p1.expunge!
          c1.reload
          assert_nil(c1.parent)
        end
      end

      context "two or more children" do
        setup do
          # ensure initial post versions won't be merged.
          travel_to(1.day.ago) do
            @p1 = FactoryBot.create(:post)
            @c1 = FactoryBot.create(:post, :parent_id => @p1.id)
            @c2 = FactoryBot.create(:post, :parent_id => @p1.id)
            @c3 = FactoryBot.create(:post, :parent_id => @p1.id)
          end
        end

        should "save a post version record for each child" do
          assert_difference(["@c1.versions.count", "@c2.versions.count", "@c3.versions.count"]) do
            @p1.expunge!
            @c1.reload
            @c2.reload
            @c3.reload
          end
        end
      end
    end

    context "Deleting a post with" do
      context "a parent" do
        should "not reassign favorites to the parent by default" do
          p1 = FactoryBot.create(:post)
          c1 = FactoryBot.create(:post, :parent_id => p1.id)
          user = FactoryBot.create(:gold_user)
          c1.add_favorite!(user)
          c1.delete!("test")
          p1.reload
          assert(Favorite.exists?(:post_id => c1.id, :user_id => user.id))
          assert(!Favorite.exists?(:post_id => p1.id, :user_id => user.id))
        end

        should "reassign favorites to the parent if specified" do
          p1 = FactoryBot.create(:post)
          c1 = FactoryBot.create(:post, :parent_id => p1.id)
          user = FactoryBot.create(:gold_user)
          c1.add_favorite!(user)
          c1.delete!("test", :move_favorites => true)
          p1.reload
          assert(!Favorite.exists?(:post_id => c1.id, :user_id => user.id), "Child should not still have favorites")
          assert(Favorite.exists?(:post_id => p1.id, :user_id => user.id), "Parent should have favorites")
        end

        should "not update the parent's has_children flag" do
          p1 = FactoryBot.create(:post)
          c1 = FactoryBot.create(:post, :parent_id => p1.id)
          c1.delete!("test")
          p1.reload
          assert(p1.has_children?, "Parent should have children")
        end

        should "clear the has_active_children flag when the 'move favorites' option is set" do
          user = FactoryBot.create(:gold_user)
          p1 = FactoryBot.create(:post)
          c1 = FactoryBot.create(:post, :parent_id => p1.id)
          c1.add_favorite!(user)

          assert_equal(true, p1.reload.has_active_children?)
          c1.delete!("test", :move_favorites => true)
          assert_equal(false, p1.reload.has_active_children?)
        end
      end

      context "one child" do
        should "not remove the has_children flag" do
          p1 = FactoryBot.create(:post)
          c1 = FactoryBot.create(:post, :parent_id => p1.id)
          p1.delete!("test")
          p1.reload
          assert_equal(true, p1.has_children?)
        end

        should "not remove the parent of that child" do
          p1 = FactoryBot.create(:post)
          c1 = FactoryBot.create(:post, :parent_id => p1.id)
          p1.delete!("test")
          c1.reload
          assert_not_nil(c1.parent)
        end
      end

      context "two or more children" do
        should "not reparent all children to the first child" do
          p1 = FactoryBot.create(:post)
          c1 = FactoryBot.create(:post, :parent_id => p1.id)
          c2 = FactoryBot.create(:post, :parent_id => p1.id)
          c3 = FactoryBot.create(:post, :parent_id => p1.id)
          p1.delete!("test")
          c1.reload
          c2.reload
          c3.reload
          assert_equal(p1.id, c1.parent_id)
          assert_equal(p1.id, c2.parent_id)
          assert_equal(p1.id, c3.parent_id)
        end
      end
    end

    context "Undeleting a post with a parent" do
      should "update with a new approver" do
        new_user = FactoryBot.create(:moderator_user)
        p1 = FactoryBot.create(:post)
        c1 = FactoryBot.create(:post, :parent_id => p1.id)
        c1.delete!("test")
        c1.approve!(new_user)
        p1.reload
        assert_equal(new_user.id, c1.approver_id)
      end

      should "preserve the parent's has_children flag" do
        p1 = FactoryBot.create(:post)
        c1 = FactoryBot.create(:post, :parent_id => p1.id)
        c1.delete!("test")
        c1.approve!
        p1.reload
        assert_not_nil(c1.parent_id)
        assert(p1.has_children?, "Parent should have children")
      end
    end
  end

  context "Moderation:" do
    context "A deleted post" do
      setup do
        @post = FactoryBot.create(:post, :is_deleted => true)
      end

      context "that is status locked" do
        setup do
          @post.update(is_status_locked: true)
        end

        should "not allow undeletion" do
          approval = @post.approve!
          assert_equal(["Post is locked and cannot be approved"], approval.errors.full_messages)
          assert_equal(true, @post.is_deleted?)
        end
      end

      context "that is undeleted" do
        setup do
          @mod = FactoryBot.create(:moderator_user)
          CurrentUser.user = @mod
        end

        context "by the approver" do
          setup do
            @post.update_attribute(:approver_id, @mod.id)
          end

          should "not be permitted" do
            approval = @post.approve!

            assert_equal(false, approval.valid?)
            assert_equal(["You have previously approved this post and cannot approve it again"], approval.errors.full_messages)
          end
        end

        context "by the uploader" do
          setup do
            @post.update_attribute(:uploader_id, @mod.id)
          end

          should "not be permitted" do
            approval = @post.approve!

            assert_equal(false, approval.valid?)
            assert_equal(["You cannot approve a post you uploaded"], approval.errors.full_messages)
          end
        end
      end

      context "when undeleted" do
        should "be undeleted" do
          @post.approve!
          assert_equal(false, @post.reload.is_deleted?)
        end

        should "create a mod action" do
          @post.approve!
          assert_equal("undeleted post ##{@post.id}", ModAction.last.description)
          assert_equal("post_undelete", ModAction.last.category)
        end
      end

      context "when approved" do
        should "be undeleted" do
          @post.approve!
          assert_equal(false, @post.reload.is_deleted?)
        end

        should "create a mod action" do
          @post.approve!
          assert_equal("undeleted post ##{@post.id}", ModAction.last.description)
          assert_equal("post_undelete", ModAction.last.category)
        end
      end

      should "be appealed" do
        create(:post_appeal, post: @post)
        assert(@post.is_deleted?, "Post should still be deleted")
        assert_equal(1, @post.appeals.count)
      end
    end

    context "An approved post" do
      should "be flagged" do
        post = FactoryBot.create(:post)
        assert_difference("PostFlag.count", 1) do
          post.flag!("bad")
        end
        assert(post.is_flagged?, "Post should be flagged.")
        assert_equal(1, post.flags.count)
      end

      should "not be flagged if no reason is given" do
        post = FactoryBot.create(:post)
        assert_difference("PostFlag.count", 0) do
          assert_raises(PostFlag::Error) do
            post.flag!("")
          end
        end
      end
    end

    context "An unapproved post" do
      should "preserve the approver's identity when approved" do
        post = FactoryBot.create(:post, :is_pending => true)
        post.approve!
        assert_equal(post.approver_id, CurrentUser.id)
      end

      context "that was previously approved by person X" do
        setup do
          @user = FactoryBot.create(:moderator_user, :name => "xxx")
          @user2 = FactoryBot.create(:moderator_user, :name => "yyy")
          @post = FactoryBot.create(:post, :approver_id => @user.id)
          @post.flag!("bad")
        end

        should "not allow person X to reapprove that post" do
          approval = @post.approve!(@user)
          assert_includes(approval.errors.full_messages, "You have previously approved this post and cannot approve it again")
        end

        should "allow person Y to approve the post" do
          @post.approve!(@user2)
          assert(@post.valid?)
        end
      end

      context "that has been reapproved" do
        should "no longer be flagged or pending" do
          post = FactoryBot.create(:post)
          post.flag!("bad")
          post.approve!
          assert(post.errors.empty?, post.errors.full_messages.join(", "))
          post.reload
          assert_equal(false, post.is_flagged?)
          assert_equal(false, post.is_pending?)
        end
      end
    end

    context "A status locked post" do
      should "not allow new flags" do
        assert_raises(PostFlag::Error) do
          @post = create(:post, is_status_locked: true)
          @post.flag!("wrong")
        end
      end

      should "not allow new appeals" do
        @post = create(:post, is_status_locked: true, is_deleted: true)
        @appeal = build(:post_appeal, post: @post)

        assert_equal(false, @appeal.valid?)
        assert_equal(["Post cannot be appealed"], @appeal.errors.full_messages)
      end

      should "not allow approval" do
        @post = create(:post, is_status_locked: true, is_pending: true)
        approval = @post.approve!
        assert_includes(approval.errors.full_messages, "Post is locked and cannot be approved")
      end
    end
  end

  context "Tagging:" do
    context "A post" do
      setup do
        @post = FactoryBot.create(:post)
      end

      context "with a banned artist" do
        setup do
          CurrentUser.scoped(FactoryBot.create(:admin_user)) do
            @artist = FactoryBot.create(:artist)
            @artist.ban!
          end
          @post = FactoryBot.create(:post, :tag_string => @artist.name)
        end

        should "ban the post" do
          assert_equal(true, @post.is_banned?)
        end
      end

      context "with an artist tag that is then changed to copyright" do
        setup do
          CurrentUser.user = FactoryBot.create(:builder_user)
          @post = Post.find(@post.id)
          @post.update(:tag_string => "art:abc")
          @post = Post.find(@post.id)
          @post.update(:tag_string => "copy:abc")
          @post.reload
        end

        should "update the category of the tag" do
          assert_equal(Tag.categories.copyright, Tag.find_by_name("abc").category)
        end

        should "1234 update the category cache of the tag" do
          assert_equal(Tag.categories.copyright, Cache.get("tc:#{Cache.hash('abc')}"))
        end

        should "update the tag counts of the posts" do
          assert_equal(0, @post.tag_count_artist)
          assert_equal(1, @post.tag_count_copyright)
          assert_equal(0, @post.tag_count_general)
        end
      end

      context "using a tag prefix on an aliased tag" do
        setup do
          FactoryBot.create(:tag_alias, :antecedent_name => "abc", :consequent_name => "xyz")
          @post = Post.find(@post.id)
          @post.update(:tag_string => "art:abc")
          @post.reload
        end

        should "convert the tag to its normalized version" do
          assert_equal("xyz", @post.tag_string)
        end
      end

      context "tagged with a valid tag" do
        subject { @post }

        should allow_value("touhou 100%").for(:tag_string)
        should allow_value("touhou FOO").for(:tag_string)
        should allow_value("touhou -foo").for(:tag_string)
        should allow_value("touhou pool:foo").for(:tag_string)
        should allow_value("touhou -pool:foo").for(:tag_string)
        should allow_value("touhou newpool:foo").for(:tag_string)
        should allow_value("touhou fav:self").for(:tag_string)
        should allow_value("touhou -fav:self").for(:tag_string)
        should allow_value("touhou upvote:self").for(:tag_string)
        should allow_value("touhou downvote:self").for(:tag_string)
        should allow_value("touhou parent:1").for(:tag_string)
        should allow_value("touhou child:1").for(:tag_string)
        should allow_value("touhou source:foo").for(:tag_string)
        should allow_value("touhou rating:z").for(:tag_string)
        should allow_value("touhou locked:rating").for(:tag_string)
        should allow_value("touhou -locked:rating").for(:tag_string)

        # \u3000 = ideographic space, \u00A0 = no-break space
        should allow_value("touhou\u3000foo").for(:tag_string)
        should allow_value("touhou\u00A0foo").for(:tag_string)
      end

      context "tagged with an invalid tag" do
        context "that doesn't already exist" do
          assert_invalid_tag("user:evazion")
          assert_invalid_tag("*~foo")
          assert_invalid_tag("*-foo")
          assert_invalid_tag(",-foo")

          assert_invalid_tag("___")
          assert_invalid_tag("~foo")
          assert_invalid_tag("_foo")
          assert_invalid_tag("foo_")
          assert_invalid_tag("foo__bar")
          assert_invalid_tag("foo*bar")
          assert_invalid_tag("foo,bar")
          assert_invalid_tag("foo\abar")
          assert_invalid_tag("café")
          assert_invalid_tag("東方")
        end

        context "that already exists" do
          setup do
            %W(___ ~foo _foo foo_ foo__bar foo*bar foo,bar foo\abar café 東方 new search).each do |tag|
              build(:tag, name: tag).save(validate: false)
            end
          end

          assert_invalid_tag("___")
          assert_invalid_tag("~foo")
          assert_invalid_tag("_foo")
          assert_invalid_tag("foo_")
          assert_invalid_tag("foo__bar")
          assert_invalid_tag("foo*bar")
          assert_invalid_tag("foo,bar")
          assert_invalid_tag("foo\abar")
          assert_invalid_tag("café")
          assert_invalid_tag("東方")
          assert_invalid_tag("new")
          assert_invalid_tag("search")
        end
      end

      context "tagged with a metatag" do
        context "for typing a tag" do
          setup do
            @post = FactoryBot.create(:post, tag_string: "char:hoge")
            @tags = @post.tag_array
          end

          should "change the type" do
            assert(Tag.where(name: "hoge", category: 4).exists?, "expected 'moge' tag to be created as a character")
          end
        end

        context "for typing an aliased tag" do
          setup do
            @alias = FactoryBot.create(:tag_alias, antecedent_name: "hoge", consequent_name: "moge")
            @post = FactoryBot.create(:post, tag_string: "char:hoge")
            @tags = @post.tag_array
          end

          should "change the type" do
            assert_equal(["moge"], @tags)
            assert(Tag.where(name: "moge", category: 0).exists?, "expected 'moge' tag to be created as a character")
            assert(Tag.where(name: "hoge", category: 4).exists?, "expected 'moge' tag to be created as a character")
          end
        end

        context "for a wildcard implication" do
          setup do
            @post = FactoryBot.create(:post, tag_string: "char:someone_(cosplay) test_school_uniform")
            @tags = @post.tag_array
          end

          should "add the cosplay tag" do
            assert(@tags.include?("cosplay"))
          end

          should "add the school_uniform tag" do
            assert(@tags.include?("school_uniform"))
          end

          should "create the tag" do
            assert(Tag.where(name: "someone_(cosplay)").exists?, "expected 'someone_(cosplay)' tag to be created")
            assert(Tag.where(name: "someone_(cosplay)", category: 4).exists?, "expected 'someone_(cosplay)' tag to be created as character")
            assert(Tag.where(name: "someone", category: 4).exists?, "expected 'someone' tag to be created")
            assert(Tag.where(name: "school_uniform", category: 0).exists?, "expected 'school_uniform' tag to be created")
          end

          should "apply aliases when the character tag is added" do
            FactoryBot.create(:tag, name: "jim", category: Tag.categories.general)
            FactoryBot.create(:tag, name: "james", category: Tag.categories.character)
            FactoryBot.create(:tag_alias, antecedent_name: "jim", consequent_name: "james")

            @post.add_tag("jim_(cosplay)")
            @post.save

            assert(@post.has_tag?("james"), "expected 'jim' to be aliased to 'james'")
          end

          should "apply implications after the character tag is added" do
            FactoryBot.create(:tag, name: "jimmy", category: Tag.categories.character)
            FactoryBot.create(:tag, name: "jim", category: Tag.categories.character)
            FactoryBot.create(:tag_implication, antecedent_name: "jimmy", consequent_name: "jim")
            @post.add_tag("jimmy_(cosplay)")
            @post.save

            assert(@post.has_tag?("jim"), "expected 'jimmy' to imply 'jim'")
          end
        end

        context "for a parent" do
          setup do
            @parent = FactoryBot.create(:post)
          end

          should "update the parent relationships for both posts" do
            @post.update(tag_string: "aaa parent:#{@parent.id}")
            @post.reload
            @parent.reload
            assert_equal(@parent.id, @post.parent_id)
            assert(@parent.has_children?)
          end

          should "not allow self-parenting" do
            @post.update(:tag_string => "parent:#{@post.id}")
            assert_nil(@post.parent_id)
          end

          should "clear the parent with parent:none" do
            @post.update(:parent_id => @parent.id)
            assert_equal(@parent.id, @post.parent_id)

            @post.update(:tag_string => "parent:none")
            assert_nil(@post.parent_id)
          end

          should "clear the parent with -parent:1234" do
            @post.update(:parent_id => @parent.id)
            assert_equal(@parent.id, @post.parent_id)

            @post.update(:tag_string => "-parent:#{@parent.id}")
            assert_nil(@post.parent_id)
          end
        end

        context "for a favgroup" do
          setup do
            @favgroup = FactoryBot.create(:favorite_group, creator: @user)
            @post = FactoryBot.create(:post, :tag_string => "aaa favgroup:#{@favgroup.id}")
          end

          should "add the post to the favgroup" do
            assert_equal(1, @favgroup.reload.post_count)
            assert_equal(true, @favgroup.contains?(@post.id))
          end

          should "remove the post from the favgroup" do
            @post.update(:tag_string => "-favgroup:#{@favgroup.id}")

            assert_equal(0, @favgroup.reload.post_count)
            assert_equal(false, @favgroup.contains?(@post.id))
          end
        end

        context "for a pool" do
          context "on creation" do
            setup do
              @pool = FactoryBot.create(:pool)
              @post = FactoryBot.create(:post, :tag_string => "aaa pool:#{@pool.id}")
            end

            should "add the post to the pool" do
              @post.reload
              @pool.reload
              assert_equal([@post.id], @pool.post_ids)
              assert_equal("pool:#{@pool.id}", @post.pool_string)
            end
          end

          context "negated" do
            setup do
              @pool = FactoryBot.create(:pool)
              @post = FactoryBot.create(:post, :tag_string => "aaa")
              @post.add_pool!(@pool)
              @post.tag_string = "aaa -pool:#{@pool.id}"
              @post.save
            end

            should "remove the post from the pool" do
              @post.reload
              @pool.reload
              assert_equal([], @pool.post_ids)
              assert_equal("", @post.pool_string)
            end
          end

          context "id" do
            setup do
              @pool = FactoryBot.create(:pool)
              @post.update(tag_string: "aaa pool:#{@pool.id}")
            end

            should "add the post to the pool" do
              @post.reload
              @pool.reload
              assert_equal([@post.id], @pool.post_ids)
              assert_equal("pool:#{@pool.id}", @post.pool_string)
            end
          end

          context "name" do
            context "that exists" do
              setup do
                @pool = FactoryBot.create(:pool, :name => "abc")
                @post.update(tag_string: "aaa pool:abc")
              end

              should "add the post to the pool" do
                @post.reload
                @pool.reload
                assert_equal([@post.id], @pool.post_ids)
                assert_equal("pool:#{@pool.id}", @post.pool_string)
              end
            end

            context "that doesn't exist" do
              should "create a new pool and add the post to that pool" do
                @post.update(tag_string: "aaa newpool:abc")
                @pool = Pool.find_by_name("abc")
                @post.reload
                assert_not_nil(@pool)
                assert_equal([@post.id], @pool.post_ids)
                assert_equal("pool:#{@pool.id}", @post.pool_string)
              end
            end

            context "with special characters" do
              should "not strip '%' from the name" do
                @post.update(tag_string: "aaa newpool:ichigo_100%")
                assert(Pool.exists?(name: "ichigo_100%"))
              end
            end
          end
        end

        context "for a rating" do
          context "that is valid" do
            should "update the rating if the post is unlocked" do
              @post.update(tag_string: "aaa rating:e")
              @post.reload
              assert_equal("e", @post.rating)
            end
          end

          context "that is invalid" do
            should "not update the rating" do
              @post.update(tag_string: "aaa rating:z")
              @post.reload
              assert_equal("q", @post.rating)
            end
          end

          context "that is locked" do
            should "change the rating if locked in the same update" do
              @post.update(tag_string: "rating:e", is_rating_locked: true)

              assert(@post.valid?)
              assert_equal("e", @post.reload.rating)
            end

            should "not change the rating if locked previously" do
              @post.is_rating_locked = true
              @post.save

              @post.update(:tag_string => "rating:e")

              assert(@post.invalid?)
              assert_not_equal("e", @post.reload.rating)
            end
          end
        end

        context "for a fav" do
          should "add/remove the current user to the post's favorite listing" do
            @post.update(tag_string: "aaa fav:self")
            assert_equal("fav:#{@user.id}", @post.fav_string)

            @post.update(tag_string: "aaa -fav:self")
            assert_equal("", @post.fav_string)
          end

          should "not fail when the fav: metatag is used twice" do
            @post.update(tag_string: "aaa fav:self fav:me")
            assert_equal("fav:#{@user.id}", @post.fav_string)

            @post.update(tag_string: "aaa -fav:self -fav:me")
            assert_equal("", @post.fav_string)
          end
        end

        context "for a child" do
          should "add and remove children" do
            @children = FactoryBot.create_list(:post, 3, parent_id: nil)

            @post.update(tag_string: "aaa child:#{@children.first.id}..#{@children.last.id}")
            assert_equal(true, @post.reload.has_children?)
            assert_equal(@post.id, @children[0].reload.parent_id)
            assert_equal(@post.id, @children[1].reload.parent_id)
            assert_equal(@post.id, @children[2].reload.parent_id)

            @post.update(tag_string: "aaa -child:#{@children.first.id}")
            assert_equal(true, @post.reload.has_children?)
            assert_nil(@children[0].reload.parent_id)
            assert_equal(@post.id, @children[1].reload.parent_id)
            assert_equal(@post.id, @children[2].reload.parent_id)

            @post.update(tag_string: "aaa child:none")
            assert_equal(false, @post.reload.has_children?)
            assert_nil(@children[0].reload.parent_id)
            assert_nil(@children[1].reload.parent_id)
            assert_nil(@children[2].reload.parent_id)
          end
        end

        context "for status:active" do
          should "approve the post if the user has permission" do
            as(create(:approver)) do
              @post.update!(is_pending: true)
              @post.update(tag_string: "aaa status:active")
            end

            assert_equal(false, @post.reload.is_pending?)
          end

          should "not approve the post if the user is doesn't have permission" do
            assert_raises(User::PrivilegeError) do
              @post.update!(is_pending: true)
              @post.update(tag_string: "aaa status:active")
            end

            assert_equal(true, @post.reload.is_pending?)
          end
        end

        context "for status:banned" do
          should "ban the post if the user has permission" do
            as(create(:approver)) do
              @post.update(tag_string: "aaa status:banned")
            end

            assert_equal(true, @post.reload.is_banned?)
          end

          should "not ban the post if the user doesn't have permission" do
            assert_raises(User::PrivilegeError) do
              @post.update(tag_string: "aaa status:banned")
            end

            assert_equal(false, @post.reload.is_banned?)
          end
        end

        context "for -status:banned" do
          should "unban the post if the user has permission" do
            as(create(:approver)) do
              @post.update!(is_banned: true)
              @post.update(tag_string: "aaa -status:banned")
            end

            assert_equal(false, @post.reload.is_banned?)
          end

          should "not unban the post if the user doesn't have permission" do
            assert_raises(User::PrivilegeError) do
              @post.update!(is_banned: true)
              @post.update(tag_string: "aaa status:banned")
            end

            assert_equal(true, @post.reload.is_banned?)
          end
        end

        context "for disapproved:<reason>" do
          should "disapprove the post if the user has permission" do
            @user = create(:approver)

            as(@user) do
              @post.update!(is_pending: true)
              @post.update(tag_string: "aaa disapproved:disinterest")
            end

            assert_equal(@post.id, PostDisapproval.last.post_id)
            assert_equal(@user.id, PostDisapproval.last.user_id)
            assert_equal("disinterest", PostDisapproval.last.reason)
          end

          should "not disapprove the post if the user is doesn't have permission" do
            assert_raises(User::PrivilegeError) do
              @post.update!(is_pending: true)
              @post.update(tag_string: "aaa disapproved:disinterest")
            end

            assert_equal(0, @post.disapprovals.count)
          end

          should "not allow disapproving active posts" do
            assert_raises(User::PrivilegeError) do
              @post.update(tag_string: "aaa disapproved:disinterest")
            end

            assert_equal(0, @post.disapprovals.count)
          end
        end

        context "for a source" do
          should "set the source with source:foo_bar_baz" do
            @post.update(:tag_string => "source:foo_bar_baz")
            assert_equal("foo_bar_baz", @post.source)
          end

          should 'set the source with source:"foo bar baz"' do
            @post.update(:tag_string => 'source:"foo bar baz"')
            assert_equal("foo bar baz", @post.source)
          end

          should 'strip the source with source:"  foo bar baz  "' do
            @post.update(:tag_string => 'source:"  foo bar baz  "')
            assert_equal("foo bar baz", @post.source)
          end

          should "clear the source with source:none" do
            @post.update(:source => "foobar")
            @post.update(:tag_string => "source:none")
            assert_equal("", @post.source)
          end

          should "set the pixiv id with source:https://img18.pixiv.net/img/evazion/14901720.png" do
            @post.update(:tag_string => "source:https://img18.pixiv.net/img/evazion/14901720.png")
            assert_equal(14901720, @post.pixiv_id)
          end
        end

        context "of" do
          setup do
            @builder = FactoryBot.create(:builder_user)
          end

          context "locked:notes" do
            context "by a member" do
              should "not lock the notes" do
                @post.update(:tag_string => "locked:notes")
                assert_equal(false, @post.is_note_locked)
              end
            end

            context "by a builder" do
              should "lock/unlock the notes" do
                CurrentUser.scoped(@builder) do
                  @post.update(:tag_string => "locked:notes")
                  assert_equal(true, @post.is_note_locked)

                  @post.update(:tag_string => "-locked:notes")
                  assert_equal(false, @post.is_note_locked)
                end
              end
            end
          end

          context "locked:rating" do
            context "by a member" do
              should "not lock the rating" do
                @post.update(:tag_string => "locked:rating")
                assert_equal(false, @post.is_rating_locked)
              end
            end

            context "by a builder" do
              should "lock/unlock the rating" do
                CurrentUser.scoped(@builder) do
                  @post.update(:tag_string => "locked:rating")
                  assert_equal(true, @post.is_rating_locked)

                  @post.update(:tag_string => "-locked:rating")
                  assert_equal(false, @post.is_rating_locked)
                end
              end
            end
          end

          context "locked:status" do
            context "by a member" do
              should "not lock the status" do
                @post.update(:tag_string => "locked:status")
                assert_equal(false, @post.is_status_locked)
              end
            end

            context "by an admin" do
              should "lock/unlock the status" do
                CurrentUser.scoped(FactoryBot.create(:admin_user)) do
                  @post.update(:tag_string => "locked:status")
                  assert_equal(true, @post.is_status_locked)

                  @post.update(:tag_string => "-locked:status")
                  assert_equal(false, @post.is_status_locked)
                end
              end
            end
          end
        end

        context "of" do
          setup do
            @gold = FactoryBot.create(:gold_user)
          end

          context "upvote:self or downvote:self" do
            context "by a member" do
              should "not upvote the post" do
                assert_raises PostVote::Error do
                  @post.update(:tag_string => "upvote:self")
                end

                assert_equal(0, @post.score)
              end

              should "not downvote the post" do
                assert_raises PostVote::Error do
                  @post.update(:tag_string => "downvote:self")
                end

                assert_equal(0, @post.score)
              end
            end

            context "by a gold user" do
              should "upvote the post" do
                CurrentUser.scoped(FactoryBot.create(:gold_user)) do
                  @post.update(:tag_string => "tag1 tag2 upvote:self")
                  assert_equal(false, @post.errors.any?)
                  assert_equal(1, @post.score)
                end
              end

              should "downvote the post" do
                CurrentUser.scoped(FactoryBot.create(:gold_user)) do
                  @post.update(:tag_string => "tag1 tag2 downvote:self")
                  assert_equal(false, @post.errors.any?)
                  assert_equal(-1, @post.score)
                end
              end
            end
          end
        end
      end

      context "tagged with a negated tag" do
        should "remove the tag if present" do
          @post.update(tag_string: "aaa bbb ccc")
          @post.update(tag_string: "aaa bbb ccc -bbb")
          @post.reload
          assert_equal("aaa ccc", @post.tag_string)
        end

        should "resolve aliases" do
          FactoryBot.create(:tag_alias, :antecedent_name => "/tr", :consequent_name => "translation_request")
          @post.update(:tag_string => "aaa translation_request -/tr")

          assert_equal("aaa", @post.tag_string)
        end
      end

      context "tagged with animated_gif or animated_png" do
        should "remove the tag if not a gif or png" do
          @post.update(tag_string: "tagme animated_gif")
          assert_equal("tagme", @post.tag_string)

          @post.update(tag_string: "tagme animated_png")
          assert_equal("tagme", @post.tag_string)
        end
      end

      should "have an array representation of its tags" do
        post = FactoryBot.create(:post)
        post.reload
        post.set_tag_string("aaa bbb")
        assert_equal(%w(aaa bbb), post.tag_array)
        assert_equal(%w(tag1 tag2), post.tag_array_was)
      end

      context "with large dimensions" do
        setup do
          @post.image_width = 10_000
          @post.image_height = 10
          @post.tag_string = ""
          @post.save
        end

        should "have the appropriate dimension tags added automatically" do
          assert_match(/incredibly_absurdres/, @post.tag_string)
          assert_match(/absurdres/, @post.tag_string)
          assert_match(/highres/, @post.tag_string)
        end
      end

      context "with a large file size" do
        setup do
          @post.file_size = 11.megabytes
          @post.tag_string = ""
          @post.save
        end

        should "have the appropriate file size tags added automatically" do
          assert_match(/huge_filesize/, @post.tag_string)
        end
      end

      context "with a .zip file extension" do
        setup do
          @post.file_ext = "zip"
          @post.tag_string = ""
          @post.save
        end

        should "have the appropriate file type tag added automatically" do
          assert_match(/ugoira/, @post.tag_string)
        end
      end

      context "with a .webm file extension" do
        setup do
          FactoryBot.create(:tag_implication, antecedent_name: "video", consequent_name: "animated")
          @post.file_ext = "webm"
          @post.tag_string = ""
          @post.save
        end

        should "have the appropriate file type tag added automatically" do
          assert_match(/video/, @post.tag_string)
        end

        should "apply implications after adding the file type tag" do
          assert(@post.has_tag?("animated"), "expected 'video' to imply 'animated'")
        end
      end

      context "with a .swf file extension" do
        setup do
          @post.file_ext = "swf"
          @post.tag_string = ""
          @post.save
        end

        should "have the appropriate file type tag added automatically" do
          assert_match(/flash/, @post.tag_string)
        end
      end

      context "with *_(cosplay) tags" do
        should "add the character tags and the cosplay tag" do
          @post.add_tag("hakurei_reimu_(cosplay)")
          @post.add_tag("hatsune_miku_(cosplay)")
          @post.save

          assert(@post.has_tag?("hakurei_reimu"))
          assert(@post.has_tag?("hatsune_miku"))
          assert(@post.has_tag?("cosplay"))
        end

        should "not add the _(cosplay) tag if it conflicts with an existing tag" do
          create(:tag, name: "little_red_riding_hood", category: Tag.categories.copyright)
          @post = create(:post, tag_string: "little_red_riding_hood_(cosplay)")

          refute(@post.has_tag?("little_red_riding_hood"))
          refute(@post.has_tag?("cosplay"))
          assert(@post.warnings[:base].grep(/Couldn't add tag/).present?)
        end

        should "allow creating a _(cosplay) tag for an empty general tag" do
          @tag = create(:tag, name: "hatsune_miku", post_count: 0, category: Tag.categories.general)
          @post = create(:post, tag_string: "hatsune_miku_(cosplay)")

          assert_equal("cosplay hatsune_miku hatsune_miku_(cosplay)", @post.reload.tag_string)
          assert_equal(true, @tag.reload.character?)
        end
      end

      context "that has been updated" do
        should "create a new version if it's the first version" do
          assert_difference("PostVersion.count", 1) do
            post = FactoryBot.create(:post)
          end
        end

        should "create a new version if it's been over an hour since the last update" do
          post = FactoryBot.create(:post)
          travel(6.hours) do
            assert_difference("PostVersion.count", 1) do
              post.update(tag_string: "zzz")
            end
          end
        end

        should "merge with the previous version if the updater is the same user and it's been less than an hour" do
          post = FactoryBot.create(:post)
          assert_difference("PostVersion.count", 0) do
            post.update(tag_string: "zzz")
          end
          assert_equal("zzz", post.versions.last.tags)
        end

        should "increment the updater's post_update_count" do
          PostVersion.sqs_service.stubs(:merge?).returns(false)
          post = FactoryBot.create(:post, :tag_string => "aaa bbb ccc")

          # XXX in the test environment the update count gets bumped twice: and
          # once by Post#post_update_count, and once by the counter cache. in
          # production the counter cache doesn't bump the count, because
          # versions are created on a separate server.
          assert_difference("CurrentUser.user.reload.post_update_count", 2) do
            post.update(tag_string: "zzz")
          end
        end

        should "reset its tag array cache" do
          post = FactoryBot.create(:post, :tag_string => "aaa bbb ccc")
          user = FactoryBot.create(:user)
          assert_equal(%w(aaa bbb ccc), post.tag_array)
          post.tag_string = "ddd eee fff"
          post.tag_string = "ddd eee fff"
          post.save
          assert_equal("ddd eee fff", post.tag_string)
          assert_equal(%w(ddd eee fff), post.tag_array)
        end

        should "create the actual tag records" do
          assert_difference("Tag.count", 3) do
            post = FactoryBot.create(:post, :tag_string => "aaa bbb ccc")
          end
        end

        should "update the post counts of relevant tag records" do
          post1 = FactoryBot.create(:post, :tag_string => "aaa bbb ccc")
          post2 = FactoryBot.create(:post, :tag_string => "bbb ccc ddd")
          post3 = FactoryBot.create(:post, :tag_string => "ccc ddd eee")
          assert_equal(1, Tag.find_by_name("aaa").post_count)
          assert_equal(2, Tag.find_by_name("bbb").post_count)
          assert_equal(3, Tag.find_by_name("ccc").post_count)
          post3.reload
          post3.tag_string = "xxx"
          post3.save
          assert_equal(1, Tag.find_by_name("aaa").post_count)
          assert_equal(2, Tag.find_by_name("bbb").post_count)
          assert_equal(2, Tag.find_by_name("ccc").post_count)
          assert_equal(1, Tag.find_by_name("ddd").post_count)
          assert_equal(0, Tag.find_by_name("eee").post_count)
          assert_equal(1, Tag.find_by_name("xxx").post_count)
        end

        should "update its tag counts" do
          artist_tag = FactoryBot.create(:artist_tag)
          copyright_tag = FactoryBot.create(:copyright_tag)
          general_tag = FactoryBot.create(:tag)
          new_post = FactoryBot.create(:post, :tag_string => "#{artist_tag.name} #{copyright_tag.name} #{general_tag.name}")
          assert_equal(1, new_post.tag_count_artist)
          assert_equal(1, new_post.tag_count_copyright)
          assert_equal(1, new_post.tag_count_general)
          assert_equal(0, new_post.tag_count_character)
          assert_equal(3, new_post.tag_count)

          new_post.tag_string = "babs"
          new_post.save
          assert_equal(0, new_post.tag_count_artist)
          assert_equal(0, new_post.tag_count_copyright)
          assert_equal(1, new_post.tag_count_general)
          assert_equal(0, new_post.tag_count_character)
          assert_equal(1, new_post.tag_count)
        end

        should "merge any tag changes that were made after loading the initial set of tags part 1" do
          post = FactoryBot.create(:post, :tag_string => "aaa bbb ccc")

          # user a adds <ddd>
          post_edited_by_user_a = Post.find(post.id)
          post_edited_by_user_a.old_tag_string = "aaa bbb ccc"
          post_edited_by_user_a.tag_string = "aaa bbb ccc ddd"
          post_edited_by_user_a.save

          # user b removes <ccc> adds <eee>
          post_edited_by_user_b = Post.find(post.id)
          post_edited_by_user_b.old_tag_string = "aaa bbb ccc"
          post_edited_by_user_b.tag_string = "aaa bbb eee"
          post_edited_by_user_b.save

          # final should be <aaa>, <bbb>, <ddd>, <eee>
          final_post = Post.find(post.id)
          assert_equal("aaa bbb ddd eee", final_post.tag_string)
        end

        should "merge any tag changes that were made after loading the initial set of tags part 2" do
          # This is the same as part 1, only the order of operations is reversed.
          # The results should be the same.

          post = FactoryBot.create(:post, :tag_string => "aaa bbb ccc")

          # user a removes <ccc> adds <eee>
          post_edited_by_user_a = Post.find(post.id)
          post_edited_by_user_a.old_tag_string = "aaa bbb ccc"
          post_edited_by_user_a.tag_string = "aaa bbb eee"
          post_edited_by_user_a.save

          # user b adds <ddd>
          post_edited_by_user_b = Post.find(post.id)
          post_edited_by_user_b.old_tag_string = "aaa bbb ccc"
          post_edited_by_user_b.tag_string = "aaa bbb ccc ddd"
          post_edited_by_user_b.save

          # final should be <aaa>, <bbb>, <ddd>, <eee>
          final_post = Post.find(post.id)
          assert_equal("aaa bbb ddd eee", final_post.tag_string)
        end

        should "merge any parent, source, and rating changes that were made after loading the initial set" do
          post = FactoryBot.create(:post, :parent => nil, :source => "", :rating => "q")
          parent_post = FactoryBot.create(:post)

          # user a changes rating to safe, adds parent
          post_edited_by_user_a = Post.find(post.id)
          post_edited_by_user_a.old_parent_id = ""
          post_edited_by_user_a.old_source = ""
          post_edited_by_user_a.old_rating = "q"
          post_edited_by_user_a.parent_id = parent_post.id
          post_edited_by_user_a.source = nil
          post_edited_by_user_a.rating = "s"
          post_edited_by_user_a.save

          # user b adds source
          post_edited_by_user_b = Post.find(post.id)
          post_edited_by_user_b.old_parent_id = ""
          post_edited_by_user_b.old_source = ""
          post_edited_by_user_b.old_rating = "q"
          post_edited_by_user_b.parent_id = nil
          post_edited_by_user_b.source = "http://example.com"
          post_edited_by_user_b.rating = "q"
          post_edited_by_user_b.save

          # final post should be rated safe and have the set parent and source
          final_post = Post.find(post.id)
          assert_equal(parent_post.id, final_post.parent_id)
          assert_equal("http://example.com", final_post.source)
          assert_equal("s", final_post.rating)
        end
      end

      context "that has been tagged with a metatag" do
        should "not include the metatag in its tag string" do
          post = FactoryBot.create(:post)
          post.tag_string = "aaa pool:1234 pool:test rating:s fav:bob"
          post.save
          assert_equal("aaa", post.tag_string)
        end
      end

      context "with a source" do
        context "that is not from pixiv" do
          should "clear the pixiv id" do
            @post.pixiv_id = 1234
            @post.update(source: "http://fc06.deviantart.net/fs71/f/2013/295/d/7/you_are_already_dead__by_mar11co-d6rgm0e.jpg")
            assert_nil(@post.pixiv_id)

            @post.pixiv_id = 1234
            @post.update(source: "http://pictures.hentai-foundry.com//a/AnimeFlux/219123.jpg")
            assert_nil(@post.pixiv_id)
          end
        end

        context "that is from pixiv" do
          should "save the pixiv id" do
            @post.update(source: "http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p0.png")
            assert_equal(46304396, @post.pixiv_id)
            @post.pixiv_id = nil
          end
        end
      end

      context "when validating tags" do
        should "warn when creating a new general tag" do
          @post.add_tag("tag")
          @post.save

          assert_match(/Created 1 new tag: \[\[tag\]\]/, @post.warnings.full_messages.join)
        end

        should "warn when adding an artist tag without an artist entry" do
          @post.add_tag("artist:bkub")
          @post.save

          assert_match(/Artist \[\[bkub\]\] requires an artist entry./, @post.warnings.full_messages.join)
        end

        should "warn when a tag removal failed due to implications or automatic tags" do
          ti = FactoryBot.create(:tag_implication, antecedent_name: "cat", consequent_name: "animal")
          @post.reload
          @post.update(old_tag_string: @post.tag_string, tag_string: "chen_(cosplay) char:chen cosplay cat animal")
          @post.warnings.clear
          @post.reload
          @post.update(old_tag_string: @post.tag_string, tag_string: "chen_(cosplay) chen cosplay cat -cosplay")

          assert_match(/\[\[animal\]\] and \[\[cosplay\]\] could not be removed./, @post.warnings.full_messages.join)
        end

        should "warn when a post from a known source is missing an artist tag" do
          post = FactoryBot.build(:post, source: "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=65985331")
          post.save
          assert_match(/Artist tag is required/, post.warnings.full_messages.join)
        end

        should "warn when missing a copyright tag" do
          assert_match(/Copyright tag is required/, @post.warnings.full_messages.join)
        end

        should "warn when an upload doesn't have enough tags" do
          post = FactoryBot.create(:post, tag_string: "tagme")
          assert_match(/Uploads must have at least \d+ general tags/, post.warnings.full_messages.join)
        end
      end
    end
  end

  context "Updating:" do
    context "an existing post" do
      setup { @post = FactoryBot.create(:post) }

      should "call Tag.increment_post_counts with the correct params" do
        @post.reload
        Tag.expects(:increment_post_counts).once.with(["abc"])
        @post.update(tag_string: "tag1 abc")
      end
    end

    context "A rating unlocked post" do
      setup { @post = FactoryBot.create(:post) }
      subject { @post }

      should "not allow values S, safe, derp" do
        ["S", "safe", "derp"].each do |rating|
          subject.rating = rating
          assert(!subject.valid?)
        end
      end

      should "allow values s, q, e" do
        ["s", "q", "e"].each do |rating|
          subject.rating = rating
          assert(subject.valid?)
        end
      end
    end

    context "A rating locked post" do
      setup { @post = FactoryBot.create(:post, :is_rating_locked => true) }
      subject { @post }

      should "not allow values S, safe, derp" do
        ["S", "safe", "derp"].each do |rating|
          subject.rating = rating
          assert(!subject.valid?)
        end
      end

      should "not allow values s, e" do
        ["s", "e"].each do |rating|
          subject.rating = rating
          assert(!subject.valid?)
        end
      end
    end
  end

  context "Favorites:" do
    context "Removing a post from a user's favorites" do
      setup do
        @user = FactoryBot.create(:contributor_user)
        @post = FactoryBot.create(:post)
        @post.add_favorite!(@user)
        @user.reload
      end

      should "decrement the user's favorite_count" do
        assert_difference("@user.favorite_count", -1) do
          @post.remove_favorite!(@user)
        end
      end

      should "decrement the post's score for gold users" do
        assert_difference("@post.score", -1) do
          @post.remove_favorite!(@user)
        end
      end

      should "not decrement the post's score for basic users" do
        @member = FactoryBot.create(:user)

        assert_no_difference("@post.score") { @post.add_favorite!(@member) }
        assert_no_difference("@post.score") { @post.remove_favorite!(@member) }
      end

      should "not decrement the user's favorite_count if the user did not favorite the post" do
        @post2 = FactoryBot.create(:post)
        assert_no_difference("@user.favorite_count") do
          @post2.remove_favorite!(@user)
        end
      end
    end

    context "Adding a post to a user's favorites" do
      setup do
        @user = FactoryBot.create(:contributor_user)
        @post = FactoryBot.create(:post)
      end

      should "periodically clean the fav_string" do
        @post.update_column(:fav_string, "fav:1 fav:1 fav:1")
        @post.update_column(:fav_count, 3)
        @post.stubs(:clean_fav_string?).returns(true)
        @post.append_user_to_fav_string(2)
        assert_equal("fav:1 fav:2", @post.fav_string)
        assert_equal(2, @post.fav_count)
      end

      should "increment the user's favorite_count" do
        assert_difference("@user.favorite_count", 1) do
          @post.add_favorite!(@user)
        end
      end

      should "increment the post's score for gold users" do
        @post.add_favorite!(@user)
        assert_equal(1, @post.score)
      end

      should "not increment the post's score for basic users" do
        @member = FactoryBot.create(:user)
        @post.add_favorite!(@member)
        assert_equal(0, @post.score)
      end

      should "update the fav strings on the post" do
        @post.add_favorite!(@user)
        @post.reload
        assert_equal("fav:#{@user.id}", @post.fav_string)
        assert(Favorite.exists?(:user_id => @user.id, :post_id => @post.id))

        assert_raises(Favorite::Error) { @post.add_favorite!(@user) }
        @post.reload
        assert_equal("fav:#{@user.id}", @post.fav_string)
        assert(Favorite.exists?(:user_id => @user.id, :post_id => @post.id))

        @post.remove_favorite!(@user)
        @post.reload
        assert_equal("", @post.fav_string)
        assert(!Favorite.exists?(:user_id => @user.id, :post_id => @post.id))

        @post.remove_favorite!(@user)
        @post.reload
        assert_equal("", @post.fav_string)
        assert(!Favorite.exists?(:user_id => @user.id, :post_id => @post.id))
      end
    end

    context "Moving favorites to a parent post" do
      setup do
        @parent = FactoryBot.create(:post)
        @child = FactoryBot.create(:post, parent: @parent)

        @user1 = FactoryBot.create(:user, enable_private_favorites: true)
        @gold1 = FactoryBot.create(:gold_user)

        @child.add_favorite!(@user1)
        @child.add_favorite!(@gold1)

        @child.give_favorites_to_parent
        @child.reload
        @parent.reload
      end

      should "move the favorites" do
        assert_equal(0, @child.fav_count)
        assert_equal(0, @child.favorites.count)
        assert_equal("", @child.fav_string)
        assert_equal([], @child.favorites.pluck(:user_id))

        assert_equal(2, @parent.fav_count)
        assert_equal(2, @parent.favorites.count)
        assert_equal("fav:#{@user1.id} fav:#{@gold1.id}", @parent.fav_string)
        assert_equal([@user1.id, @gold1.id], @parent.favorites.pluck(:user_id))
      end

      should "create a vote for each user who can vote" do
        assert(@parent.votes.where(user: @gold1).exists?)
        assert_equal(1, @parent.score)
      end
    end
  end

  context "Pools:" do
    setup do
      SqsService.any_instance.stubs(:send_message)
    end

    context "Removing a post from a pool" do
      should "update the post's pool string" do
        post = FactoryBot.create(:post)
        pool = FactoryBot.create(:pool)
        post.add_pool!(pool)
        post.remove_pool!(pool)
        post.reload
        assert_equal("", post.pool_string)
        post.remove_pool!(pool)
        post.reload
        assert_equal("", post.pool_string)
      end
    end

    context "Adding a post to a pool" do
      should "update the post's pool string" do
        post = FactoryBot.create(:post)
        pool = FactoryBot.create(:pool)
        post.add_pool!(pool)
        post.reload
        assert_equal("pool:#{pool.id}", post.pool_string)
        post.add_pool!(pool)
        post.reload
        assert_equal("pool:#{pool.id}", post.pool_string)
        post.remove_pool!(pool)
        post.reload
        assert_equal("", post.pool_string)
      end
    end
  end

  context "Uploading:" do
    context "Uploading a post" do
      should "capture who uploaded the post" do
        post = FactoryBot.create(:post)
        user1 = FactoryBot.create(:user)
        user2 = FactoryBot.create(:user)
        user3 = FactoryBot.create(:user)

        post.uploader = user1
        assert_equal(user1.id, post.uploader_id)

        post.uploader_id = user2.id
        assert_equal(user2.id, post.uploader_id)
        assert_equal(user2.id, post.uploader_id)
        assert_equal(user2.name, post.uploader.name)
      end

      context "tag post counts" do
        setup { @post = FactoryBot.build(:post) }

        should "call Tag.increment_post_counts with the correct params" do
          Tag.expects(:increment_post_counts).once.with(["tag1", "tag2"])
          @post.save
        end
      end

      should "increment the uploaders post_upload_count" do
        assert_difference(-> { CurrentUser.user.post_upload_count }) do
          post = FactoryBot.create(:post, uploader: CurrentUser.user)
          CurrentUser.user.reload
        end
      end
    end
  end

  context "Voting:" do
    should "not allow members to vote" do
      @user = FactoryBot.create(:user)
      @post = FactoryBot.create(:post)
      as(@user) do
        assert_raises(PostVote::Error) { @post.vote!("up") }
      end
    end

    should "not allow duplicate votes" do
      user = FactoryBot.create(:gold_user)
      post = FactoryBot.create(:post)
      CurrentUser.scoped(user, "127.0.0.1") do
        assert_nothing_raised {post.vote!("up")}
        assert_raises(PostVote::Error) {post.vote!("up")}
        post.reload
        assert_equal(1, PostVote.count)
        assert_equal(1, post.score)
      end
    end

    should "allow undoing of votes" do
      user = FactoryBot.create(:gold_user)
      post = FactoryBot.create(:post)

      # We deliberately don't call post.reload until the end to verify that
      # post.unvote! returns the correct score even when not forcibly reloaded.
      CurrentUser.scoped(user, "127.0.0.1") do
        post.vote!("up")
        assert_equal(1, post.score)

        post.unvote!
        assert_equal(0, post.score)

        assert_nothing_raised {post.vote!("down")}
        assert_equal(-1, post.score)

        post.unvote!
        assert_equal(0, post.score)

        assert_nothing_raised {post.vote!("up")}
        assert_equal(1, post.score)

        post.reload
        assert_equal(1, post.score)
      end
    end
  end

  context "Reverting: " do
    context "a post that is rating locked" do
      setup do
        @post = FactoryBot.create(:post, :rating => "s")
        travel(2.hours) do
          @post.update(rating: "q", is_rating_locked: true)
        end
      end

      should "not revert the rating" do
        assert_raises ActiveRecord::RecordInvalid do
          @post.revert_to!(@post.versions.first)
        end

        assert_equal(["Rating is locked and cannot be changed. Unlock the post first."], @post.errors.full_messages)
        assert_equal(@post.versions.last.rating, @post.reload.rating)
      end

      should "revert the rating after unlocking" do
        @post.update(rating: "e", is_rating_locked: false)
        assert_nothing_raised do
          @post.revert_to!(@post.versions.first)
        end

        assert(@post.valid?)
        assert_equal(@post.versions.first.rating, @post.rating)
      end
    end

    context "a post that has been updated" do
      setup do
        PostVersion.sqs_service.stubs(:merge?).returns(false)
        @post = FactoryBot.create(:post, :rating => "q", :tag_string => "aaa", :source => "")
        @post.reload
        @post.update(:tag_string => "aaa bbb ccc ddd")
        @post.reload
        @post.update(:tag_string => "bbb xxx yyy", :source => "xyz")
        @post.reload
        @post.update(:tag_string => "bbb mmm yyy", :source => "abc")
        @post.reload
      end

      context "and then reverted to an early version" do
        setup do
          @post.revert_to(@post.versions[1])
        end

        should "correctly revert all fields" do
          assert_equal("aaa bbb ccc ddd", @post.tag_string)
          assert_equal("", @post.source)
          assert_equal("q", @post.rating)
        end
      end

      context "and then reverted to a later version" do
        setup do
          @post.revert_to(@post.versions[-2])
        end

        should "correctly revert all fields" do
          assert_equal("bbb xxx yyy", @post.tag_string)
          assert_equal("xyz", @post.source)
          assert_equal("q", @post.rating)
        end
      end
    end
  end

  context "URLs:" do
    should "generate the correct urls for animated gifs" do
      manager = StorageManager::Local.new(base_url: "https://test.com/data")
      Danbooru.config.stubs(:storage_manager).returns(manager)

      @post = build(:post, md5: "deadbeef", file_ext: "gif", tag_string: "animated_gif")

      assert_equal("https://test.com/data/preview/deadbeef.jpg", @post.preview_file_url)
      assert_equal("https://test.com/data/deadbeef.gif", @post.large_file_url)
      assert_equal("https://test.com/data/deadbeef.gif", @post.file_url)
    end
  end

  context "#replace!" do
    subject { @post.replace!(tags: "something", replacement_url: "https://danbooru.donmai.us/images/download-preview.png") }

    setup do
      @post = FactoryBot.create(:post)
      @post.stubs(:queue_delete_files)
    end

    should "update the post" do
      assert_changes(-> { @post.md5 }) do
        subject
      end
    end
  end
end
