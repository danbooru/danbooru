require 'test_helper'

class TagAliasTest < ActiveSupport::TestCase
  context "A tag alias" do
    setup do
      @admin = FactoryBot.create(:admin_user)

      travel_to(1.month.ago) do
        user = FactoryBot.create(:user)
        CurrentUser.user = user
      end
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "on validation" do
      subject do
        FactoryBot.create(:tag, :name => "aaa")
        FactoryBot.create(:tag, :name => "bbb")
        FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb", :status => "active")
      end

      should allow_value('active').for(:status)
      should allow_value('deleted').for(:status)
      should allow_value('pending').for(:status)
      should allow_value('processing').for(:status)
      should allow_value('error: derp').for(:status)

      should_not allow_value('ACTIVE').for(:status)
      should_not allow_value('error').for(:status)
      should_not allow_value('derp').for(:status)

      should allow_value(nil).for(:forum_topic_id)
      should_not allow_value(-1).for(:forum_topic_id).with_message("must exist", against: :forum_topic)

      should allow_value(nil).for(:approver_id)
      should_not allow_value(-1).for(:approver_id).with_message("must exist", against: :approver)

      # should_not allow_value(nil).for(:creator_id) # XXX https://github.com/thoughtbot/shoulda-context/issues/53
      should_not allow_value(-1).for(:creator_id).with_message("must exist", against: :creator)

      should "not allow duplicate active aliases" do
        ta1 = FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "active")
        ta2 = FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "retired")
        ta3 = FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "deleted")
        ta4 = FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "deleted")
        ta5 = FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")
        [ta1, ta2, ta3, ta4, ta5].each { |ta| assert(ta.valid?) }

        ta5.update(status: "active")
        assert_includes(ta5.errors[:antecedent_name], "has already been taken")
      end
    end

    context "#reject!" do
      should "not be blocked by validations" do
        ta1 = create(:tag_alias, antecedent_name: "kitty", consequent_name: "kitten", status: "active")
        ta2 = build(:tag_alias, antecedent_name: "cat", consequent_name: "kitty", status: "pending")

        ta2.reject!
        assert_equal("deleted", ta2.reload.status)
      end
    end

    should "populate the creator information" do
      ta = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", creator: CurrentUser.user)
      assert_equal(CurrentUser.user.id, ta.creator_id)
    end

    should "convert a tag to its normalized version" do
      tag1 = create(:tag, name: "aaa")
      tag2 = create(:tag, name: "bbb")
      ta = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb")

      assert_equal(["bbb"], TagAlias.to_aliased("aaa"))
      assert_equal(["bbb"], TagAlias.to_aliased("aaa".mb_chars))
      assert_equal(["bbb", "ccc"], TagAlias.to_aliased(["aaa", "ccc"]))
      assert_equal(["ccc", "bbb"], TagAlias.to_aliased(["ccc", "bbb"]))
      assert_equal(["bbb", "bbb"], TagAlias.to_aliased(["aaa", "aaa"]))
    end

    context "saved searches" do
      should "move saved searches" do
        @ss1 = create(:saved_search, query: "123 ... 456", user: CurrentUser.user)
        @ss2 = create(:saved_search, query: "123 -... 456", user: CurrentUser.user)
        @ss3 = create(:saved_search, query: "123 ~... 456", user: CurrentUser.user)
        @ss4 = create(:saved_search, query: "... 456", user: CurrentUser.user)
        @ss5 = create(:saved_search, query: "123 ...", user: CurrentUser.user)
        @ta = create(:tag_alias, antecedent_name: "...", consequent_name: "bbb")

        @ta.approve!(@admin)
        perform_enqueued_jobs

        assert_equal("123 bbb 456", @ss1.reload.query)
        assert_equal("123 -bbb 456", @ss2.reload.query)
        assert_equal("123 ~bbb 456", @ss3.reload.query)
        assert_equal("bbb 456", @ss4.reload.query)
        assert_equal("123 bbb", @ss5.reload.query)
      end
    end

    context "blacklists" do
      should "move blacklists" do
        @u1 = create(:user, blacklisted_tags: "111 ... 222")
        @u2 = create(:user, blacklisted_tags: "111 -... -222")
        @u3 = create(:user, blacklisted_tags: "111 ~... ~222")
        @u4 = create(:user, blacklisted_tags: "... 222")
        @u5 = create(:user, blacklisted_tags: "111 ...")
        @u6 = create(:user, blacklisted_tags: "111 222\n\n... 333\n")
        @u7 = create(:user, blacklisted_tags: "111 ...\r\n222 333\n")
        @ta = create(:tag_alias, antecedent_name: "...", consequent_name: "aaa")

        @ta.approve!(@admin)
        perform_enqueued_jobs

        assert_equal("111 aaa 222", @u1.reload.blacklisted_tags)
        assert_equal("111 -aaa -222", @u2.reload.blacklisted_tags)
        assert_equal("111 ~aaa ~222", @u3.reload.blacklisted_tags)
        assert_equal("aaa 222", @u4.reload.blacklisted_tags)
        assert_equal("111 aaa", @u5.reload.blacklisted_tags)
        assert_equal("111 222\n\naaa 333", @u6.reload.blacklisted_tags)
        assert_equal("111 aaa\n222 333", @u7.reload.blacklisted_tags)
      end
    end

    should "update any affected posts when saved" do
      post1 = FactoryBot.create(:post, :tag_string => "aaa bbb")
      post2 = FactoryBot.create(:post, :tag_string => "ccc ddd")

      ta = FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "ccc")
      ta.approve!(@admin)
      perform_enqueued_jobs

      assert_equal("bbb ccc", post1.reload.tag_string)
      assert_equal("ccc ddd", post2.reload.tag_string)
    end

    should "not validate for transitive relations" do
      ta1 = FactoryBot.create(:tag_alias, :antecedent_name => "bbb", :consequent_name => "ccc")
      assert_difference("TagAlias.count", 0) do
        ta2 = FactoryBot.build(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
        ta2.save
        assert(ta2.errors.any?, "Tag alias should be invalid")
        assert_equal("A tag alias for bbb already exists", ta2.errors.full_messages.join)
      end
    end

    context "when the tags have wikis" do
      should "rename the old wiki if there is no conflict" do
        @wiki = create(:wiki_page, title: "aaa")
        @ta = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")

        @ta.approve!(@admin)
        perform_enqueued_jobs
        assert_equal("active", @ta.reload.status)

        assert_equal("bbb", @wiki.reload.title)
      end

      should "merge existing wikis if there is a conflict" do
        @wiki1 = create(:wiki_page, title: "aaa", other_names: "111 222", body: "first")
        @wiki2 = create(:wiki_page, title: "bbb", other_names: "111 333", body: "second")
        @ta = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")

        @ta.approve!(@admin)
        perform_enqueued_jobs
        assert_equal("active", @ta.reload.status)

        assert_equal(true, @wiki1.reload.is_deleted)
        assert_equal([], @wiki1.other_names)
        assert_equal("This tag has been moved to [[#{@wiki2.title}]].", @wiki1.body)

        assert_equal(false, @wiki2.reload.is_deleted)
        assert_equal(%w[111 333 222], @wiki2.other_names)
        assert_equal("second", @wiki2.body)
      end

      should "ignore the old wiki if it has been deleted" do
        @wiki1 = create(:wiki_page, title: "aaa", other_names: "111 222", body: "first", is_deleted: true)
        @wiki2 = create(:wiki_page, title: "bbb", other_names: "111 333", body: "second")
        @ta = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")

        @ta.approve!(@admin)
        perform_enqueued_jobs
        assert_equal("active", @ta.reload.status)

        assert_equal(true, @wiki1.reload.is_deleted)
        assert_equal(%w[111 222], @wiki1.other_names)
        assert_equal("first", @wiki1.body)

        assert_equal(false, @wiki2.reload.is_deleted)
        assert_equal(%w[111 333], @wiki2.other_names)
        assert_equal("second", @wiki2.body)
      end

      should "rewrite links in other wikis to use the new tag" do
        @wiki = create(:wiki_page, body: "foo [[aaa]] bar")
        @ta = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb")

        @ta.approve!(@admin)
        perform_enqueued_jobs
        assert_equal("active", @ta.reload.status)

        assert_equal("foo [[bbb]] bar", @wiki.reload.body)
      end
    end

    context "when the tags have artist entries" do
      should "rename the old artist entry if there is no conflict" do
        @artist = create(:artist, name: "aaa")
        @ta = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")

        @ta.approve!(@admin)
        perform_enqueued_jobs
        assert_equal("active", @ta.reload.status)

        assert_equal("bbb", @artist.reload.name)
      end

      should "merge existing artists if there is a conflict" do
        @tag = create(:tag, name: "aaa", category: Tag.categories.artist)
        @artist1 = create(:artist, name: "aaa", group_name: "g_aaa", other_names: "111 222", url_string: "https://twitter.com/111\n-https://twitter.com/222")
        @artist2 = create(:artist, name: "bbb", other_names: "111 333", url_string: "https://twitter.com/111\n-https://twitter.com/333\nhttps://twitter.com/444")
        @ta = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")

        @ta.approve!(@admin)
        perform_enqueued_jobs
        assert_equal("active", @ta.reload.status)

        assert_equal(true, @artist1.reload.is_deleted)
        assert_equal([@artist2.name], @artist1.other_names)
        assert_equal("", @artist1.group_name)
        assert_equal([], @artist1.url_array)

        assert_equal(false, @artist2.reload.is_deleted)
        assert_equal(%w[111 333 222 aaa], @artist2.other_names)
        assert_equal("g_aaa", @artist2.group_name)
        assert_equal(%w[-https://twitter.com/222 -https://twitter.com/333 https://twitter.com/111 https://twitter.com/444], @artist2.url_array)
      end

      should "ignore the old artist if it has been deleted" do
        @artist1 = create(:artist, name: "aaa", group_name: "g_aaa", other_names: "111 222", url_string: "https://twitter.com/111\n-https://twitter.com/222", is_deleted: true)
        @artist2 = create(:artist, name: "bbb", other_names: "111 333", url_string: "https://twitter.com/111\n-https://twitter.com/333\nhttps://twitter.com/444")
        @ta = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")

        @ta.approve!(@admin)
        perform_enqueued_jobs
        assert_equal("active", @ta.reload.status)

        assert_equal(true, @artist1.reload.is_deleted)
        assert_equal(%w[111 222], @artist1.other_names)
        assert_equal("g_aaa", @artist1.group_name)
        assert_equal(%w[-https://twitter.com/222 https://twitter.com/111], @artist1.url_array)

        assert_equal(false, @artist2.reload.is_deleted)
        assert_equal(%w[111 333], @artist2.other_names)
        assert_equal("", @artist2.group_name)
        assert_equal(%w[-https://twitter.com/333 https://twitter.com/111 https://twitter.com/444], @artist2.url_array)
      end
    end


    should "move existing aliases" do
      ta1 = FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb", :status => "pending")
      ta2 = FactoryBot.create(:tag_alias, :antecedent_name => "bbb", :consequent_name => "ccc", :status => "pending")

      # XXX this is broken, it depends on the order the jobs are executed in.
      ta2.approve!(@admin)
      ta1.approve!(@admin)
      perform_enqueued_jobs

      assert_equal("ccc", ta1.reload.consequent_name)
    end

    should "move existing implications" do
      ti = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ta = FactoryBot.create(:tag_alias, :antecedent_name => "bbb", :consequent_name => "ccc")
      ta.approve!(@admin)
      perform_enqueued_jobs

      assert_equal("ccc", ti.reload.consequent_name)
    end

    should "push the consequent's category to the antecedent if the antecedent is general" do
      tag1 = create(:tag, name: "general", category: 0)
      tag2 = create(:tag, name: "artist", category: 1)
      ta = create(:tag_alias, antecedent_name: "general", consequent_name: "artist")

      ta.approve!(@admin)
      perform_enqueued_jobs

      assert_equal(1, tag1.reload.category)
      assert_equal(1, tag2.reload.category)
    end

    should "push the antecedent's category to the consequent if the consequent is general" do
      tag1 = create(:tag, name: "artist", category: 1)
      tag2 = create(:tag, name: "general", category: 0)
      ta = create(:tag_alias, antecedent_name: "artist", consequent_name: "general")

      ta.approve!(@admin)
      perform_enqueued_jobs

      assert_equal(1, tag1.reload.category)
      assert_equal(1, tag2.reload.category)
    end

    should "not change either tag category when neither the antecedent or consequent are general" do
      tag1 = create(:tag, name: "character", category: 4)
      tag2 = create(:tag, name: "copyright", category: 3)
      ta = create(:tag_alias, antecedent_name: "character", consequent_name: "copyright")

      ta.approve!(@admin)
      perform_enqueued_jobs

      assert_equal(4, tag1.reload.category)
      assert_equal(3, tag2.reload.category)
    end
  end
end
