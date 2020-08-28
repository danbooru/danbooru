require 'test_helper'

class SavedSearchTest < ActiveSupport::TestCase
  def setup
    super
    @user = FactoryBot.create(:user)
    CurrentUser.user = @user
    CurrentUser.ip_addr = "127.0.0.1"
    @mock_redis = MockRedis.new
    SavedSearch.stubs(:redis).returns(@mock_redis)
  end

  def teardown
    super
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context ".labels_for" do
    setup do
      FactoryBot.create(:saved_search, user: @user, label_string: "blah", query: "blah")
      FactoryBot.create(:saved_search, user: @user, label_string: "zah", query: "blah")
    end

    should "fetch the labels used by a user" do
      assert_equal(%w(blah zah), SavedSearch.labels_for(@user.id))
    end
  end

  context ".queries_for" do
    setup do
      FactoryBot.create(:tag_alias, antecedent_name: "bbb", consequent_name: "ccc", creator: @user)
      FactoryBot.create(:saved_search, user: @user, label_string: "blah", query: "aaa")
      FactoryBot.create(:saved_search, user: @user, label_string: "zah", query: "CCC BBB AAA")
      FactoryBot.create(:saved_search, user: @user, label_string: "qux", query: " aaa  bbb  ccc ")
    end

    should "fetch the queries used by a user for a label" do
      assert_equal(%w(aaa), SavedSearch.queries_for(@user.id, label: "blah"))
    end

    should "fetch the queries used by a user without a label" do
      assert_equal(["aaa", "aaa ccc"], SavedSearch.queries_for(@user.id))
    end
  end

  context ".search_labels" do
    setup do
      FactoryBot.create(:tag_alias, antecedent_name: "bbb", consequent_name: "ccc", creator: @user)
      FactoryBot.create(:saved_search, user: @user, label_string: "blah", query: "aaa")
      FactoryBot.create(:saved_search, user: @user, label_string: "blahbling", query: "CCC BBB AAA")
      FactoryBot.create(:saved_search, user: @user, label_string: "qux", query: " aaa  bbb  ccc ")
    end

    should "fetch the queries used by a user for a label" do
      assert_equal(%w(blah blahbling), SavedSearch.search_labels(@user.id, label: "blah"))
    end
  end

  context ".post_ids_for" do
    context "with a label" do
      setup do
        create(:saved_search, query: "a", labels: ["blah"], user: @user)
        create(:saved_search, query: "b", labels: ["blah"], user: @user)
        create(:saved_search, query: "c", labels: ["blah"], user: @user)

        create(:post, tag_string: "a")
        create(:post, tag_string: "b")
        create(:post, tag_string: "c")
      end

      context "without a primed cache" do
        should "return nothing" do
          post_ids = SavedSearch.post_ids_for(@user.id, label: "blah")
          assert_equal([], post_ids)
        end
      end

      context "with a primed cache" do
        setup do
          perform_enqueued_jobs do
            SavedSearch.post_ids_for(@user.id, label: "blah")
          end
        end

        should "fetch the post ids" do
          post_ids = SavedSearch.post_ids_for(@user.id, label: "blah")
          assert_equal(Post.pluck(:id).sort, post_ids.sort)
        end
      end
    end

    context "without a label" do
      setup do
        create(:saved_search, query: "a", user: @user)
        create(:saved_search, query: "b", user: @user)
        create(:saved_search, query: "c", user: @user)

        create(:post, tag_string: "a")
        create(:post, tag_string: "b")
        create(:post, tag_string: "c")
      end

      context "without a primed cache" do
        should "return nothing" do
          post_ids = SavedSearch.post_ids_for(@user.id)
          assert_equal([], post_ids)
        end
      end

      context "with a primed cache" do
        setup do
          perform_enqueued_jobs do
            SavedSearch.post_ids_for(@user.id)
          end
        end

        should "fetch the post ids" do
          post_ids = SavedSearch.post_ids_for(@user.id)
          assert_equal(Post.pluck(:id).sort, post_ids.sort)
        end
      end
    end
  end

  context "Populating a saved search" do
    setup do
      @saved_search = create(:saved_search, query: "bkub", user: @user)
      @post = create(:post, tag_string: "bkub")
    end

    should "work for a single tag search" do
      SavedSearch.populate("bkub")
      assert_equal([@post.id], SavedSearch.post_ids_for(@user.id))
    end

    should "work for a tag search returning no posts" do
      SavedSearch.populate("does_not_exist")
      assert_equal([], SavedSearch.post_ids_for(@user.id))
    end
  end

  context "Creating a saved search" do
    setup do
      FactoryBot.create(:tag_alias, antecedent_name: "zzz", consequent_name: "yyy", creator: @user)
      @saved_search = @user.saved_searches.create(query: " ZZZ xxx ")
    end

    should "normalize the query aside from the order" do
      assert_equal("yyy xxx", @saved_search.query)
    end

    should "normalize the label string" do
      @saved_search.label_string = "Foo Bar"
      assert_equal(%w[foo bar], @saved_search.labels)

      @saved_search.labels = ["Artist 1", "Artist 2"]
      assert_equal(%w[artist_1 artist_2], @saved_search.labels)
    end
  end

  context "A user with max saved searches" do
    setup do
      @user = create(:gold_user)
      User.any_instance.stubs(:max_saved_searches).returns(1)
      @ss1 = create(:saved_search, user: @user)
    end

    should "not be able to create another saved search" do
      @ss2 = build(:saved_search, user: @user)

      assert_equal(false, @ss2.valid?)
      assert_equal(["You can only have up to 1 saved search"], @ss2.errors.full_messages)
    end

    should "be able to edit existing saved searches" do
      @ss1.update!(query: "blah")

      assert_equal(true, @ss1.valid?)
      assert_equal("blah", @ss1.query)
    end
  end
end
