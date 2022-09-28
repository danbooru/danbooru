require 'test_helper'

class PostTest < ActiveSupport::TestCase
  def self.assert_invalid_tag(tag_name)
    should "not allow '#{tag_name}' to be tagged" do
      post = create(:post, tag_string: "touhou #{tag_name}")

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
  end

  def teardown
    super

    CurrentUser.user = nil
  end

  context "Deletion:" do
    context "Expunging a post" do
      setup do
        @post = create(:post_with_file, uploader: @user, filename: "test.jpg")
        Favorite.create!(post: @post, user: @user)
        create(:favorite_group, post_ids: [@post.id])
        perform_enqueued_jobs # perform IqdbAddPostJob
      end

      should "log a modaction" do
        @post.expunge!(@user)

        assert_equal(1, ModAction.count)
        assert_equal("post_permanent_delete", ModAction.last.category)
        assert_equal(@user, ModAction.last.creator)
        assert_nil(ModAction.last.subject)
      end

      should "delete the files" do
        assert_nothing_raised { @post.file(:preview) }
        assert_nothing_raised { @post.file(:original) }

        @post.expunge!

        assert_raise(StandardError) { @post.file(:preview) }
        assert_raise(StandardError) { @post.file(:original) }
      end

      should "mark the media asset as deleted" do
        @post.expunge!

        assert_equal("deleted", @post.media_asset.status)
      end

      should "remove all favorites" do
        @post.expunge!

        assert_equal(0, @post.favorites.count)
        assert_equal(0, @user.favorites.count)
        assert_equal(0, @user.reload.favorite_count)
      end

      should "remove all favgroups" do
        assert_equal(1, FavoriteGroup.for_post(@post.id).count)
        @post.expunge!
        assert_equal(0, FavoriteGroup.for_post(@post.id).count)
      end

      should "destroy all modactions belonging to the post" do
        create(:mod_action, description: "deleted post ##{@post.id}", category: :post_delete, subject: @post)
        create(:mod_action, description: "undeleted post ##{@post.id}", category: :post_undelete, subject: @post)
        create(:mod_action, description: "banned post ##{@post.id}", category: :post_ban, subject: @post)
        create(:mod_action, description: "unbanned post ##{@post.id}", category: :post_unban, subject: @post)

        @post.expunge!(@user)

        assert_equal(1, ModAction.count)
        assert_equal("post_permanent_delete", ModAction.last.category)
        assert_equal(@user, ModAction.last.creator)
        assert_nil(ModAction.last.subject)
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
        @post.expunge!
        perform_enqueued_jobs
        assert_performed_jobs(1, only: IqdbRemovePostJob)
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
          flag = create(:post_flag)
          flag.post.delete!("test deletion")

          assert_equal(true, flag.post.is_deleted)
          assert_equal(2, flag.post.flags.size)
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
          p1 = create(:post)
          c1 = create(:post_with_file, parent_id: p1.id)
          c1.expunge!
          p1.reload
          assert_equal(false, p1.has_children?)
        end

        should "update the parent's has_children flag" do
          p1 = create(:post)
          c1 = create(:post_with_file, parent_id: p1.id)
          c1.expunge!
          p1.reload
          assert(!p1.has_children?, "Parent should not have children")
        end
      end

      context "one child" do
        should "remove the parent of that child" do
          p1 = create(:post_with_file)
          c1 = create(:post, parent_id: p1.id)
          p1.expunge!
          c1.reload
          assert_nil(c1.parent)
        end
      end

      context "two or more children" do
        setup do
          # ensure initial post versions won't be merged.
          travel_to(1.day.ago) do
            @p1 = create(:post_with_file)
            @c1 = create(:post, parent_id: @p1.id)
            @c2 = create(:post, parent_id: @p1.id)
            @c3 = create(:post, parent_id: @p1.id)
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
          create(:favorite, post: c1, user: user)
          c1.delete!("test")
          p1.reload
          assert(Favorite.exists?(:post_id => c1.id, :user_id => user.id))
          assert(!Favorite.exists?(:post_id => p1.id, :user_id => user.id))
        end

        should "reassign favorites to the parent if specified" do
          p1 = FactoryBot.create(:post)
          c1 = FactoryBot.create(:post, :parent_id => p1.id)
          user = FactoryBot.create(:gold_user)
          create(:favorite, post: c1, user: user)
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
          create(:favorite, post: c1, user: user)

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
  end

  context "Moderation:" do
    context "A deleted post" do
      should "be appealed" do
        @post = create(:post, is_deleted: true)
        create(:post_appeal, post: @post)

        assert(@post.is_deleted?, "Post should still be deleted")
        assert_equal(1, @post.appeals.count)
      end
    end
  end

  context "Tagging:" do
    context "A post" do
      setup do
        @post = FactoryBot.create(:post)
      end

      context "with a new tag" do
        should "create the new tag" do
          tag1 = create(:tag, name: "foo", post_count: 100, category: Tag.categories.character)
          create(:post, tag_string: "foo bar")
          tag2 = Tag.find_by_name("bar")

          assert_equal(101, tag1.reload.post_count)
          assert_equal(Tag.categories.character, tag1.category)
          assert_equal(0, tag1.versions.count)

          assert_equal(1, tag2.post_count)
          assert_equal(Tag.categories.general, tag2.category)
          assert_equal(0, tag2.versions.count)
        end
      end

      context "with a banned artist" do
        setup do
          CurrentUser.scoped(FactoryBot.create(:admin_user)) do
            @artist = FactoryBot.create(:artist)
            @artist.ban!
            perform_enqueued_jobs
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

        setup do
          create(:tag, name: "hakurei_reimu")
        end

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

        # \u3000 = ideographic space, \u00A0 = no-break space
        should allow_value("touhou\u3000foo").for(:tag_string)
        should allow_value("touhou\u00A0foo").for(:tag_string)

        should allow_value("/hr").for(:tag_string)
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

      context "tagged with an abbreviation" do
        should "expand the abbreviation" do
          create(:tag, name: "hair_ribbon", post_count: 300_000)
          create(:tag, name: "hakurei_reimu", post_count: 50_000)

          @post.update!(tag_string: "aaa /hr")
          assert_equal("aaa hair_ribbon", @post.reload.tag_string)
        end
      end

      context "tagged with a tag string containing newlines" do
        should "not include the newlines in the tags" do
          @post.update!(tag_string: "bkub\r\ntouhou\r\nchen  inaba_tewi\nhonk_honk\n")

          assert_equal("bkub chen honk_honk inaba_tewi touhou", @post.tag_string)
        end
      end

      context "tagged with a deprecated tag" do
        should "not remove the tag if the tag was already in the post" do
          bad_tag = create(:tag, name: "bad_tag")
          old_post = create(:post, tag_string: "bad_tag")
          bad_tag.update!(is_deprecated: true, updater: create(:user))
          old_post.update!(tag_string: "asd bad_tag")

          assert_equal("asd bad_tag", old_post.reload.tag_string)
          assert_no_match(/The following tags are deprecated and could not be added: \[\[a_bad_tag\]\]/, @post.warnings.full_messages.join)
        end

        should "not add the tag if it is being added" do
          create(:tag, name: "a_bad_tag", is_deprecated: true)
          @post.update!(tag_string: "asd a_bad_tag")

          assert_equal("asd", @post.reload.tag_string)
          assert_match(/The following tags are deprecated and could not be added: \[\[a_bad_tag\]\]/, @post.warnings.full_messages.join)
        end

        should "not add the tag when it contains a category prefix" do
          create(:tag, name: "a_bad_tag", is_deprecated: true)
          @post.update!(tag_string: "asd char:a_bad_tag")

          assert_equal("asd", @post.reload.tag_string)
          assert_match(/The following tags are deprecated and could not be added: \[\[a_bad_tag\]\]/, @post.warnings.full_messages.join)
        end

        should "not warn about the tag being deprecated when the tag is added and removed in the same edit" do
          create(:tag, name: "a_bad_tag", is_deprecated: true)
          @post.update!(tag_string: "asd a_bad_tag -a_bad_tag")

          assert_equal("asd", @post.reload.tag_string)
          assert_no_match(/The following tags are deprecated and could not be added: \[\[a_bad_tag\]\]/, @post.warnings.full_messages.join)
        end
      end

      context "tagged with a metatag" do
        context "for a tag category prefix" do
          should "set the category of a new tag" do
            create(:post, tag_string: "char:chen")
            tag = Tag.find_by_name("chen")

            assert_equal(Tag.categories.character, tag.category)
            assert_equal(0, tag.versions.count)
          end

          should "change the category of an existing tag" do
            user = create(:user)
            tag = create(:tag, name: "hoge", post_count: 1)
            post = as(user) { create(:post, tag_string: "char:hoge") }

            assert_equal(Tag.categories.character, tag.reload.category)

            assert_equal(2, tag.versions.count)
            assert_equal(1, tag.first_version.version)
            assert_nil(tag.first_version.updater)
            assert_nil(tag.first_version.previous_version)
            assert_equal(Tag.categories.general, tag.first_version.category)

            assert_equal(2, tag.last_version.version)
            assert_equal(user, tag.last_version.updater)
            assert_equal(tag.first_version, tag.last_version.previous_version)
            assert_equal(Tag.categories.character, tag.last_version.category)
          end

          should "change the category for an aliased tag" do
            create(:tag_alias, antecedent_name: "hoge", consequent_name: "moge")
            post = create(:post, tag_string: "char:hoge")

            assert_equal(["moge"], post.tag_array)
            assert_equal(Tag.categories.general, Tag.find_by_name("moge").category)
            assert_equal(Tag.categories.character, Tag.find_by_name("hoge").category)
          end

          should "not raise an exception for an invalid tag name" do
            post = create(:post, tag_string: "tagme char:copy:blah")

            assert_match(/Couldn't add tag: 'copy:blah' cannot begin with 'copy:'/, post.warnings[:base].join("\n"))
            assert_equal(["tagme"], post.tag_array)
            assert_equal(false, Tag.exists?(name: "copy:blah"))
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

            assert_equal(false, @post.has_tag?("jim_(cosplay)"))
            assert_equal(false, @post.has_tag?("james_(cosplay)"))
            assert_equal(false, @post.has_tag?("jim"))
            assert_equal(false, @post.has_tag?("james"))
            assert_match(/'jim_\(cosplay\)' is not allowed because 'jim' is aliased to 'james'/, @post.warnings.full_messages.join)
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

          should "clear the parent with parent:0" do
            @post.update(parent_id: @parent.id)
            assert_equal(@parent.id, @post.parent_id)

            @post.update(tag_string: "parent:0")
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
          should "add the post to the pool by id" do
            @pool = create(:pool)
            @post = create(:post, tag_string: "aaa pool:#{@pool.id}")
            assert_equal([@post.id], @pool.reload.post_ids)
          end

          should "remove the post from the pool by id" do
            @pool = create(:pool, post_ids: [@post.id])
            @post.update!(tag_string: "aaa -pool:#{@pool.id}")

            assert_equal([], @pool.reload.post_ids)
          end

          should "add the post to the pool by name" do
            @pool = create(:pool, name: "abc")
            @post.update(tag_string: "aaa pool:abc")

            assert_equal([@post.id], @pool.reload.post_ids)
          end

          should "remove the post from the pool by name" do
            @pool = create(:pool, name: "abc", post_ids: [@post.id])
            @post.update(tag_string: "aaa -pool:abc")

            assert_equal([], @pool.reload.post_ids)
          end
        end

        context "for the newpool: metatag" do
          should "create a new pool and add the post to that pool" do
            @post.update(tag_string: "aaa newpool:abc")
            @pool = Pool.find_by_name("abc")

            assert_not_nil(@pool)
            assert_equal([@post.id], @pool.post_ids)
          end

          should "not strip special characters from the name" do
            @post.update(tag_string: "aaa newpool:ichigo_100%")

            assert(Pool.exists?(name: "ichigo_100%"))
          end

          should "parse a double-quoted name" do
            @post.update(tag_string: 'aaa newpool:"foo bar baz" bbb')
            @pool = Pool.find_by_name("foo_bar_baz")

            assert_not_nil(@pool)
            assert_equal([@post.id], @pool.post_ids)
            assert_equal("aaa bbb", @post.tag_string)
          end

          should "parse a single-quoted name" do
            @post.update(tag_string: "aaa newpool:'foo bar baz' bbb")
            @pool = Pool.find_by_name("foo_bar_baz")

            assert_not_nil(@pool)
            assert_equal([@post.id], @pool.post_ids)
            assert_equal("aaa bbb", @post.tag_string)
          end

          should "parse a name with backslash-escaped spaces" do
            @post.update(tag_string: "aaa newpool:foo\\ bar\\ baz bbb")
            @pool = Pool.find_by_name("foo_bar_baz")

            assert_not_nil(@pool)
            assert_equal([@post.id], @pool.post_ids)
            assert_equal("aaa bbb", @post.tag_string)
          end
        end

        context "for a rating" do
          context "that is valid" do
            should "update the rating" do
              @post.update(tag_string: "aaa rating:e")
              assert_equal("e", @post.reload.rating)

              @post.update(tag_string: "aaa rating:q")
              assert_equal("q", @post.reload.rating)

              @post.update(tag_string: "aaa rating:s")
              assert_equal("s", @post.reload.rating)

              @post.update(tag_string: "aaa rating:g")
              assert_equal("g", @post.reload.rating)
            end

            should "update the rating for a long name" do
              @post.update(tag_string: "aaa rating:explicit")
              assert_equal("e", @post.reload.rating)

              @post.update(tag_string: "aaa rating:questionable")
              assert_equal("q", @post.reload.rating)

              @post.update(tag_string: "aaa rating:sensitive")
              assert_equal("s", @post.reload.rating)

              @post.update(tag_string: "aaa rating:general")
              assert_equal("g", @post.reload.rating)
            end

            should "update the rating for rating:safe" do
              @post.update(tag_string: "aaa rating:safe")
              assert_equal("s", @post.reload.rating)
            end
          end

          context "that is invalid" do
            should "not update the rating" do
              @post.update(tag_string: "aaa rating:z")
              @post.reload
              assert_equal("q", @post.rating)
            end
          end

          context "when a post is created" do
            should "set the rating" do
              @post = create(:post, tag_string: "tagme rating:e", rating: nil)

              assert_equal("e", @post.rating)
            end
          end
        end

        context "for a fav" do
          should "add/remove the current user to the post's favorite listing" do
            @post.update(tag_string: "aaa fav:self")
            assert_equal(1, @post.reload.score)
            assert_equal(1, @post.favorites.where(user: @user).count)
            assert_equal(1, @post.votes.active.positive.where(user: @user).count)

            @post.update(tag_string: "aaa -fav:self")
            assert_equal(0, @post.reload.score)
            assert_equal(0, @post.favorites.count)
            assert_equal(0, @post.votes.active.positive.where(user: @user).count)
          end

          should "not allow banned users to fav" do
            assert_no_difference("@post.favorites.count") do
              as(create(:banned_user)) { @post.update(tag_string: "aaa fav:self") }
            end

            assert_no_difference("@post.favorites.count") do
              as(create(:banned_user)) { @post.update(tag_string: "aaa -fav:self") }
            end
          end

          should "not allow restricted users to fav" do
            assert_no_difference("@post.favorites.count") do
              as(create(:restricted_user)) { @post.update(tag_string: "aaa fav:self") }
            end

            assert_no_difference("@post.favorites.count") do
              as(create(:restricted_user)) { @post.update(tag_string: "aaa -fav:self") }
            end
          end

          should "not fail when the fav: metatag is used twice" do
            @post.update(tag_string: "aaa fav:self fav:me")
            assert_equal(1, @post.favorites.where(user: @user).count)

            @post.update(tag_string: "aaa -fav:self -fav:me")
            assert_equal(0, @post.favorites.count)
          end
        end

        context "for a child" do
          should "add children with child:ids" do
            @children = create_list(:post, 3, parent: nil)
            @post.update(tag_string: "aaa child:#{@children.first.id}..#{@children.last.id}")

            assert_equal(true, @post.reload.has_children?)
            assert_equal(@post.id, @children[0].reload.parent_id)
            assert_equal(@post.id, @children[1].reload.parent_id)
            assert_equal(@post.id, @children[2].reload.parent_id)
          end

          should "remove children with -child:ids" do
            @children = create_list(:post, 3, parent: @post)
            @post.update(tag_string: "aaa -child:#{@children.first.id}")

            assert_equal(true, @post.reload.has_children?)
            assert_nil(@children[0].reload.parent_id)
            assert_equal(@post.id, @children[1].reload.parent_id)
            assert_equal(@post.id, @children[2].reload.parent_id)
          end

          should "remove all children with child:none" do
            @children = create_list(:post, 3, parent: @post)
            @post.update!(tag_string: "aaa child:none")

            assert_equal(false, @post.reload.has_children?)
            assert_nil(@children[0].reload.parent_id)
            assert_nil(@children[1].reload.parent_id)
            assert_nil(@children[2].reload.parent_id)
          end

          should "not add children with child:" do
            @children = create_list(:post, 3, parent: nil)
            @post.update(tag_string: "aaa child:")

            assert_equal(false, @post.reload.has_children?)
            assert_nil(@children[0].reload.parent_id)
            assert_nil(@children[1].reload.parent_id)
            assert_nil(@children[2].reload.parent_id)
          end

          should "not remove children with -child:" do
            @children = create_list(:post, 3, parent: @post)
            @post.update!(tag_string: "aaa -child:")

            assert_equal(true, @post.reload.has_children?)
            assert_equal(@post, @children[0].reload.parent)
            assert_equal(@post, @children[1].reload.parent)
            assert_equal(@post, @children[2].reload.parent)
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
            @post.update!(is_pending: true)

            assert_no_difference("@post.approvals.count") do
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
            assert_no_changes("@post.reload.is_banned?") do
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
            @post.update!(is_banned: true)

            assert_no_changes("@post.reload.is_banned?") do
              @post.update(tag_string: "aaa -status:banned")
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
            assert_no_difference("@post.disapprovals.count") do
              @post.update!(is_pending: true)
              @post.update(tag_string: "aaa disapproved:disinterest")
            end

            assert_equal(0, @post.disapprovals.count)
          end

          should "not allow disapproving active posts" do
            assert_no_difference("@post.disapprovals.count") do
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
            @post.update(tag_string: 'aaa source:"foo bar baz" bbb')
            assert_equal("foo bar baz", @post.source)
            assert_equal("aaa bbb non-web_source", @post.tag_string)
          end

          should "set the source with source:'foo bar baz'" do
            @post.update(tag_string: "aaa source:'foo bar baz' bbb")
            assert_equal("foo bar baz", @post.source)
            assert_equal("aaa bbb non-web_source", @post.tag_string)
          end

          should "set the source with source:foo\\ bar\\ baz" do
            @post.update(tag_string: "aaa source:foo\\ bar\\ baz bbb")
            assert_equal("foo bar baz", @post.source)
            assert_equal("aaa bbb non-web_source", @post.tag_string)
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

          should "give priority to the source: metatag over the source field" do
            @post.update(tag_string: "source:me", source: "I made it up")
            assert_equal("me", @post.source)
          end

          should "set the pixiv id with source:https://img18.pixiv.net/img/evazion/14901720.png" do
            @post.update(:tag_string => "source:https://img18.pixiv.net/img/evazion/14901720.png")
            assert_equal("https://img18.pixiv.net/img/evazion/14901720.png", @post.source)
            assert_equal(14901720, @post.pixiv_id)
          end

          should "validate the max source length" do
            @post.update(source: "X"*1201)

            assert_equal(false, @post.valid?)
            assert_equal(["is too long (maximum is 1200 characters)"], @post.errors[:source])
          end
        end

        context "of" do
          setup do
            @gold = FactoryBot.create(:gold_user)
          end

          context "upvote:self or downvote:self" do
            context "by a member" do
              should "upvote the post" do
                assert_difference("PostVote.count") do
                  @post.update(tag_string: "upvote:self")
                end

                assert_equal(1, @post.reload.score)
              end

              should "downvote the post" do
                assert_difference("PostVote.count") do
                  @post.update(tag_string: "downvote:self")
                end

                assert_equal(-1, @post.reload.score)
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

        should "resolve aliases before removing negated tags" do
          create(:tag_alias, antecedent_name: "female_focus", consequent_name: "female")

          @post.update!(tag_string: "blah female_focus -female")
          assert_equal("blah", @post.tag_string)

          @post.update!(tag_string: "blah female_focus -female_focus")
          assert_equal("blah", @post.tag_string)
        end

        should "resolve abbreviations" do
          create(:tag, name: "hair_ribbon", post_count: 300_000)
          create(:tag, name: "hakurei_reimu", post_count: 50_000)

          @post.update!(tag_string: "aaa hair_ribbon hakurei_reimu")
          assert_equal("aaa hair_ribbon hakurei_reimu", @post.reload.tag_string)

          @post.update!(tag_string: "aaa hair_ribbon hakurei_reimu -/hr")
          assert_equal("aaa hakurei_reimu", @post.reload.tag_string)
        end
      end

      context "a static image tagged with animated_gif" do
        should "remove the tag" do
          @media_asset = create(:media_asset, file: "test/files/test-static-32x32.gif")
          @post.update!(md5: @media_asset.md5)
          @post.reload.update!(tag_string: "tagme animated animated_gif")
          assert_equal("tagme", @post.tag_string)
        end
      end

      context "a static image tagged with animated_png" do
        should "remove the tag" do
          @media_asset = create(:media_asset, file: "test/files/test.png")
          @post.update!(md5: @media_asset.md5)
          @post.reload.update!(tag_string: "tagme animated animated_png")
          assert_equal("tagme", @post.tag_string)
        end
      end

      context "an animated gif missing the animated_gif tag" do
        should "automatically add the animated_gif tag" do
          @media_asset = MediaAsset.upload!("test/files/test-animated-86x52.gif")
          @post.update!(md5: @media_asset.md5)
          @post.reload.update!(tag_string: "tagme")
          assert_equal("animated animated_gif tagme", @post.tag_string)
        end
      end

      context "an animated png missing the animated_png tag" do
        should "automatically add the animated_png tag" do
          @media_asset = MediaAsset.upload!("test/files/test-animated-256x256.png")
          @post.update!(md5: @media_asset.md5)
          @post.reload.update!(tag_string: "tagme")
          assert_equal("animated animated_png tagme", @post.tag_string)
        end
      end

      context "a greyscale image missing the greyscale tag" do
        should "automatically add the greyscale tag" do
          @media_asset = MediaAsset.upload!("test/files/test-grey-no-profile.jpg")
          @post.update!(md5: @media_asset.md5)
          @post.reload.update!(tag_string: "tagme")
          assert_equal("greyscale tagme", @post.tag_string)
        end
      end

      context "an exif-rotated image missing the exif_rotation tag" do
        should "automatically add the exif_rotation tag" do
          @media_asset = MediaAsset.upload!("test/files/test-rotation-90cw.jpg")
          @post.update!(md5: @media_asset.md5)
          @post.reload.update!(tag_string: "tagme")
          assert_equal("exif_rotation tagme", @post.tag_string)
        end
      end

      context "a PNG with the exif orientation flag" do
        should "not add the exif_rotation tag" do
          @media_asset = MediaAsset.upload!("test/files/test-rotation-90cw.png")
          @post.update!(md5: @media_asset.md5)
          @post.reload.update!(tag_string: "tagme")
          assert_equal("tagme", @post.tag_string)
        end
      end

      context "a non-repeating GIF missing the non-repeating_animation tag" do
        should "automatically add the non-repeating_animation tag" do
          @media_asset = MediaAsset.upload!("test/files/test-animated-86x52-loop-1.gif")
          @post.update!(md5: @media_asset.md5)
          @post.reload.update!(tag_string: "tagme")
          assert_equal("animated animated_gif non-repeating_animation tagme", @post.tag_string)

          @media_asset = MediaAsset.upload!("test/files/test-animated-86x52-loop-2.gif")
          @post.update!(md5: @media_asset.md5)
          @post.reload.update!(tag_string: "tagme")
          assert_equal("animated animated_gif non-repeating_animation tagme", @post.tag_string)
        end
      end

      context "a post with a non-web source" do
        should "automatically add the non-web_source tag" do
          @post.update!(source: "this was once revealed to me in a dream")
          assert_equal("non-web_source tag1 tag2", @post.tag_string)
        end

        should "remove the non-web_source tag when using the source: metatag" do
          @post.update!(tag_string: "aaa source:me")
          assert_equal("aaa non-web_source", @post.tag_string)

          @post.update!(tag_string: "aaa source:https://www.example.com")
          assert_equal("aaa", @post.tag_string)
        end
      end

      context "a post with a bad_link source" do
        should "add the bad_link tag for known bad sources" do
          @post.update!(source: "https://pbs.twimg.com/media/FQjQA1mVgAMcHLv.jpg:orig")
          assert_equal("bad_link tag1 tag2", @post.tag_string)

          @post.update!(source: "https://media.tumblr.com/570edf684c7eb195d391115f8b18ca55/tumblr_pen2zwt3bK1uh1m9xo1_1280.png")
          assert_equal("bad_link tag1 tag2", @post.tag_string)
        end

        should "remove the bad_link tag for known good sources" do
          @post.update!(tag_string: "bad_link tag1 tag2")
          @post.update!(source: "https://i.pximg.net/img-original/img/2022/04/25/08/03/14/97867015_p0.png")
          assert_equal("tag1 tag2", @post.tag_string)
        end

        should "not add the bad_link tag for unknown sources" do
          @post.update!(source: "https://www.example.com/image.jpg")
          assert_equal("tag1 tag2", @post.tag_string)
        end

        should "not remove the bad_link tag for unknown sources" do
          @post.update!(tag_string: "bad_link tag1 tag2", source: "https://www.example.com/image.jpg")
          assert_equal("bad_link tag1 tag2", @post.tag_string)
        end

        should "remove the bad_link tag when using the source: metatag" do
          @post.update!(tag_string: "aaa source:https://pbs.twimg.com/media/FQjQA1mVgAMcHLv.jpg:orig")
          assert_equal("aaa bad_link", @post.tag_string)

          @post.update!(tag_string: "aaa source:https://i.pximg.net/img-original/img/2022/04/25/08/03/14/97867015_p0.png")
          assert_equal("aaa", @post.tag_string)
        end
      end

      context "a post with a bad source" do
        should "add the bad_source tag for known bad sources" do
          @post.update!(source: "https://twitter.com/danboorubot/")
          assert_equal("bad_source tag1 tag2", @post.tag_string)

          @post.update!(source: "https://www.pixiv.net/en/users/6210796")
          assert_equal("bad_source tag1 tag2", @post.tag_string)
        end

        should "remove the bad_source tag for known good sources" do
          @post.update!(tag_string: "bad_source tag1 tag2")
          @post.update!(source: "https://twitter.com/kafun/status/1520766650907521024")
          assert_equal("tag1 tag2", @post.tag_string)
        end

        should "not add the bad_source tag for unknown sources" do
          @post.update!(source: "https://www.example.com/image.html")
          assert_equal("tag1 tag2", @post.tag_string)
        end

        should "not remove the bad_source tag for unknown sources" do
          @post.update!(tag_string: "bad_source tag1 tag2", source: "https://www.example.com/image.html")
          assert_equal("bad_source tag1 tag2", @post.tag_string)
        end

        should "remove the bad_source tag when using the source: metatag" do
          @post.update!(tag_string: "aaa source:https://twitter.com/danboorubot/")
          assert_equal("aaa bad_source", @post.tag_string)

          @post.update!(tag_string: "aaa source:https://twitter.com/kafun/status/1520766650907521024")
          assert_equal("aaa", @post.tag_string)
        end
      end

      context "a post with a blank source" do
        should "remove the non-web_source tag" do
          @post.update!(source: "", tag_string: "non-web_source")
          @post.save!
          assert_equal("tagme", @post.tag_string)
        end
      end

      context "a post with a https:// source" do
        should "remove the non-web_source tag" do
          @post.update!(source: "https://www.google.com", tag_string: "non-web_source")
          @post.save!
          assert_equal("tagme", @post.tag_string)
        end
      end

      should "have an array representation of its tags" do
        post = FactoryBot.create(:post)
        post.reload
        post.tag_string = "aaa bbb"
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
          assert_match(/'little_red_riding_hood_\(cosplay\)' is not allowed because 'little_red_riding_hood' is not a character tag/, @post.warnings.full_messages.join)
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
            post = create(:post, tag_string: "foo")

            assert_equal("foo", post.versions.last.tags)
            assert_equal(["foo"], post.versions.last.added_tags)
          end
        end

        should "create a new version if it's been over an hour since the last update" do
          post = create(:post, tag_string: "foo")

          travel(6.hours) do
            assert_difference("PostVersion.count", 1) do
              post.update(tag_string: "bar foo")
            end
          end

          assert_equal("bar foo", post.versions.last.tags)
          assert_equal(["bar"], post.versions.last.added_tags)
        end

        should "merge with the previous version if the updater is the same user and it's been less than an hour" do
          post = create(:post, tag_string: "foo")

          assert_difference("PostVersion.count", 0) do
            post.update(tag_string: "foo bar")
          end

          assert_equal("bar foo", post.versions.last.tags)
          # assert_equal(%w[bar foo], post.versions.last.added_tags)
        end

        should "create a new version even if adding a metatag fails" do
          travel(2.hours) do
            @post.update!(tag_string: "foo status:banned")
          end

          assert_equal(false, @post.reload.is_banned?)
          assert_equal(2, @post.versions.last.version)
          assert_equal("foo", @post.tag_string)
          assert_equal("foo", @post.versions.last.tags)
        end

        should "record the changes correctly when using a metatag that modifies the post itself" do
          travel(2.hours) do
            @post.update!(tag_string: "foo fav:me")
          end

          assert_equal(1, @post.reload.score)
          assert_equal(2, @post.versions.last.version)
          assert_equal("foo", @post.tag_string)
          assert_equal("foo", @post.versions.last.tags)
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
        context "that contains unicode characters" do
          should "normalize the source to NFC form" do
            source1 = "poke\u0301mon" # pokémon (nfd form)
            source2 = "pok\u00e9mon"  # pokémon (nfc form)
            @post.update!(source: source1)
            assert_equal(source2, @post.source)
          end
        end

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

        context "like 'Blog.'" do
          should "not raise an exception" do
            @post.update!(source: "Blog.")
            assert_equal("Blog.", @post.source)
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

    context "A post" do
      setup { @post = FactoryBot.create(:post) }
      subject { @post }

      should "not allow values S, safe, derp" do
        ["S", "safe", "derp"].each do |rating|
          subject.rating = rating
          assert(!subject.valid?)
        end
      end

      should "allow values g, s, q, e" do
        ["g", "s", "q", "e"].each do |rating|
          subject.rating = rating
          assert(subject.valid?)
        end
      end
    end
  end

  context "Favorites:" do
    context "Removing a post from a user's favorites" do
      setup do
        @user = FactoryBot.create(:contributor_user)
        @post = FactoryBot.create(:post)
        create(:favorite, post: @post, user: @user)
        @user.reload
      end

      should "decrement the user's favorite_count" do
        assert_difference("@user.reload.favorite_count", -1) do
          Favorite.destroy_by(post: @post, user: @user)
        end
      end

      should "decrement the post's score for gold users" do
        assert_difference("@post.reload.score", -1) do
          Favorite.destroy_by(post: @post, user: @user)
        end
      end

      should "decrement the post's score for basic users" do
        @member = FactoryBot.create(:user)

        assert_difference("@post.reload.score", -1) do
          Favorite.destroy_by(post: @post, user: @user)
        end
      end

      should "not decrement the user's favorite_count if the user did not favorite the post" do
        @post2 = FactoryBot.create(:post)
        assert_no_difference("@user.favorite_count") do
          Favorite.destroy_by(post: @post2, user: @user)
        end
      end
    end

    context "Adding a post to a user's favorites" do
      setup do
        @user = FactoryBot.create(:contributor_user)
        @post = FactoryBot.create(:post)
      end

      should "increment the user's favorite_count" do
        assert_difference("@user.favorite_count", 1) do
          create(:favorite, post: @post, user: @user)
        end
      end

      should "increment the post's score for gold users" do
        create(:favorite, post: @post, user: @user)
        assert_equal(1, @post.reload.score)
      end

      should "not increment the post's score for basic users" do
        @member = FactoryBot.create(:user)
        create(:favorite, post: @post, user: @member)
        assert_equal(0, @post.score)
      end
    end

    context "Moving favorites to a parent post" do
      setup do
        @parent = FactoryBot.create(:post)
        @child = FactoryBot.create(:post, parent: @parent)

        @user1 = FactoryBot.create(:user, enable_private_favorites: true)
        @gold1 = FactoryBot.create(:gold_user)

        create(:favorite, post: @child, user: @user1)
        create(:favorite, post: @child, user: @gold1)

        @child.give_favorites_to_parent
        @child.reload
        @parent.reload
      end

      should "move the favorites" do
        assert_equal(0, @child.fav_count)
        assert_equal(0, @child.favorites.count)
        assert_equal([], @child.favorites.pluck(:user_id))

        assert_equal(2, @parent.fav_count)
        assert_equal(2, @parent.favorites.count)
        assert_equal([@user1.id, @gold1.id], @parent.favorites.pluck(:user_id))
      end

      should "create a vote for each user who can vote" do
        assert(@parent.votes.where(user: @gold1).exists?)
        assert(@parent.votes.where(user: @user1).exists?)
        assert_equal(2, @parent.score)
      end
    end
  end

  context "Pools:" do
    setup do
      SqsService.any_instance.stubs(:send_message)
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
    should "allow members to vote" do
      user = create(:user)
      post = create(:post)

      assert_nothing_raised { post.vote!(1, user) }
      assert_equal(1, post.votes.count)
      assert_equal(1, post.reload.score)
    end

    should "not allow duplicate votes" do
      user = create(:gold_user)
      post = create(:post)

      post.vote!(1, user)
      post.vote!(1, user)

      assert_equal(1, post.reload.score)
      assert_equal(1, post.votes.active.count)
    end

    should "allow undoing of votes" do
      user = create(:gold_user)
      post = create(:post)

      # We deliberately don't call post.reload until the end to verify that
      # post.unvote! returns the correct score even when not forcibly reloaded.
      post.vote!(1, user)
      assert_equal(1, post.score)
      assert_equal(1, post.up_score)
      assert_equal(0, post.down_score)
      assert_equal(1, post.votes.active.positive.count)

      post.votes.last.soft_delete!
      post.reload
      assert_equal(0, post.score)
      assert_equal(0, post.up_score)
      assert_equal(0, post.down_score)
      assert_equal(0, post.votes.active.count)

      post.vote!(-1, user)
      assert_equal(-1, post.score)
      assert_equal(0, post.up_score)
      assert_equal(-1, post.down_score)
      assert_equal(1, post.votes.active.negative.count)

      post.votes.last.soft_delete!
      post.reload
      assert_equal(0, post.score)
      assert_equal(0, post.up_score)
      assert_equal(0, post.down_score)
      assert_equal(0, post.votes.active.count)

      post.vote!(1, user)
      assert_equal(1, post.score)
      assert_equal(1, post.up_score)
      assert_equal(0, post.down_score)
      assert_equal(1, post.votes.active.positive.count)

      post.reload
      assert_equal(1, post.score)
    end
  end

  context "Reverting: " do
    context "a post that has been updated" do
      setup do
        PostVersion.sqs_service.stubs(:merge?).returns(false)
        @post = create(:post, rating: "q", tag_string: "aaa", source: "")
        @post.reload
        @post.update(tag_string: "aaa bbb ccc ddd")
        @post.reload
        @post.update(tag_string: "bbb xxx yyy", source: "http://xyz.com")
        @post.reload
        @post.update(tag_string: "bbb mmm yyy", source: "http://abc.com")
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
          assert_equal("http://xyz.com", @post.source)
          assert_equal("q", @post.rating)
        end
      end
    end
  end

  context "URLs:" do
    should "generate the correct urls for animated gifs" do
      @post = create(:post_with_file, filename: "test-animated-86x52.gif")

      assert_equal("https://www.example.com/data/preview/77/d8/77d89bda37ea3af09158ed3282f8334f.jpg", @post.preview_file_url)
      assert_equal("https://www.example.com/data/original/77/d8/77d89bda37ea3af09158ed3282f8334f.gif", @post.large_file_url)
      assert_equal("https://www.example.com/data/original/77/d8/77d89bda37ea3af09158ed3282f8334f.gif", @post.file_url)
    end
  end

  context "Searching:" do
    context "the user_tag_match method" do
      should "should not negate conditions before the search" do
        @post1 = create(:post, tag_string: "solo", is_pending: true)
        @post2 = create(:post, tag_string: "touhou", is_deleted: true)

        assert_equal([@post1.id], Post.pending.anon_tag_match("solo").pluck(:id))
        assert_equal([], Post.pending.anon_tag_match("-solo").pluck(:id))
        assert_equal([@post2.id], Post.deleted.anon_tag_match("touhou").pluck(:id))
        assert_equal([], Post.deleted.anon_tag_match("-touhou").pluck(:id))
      end
    end
  end
end
