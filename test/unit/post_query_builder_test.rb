require 'test_helper'

class PostQueryBuilderTest < ActiveSupport::TestCase
  def assert_tag_match(posts, query, relation: Post.all, current_user: CurrentUser.user, tag_limit: nil, **options)
    assert_equal(posts.map(&:id), relation.user_tag_match(query, current_user, tag_limit: tag_limit, **options).pluck("posts.id"))
  end

  def assert_search_error(query, current_user: CurrentUser.user, **options)
    assert_raises(PostQuery::Error) { PostQuery.search(query, current_user: current_user, **options) }
  end

  def assert_fast_count(count, query, query_options = {}, fast_count_options = {})
    assert_equal(count, PostQuery.normalize(query, **query_options).with_implicit_metatags.fast_count(**fast_count_options))
  end

  setup do
    CurrentUser.user = create(:user)
  end

  teardown do
    CurrentUser.user = nil
  end

  context "Searching:" do
    should "return posts for the age:<1minute tag" do
      post = create(:post)
      assert_tag_match([post], "age:<1minute")
    end

    should "return posts for the age:<1minute tag when the user is in Pacific time zone" do
      post = create(:post)
      Time.zone = "Pacific Time (US & Canada)"
      assert_tag_match([post], "age:<1minute")
      Time.zone = "Eastern Time (US & Canada)"
    end

    should "return posts for the age:<1minute tag when the user is in Tokyo time zone" do
      post = create(:post)
      Time.zone = "Asia/Tokyo"
      assert_tag_match([post], "age:<1minute")
      Time.zone = "Eastern Time (US & Canada)"
    end

    should "return posts for the ' tag" do
      post1 = create(:post, tag_string: "'")
      post2 = create(:post, tag_string: "aaa bbb")

      assert_tag_match([post1], "'")
    end

    should "return posts for the \\ tag" do
      post1 = create(:post, tag_string: "\\")
      post2 = create(:post, tag_string: "aaa bbb")

      assert_tag_match([post1], "\\")
    end

    should "return posts for the ? tag" do
      post1 = create(:post, tag_string: "?")
      post2 = create(:post, tag_string: "aaa bbb")

      assert_tag_match([post1], "?")
    end

    should "return posts for the empty search" do
      post1 = create(:post)

      assert_tag_match([post1], "")
      assert_tag_match([post1], " ")
      assert_tag_match([post1], nil)
    end

    should "return posts for 1 tag" do
      post1 = create(:post, tag_string: "aaa")
      post2 = create(:post, tag_string: "aaa bbb")
      post3 = create(:post, tag_string: "bbb ccc")

      assert_tag_match([post2, post1], "aaa")
      assert_tag_match([post2, post1], "AAA")
      assert_tag_match([post2, post1], " aaa ")
    end

    should "return posts for a 2 tag join" do
      post1 = create(:post, tag_string: "aaa")
      post2 = create(:post, tag_string: "aaa bbb")
      post3 = create(:post, tag_string: "bbb ccc")

      assert_tag_match([post2], "aaa bbb")
      assert_tag_match([post2], " aaa bbb ")
    end

    should "return posts for a 2 tag union" do
      post1 = create(:post, tag_string: "aaa")
      post2 = create(:post, tag_string: "aaab bbb")
      post3 = create(:post, tag_string: "bbb ccc")

      assert_tag_match([post3, post1], "~aaa ~ccc")
    end

    should "return posts for 1 tag with exclusion" do
      post1 = create(:post, tag_string: "aaa")
      post2 = create(:post, tag_string: "aaa bbb")
      post3 = create(:post, tag_string: "bbb ccc")

      assert_tag_match([post1], "aaa -bbb")
    end

    should "return posts for 1 tag with a pattern" do
      post1 = create(:post, tag_string: "aaa")
      post2 = create(:post, tag_string: "aaab bbb")
      post3 = create(:post, tag_string: "bbb ccc")

      assert_tag_match([post2, post1], "a*")
    end

    should "return posts for 2 tags, one with a pattern" do
      post1 = create(:post, tag_string: "aaa")
      post2 = create(:post, tag_string: "aaab bbb")
      post3 = create(:post, tag_string: "bbb ccc")

      assert_tag_match([post2], "a* bbb")
    end

    should "return posts for a negated pattern" do
      post1 = create(:post, tag_string: "aaa")
      post2 = create(:post, tag_string: "aaab bbb")
      post3 = create(:post, tag_string: "bbb ccc")

      assert_tag_match([post3], "-a*")
      assert_tag_match([post3], "bbb -a*")
      assert_tag_match([post3], "~bbb -a*")
      assert_tag_match([post1], "a* -*b")
      assert_tag_match([post2], "-*c -a*a")
    end

    should "return posts for a complex search with multiple AND, OR, and NOT tags" do
      post1 = create(:post, tag_string: "original")
      post2 = create(:post, tag_string: "smile")
      post3 = create(:post, tag_string: "original smile")
      post4 = create(:post, tag_string: "original smile 1girl")
      post5 = create(:post, tag_string: "original smile 1girl 1boy")
      post6 = create(:post, tag_string: "original smile 1girl multiple_boys")
      post7 = create(:post, tag_string: "original smile multiple_girls")
      post8 = create(:post, tag_string: "original smile multiple_girls 1boy")
      post9 = create(:post, tag_string: "original smile multiple_girls multiple_boys")

      assert_tag_match([post7, post4], "original smile ~1girl ~multiple_girls -1boy -multiple_boys", tag_limit: 100)
    end

    should "ignore invalid operator syntax" do
      assert_nothing_raised do
        assert_tag_match([], "-")
        assert_tag_match([], "~")
      end
    end

    context "for an invalid metatag value" do
      should "return nothing" do
        post = create(:post_with_file, created_at: Time.parse("2021-06-15 12:00:00"), score: 42, filename: "test.jpg")

        assert_tag_match([], "score:foo")
        assert_tag_match([], "score:42x")
        assert_tag_match([], "score:x42")
        assert_tag_match([], "score:42.0")

        assert_tag_match([], "mpixels:foo")
        assert_tag_match([], "mpixels:0.1675foo")
        assert_tag_match([], "mpixels:foo0.1675")

        assert_tag_match([], "ratio:foo")
        assert_tag_match([], "ratio:1.49foo")
        assert_tag_match([], "ratio:foo1.49")
        assert_tag_match([], "ratio:1:0")
        assert_tag_match([], "ratio:1/0")
        assert_tag_match([], "ratio:-149/-100")

        assert_tag_match([], "filesize:foo")
        assert_tag_match([], "filesize:28086foo")
        assert_tag_match([], "filesize:foo28086")

        assert_tag_match([], "filesize:foo")
        assert_tag_match([], "filesize:28086foo")
        assert_tag_match([], "filesize:foo28086")

        assert_tag_match([], "date:foo")
        assert_tag_match([], "date:2021-13-01")
        assert_tag_match([], "date:2021-01-32")
        assert_tag_match([], "date:01-32-2021")
        assert_tag_match([], "date:13-01-2021")

        assert_tag_match([], "age:foo")
        assert_tag_match([], "age:30")

        assert_tag_match([], "md5:foo")
      end
    end

    should "return posts for the id:<N> metatag" do
      posts = create_list(:post, 3)

      assert_tag_match([posts[1]], "id:#{posts[1].id}")
      assert_tag_match([posts[2]], "id:>#{posts[1].id}")
      assert_tag_match([posts[0]], "id:<#{posts[1].id}")

      assert_tag_match([posts[2], posts[1]], "id:>=#{posts[1].id}")
      assert_tag_match([posts[1], posts[0]], "id:<=#{posts[1].id}")
      assert_tag_match([posts[2], posts[0]], "id:#{posts[0].id},#{posts[2].id}")

      assert_tag_match([posts[2], posts[1]], "id:#{posts[1].id}..")
      assert_tag_match([posts[1], posts[0]], "id:..#{posts[1].id}")
      assert_tag_match([posts[1], posts[0]], "id:#{posts[0].id}..#{posts[1].id}")
      assert_tag_match([posts[1], posts[0]], "id:#{posts[1].id}..#{posts[0].id}")
      assert_tag_match([posts[1], posts[0]], "id:#{posts[0].id}...#{posts[2].id}")

      assert_tag_match(posts.reverse, "id:#{posts[0].id},#{posts[1].id}..#{posts[2].id}")
      assert_tag_match(posts.reverse, "id:#{posts[0].id}..#{posts[1].id},#{posts[2].id}")
      assert_tag_match(posts.reverse, "id:#{posts[0].id},>=#{posts[1].id}")
      assert_tag_match(posts.reverse, "id:<=#{posts[1].id},#{posts[2].id}")

      assert_tag_match([], "id:<#{posts[0].id},>#{posts[2].id}")
      assert_tag_match([posts[2], posts[0]], "id:<=#{posts[0].id},>=#{posts[2].id}")
      assert_tag_match([posts[2], posts[0]], "id:..#{posts[0].id},#{posts[2].id}..")

      assert_tag_match([posts[1]], "id:<#{posts[0].id},#{posts[1].id},>#{posts[2].id}")
      assert_tag_match([posts[1]], "id:#{posts[1].id},<#{posts[0].id},>#{posts[2].id}")
      assert_tag_match([posts[1]], "id:<#{posts[0].id},>#{posts[2].id},#{posts[1].id}")

      assert_tag_match([posts[1], posts[0]], "-id:>#{posts[1].id}")
      assert_tag_match([posts[2], posts[1]], "-id:<#{posts[1].id}")
      assert_tag_match([posts[0]], "-id:>=#{posts[1].id}")
      assert_tag_match([posts[2]], "-id:<=#{posts[1].id}")
      assert_tag_match([posts[0]], "-id:#{posts[1].id}..#{posts[2].id}")
      assert_tag_match([posts[0]], "-id:#{posts[1].id},#{posts[2].id}")

      assert_tag_match([], "-id:#{posts[0].id},#{posts[1].id}..#{posts[2].id}")
      assert_tag_match([], "-id:#{posts[0].id}..#{posts[1].id},#{posts[2].id}")
      assert_tag_match([], "-id:#{posts[0].id},>=#{posts[1].id}")
      assert_tag_match([], "-id:<=#{posts[1].id},#{posts[2].id}")

      assert_tag_match(posts.reverse, "-id:<#{posts[0].id},>#{posts[2].id}")
      assert_tag_match([posts[1]], "-id:<=#{posts[0].id},>=#{posts[2].id}")
      assert_tag_match([posts[1]], "-id:..#{posts[0].id},#{posts[2].id}..")

      assert_tag_match([posts[2], posts[0]], "-id:<#{posts[0].id},#{posts[1].id},>#{posts[2].id}")
      assert_tag_match([posts[2], posts[0]], "-id:#{posts[1].id},<#{posts[0].id},>#{posts[2].id}")
      assert_tag_match([posts[2], posts[0]], "-id:<#{posts[0].id},>#{posts[2].id},#{posts[1].id}")

      assert_tag_match([], "id:#{posts[0].id} id:#{posts[2].id}")
      assert_tag_match([posts[0]], "-id:#{posts[1].id} -id:#{posts[2].id}")
      assert_tag_match([posts[1]], "id:>#{posts[0].id} id:<#{posts[2].id}")
    end

    should "return posts for the score:<N> metatag" do
      post1 = create(:post, score: 5)
      post2 = create(:post, score: 0)

      assert_tag_match([post1], "score:5")
      assert_tag_match([post2], "score:0")
    end

    should "return posts for the upvotes:<N> metatag" do
      post1 = create(:post, up_score: 5)
      post2 = create(:post, up_score: 0)

      assert_tag_match([post1], "upvotes:5")
      assert_tag_match([post2], "upvotes:0")
    end

    should "return posts for the downvotes:<N> metatag" do
      post1 = create(:post, down_score: -5)
      post2 = create(:post, down_score: 0)

      assert_tag_match([post1], "downvotes:5")
      assert_tag_match([post2], "downvotes:0")
    end

    should "return posts for the fav:<name> metatag" do
      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user, enable_private_favorites: true)
      post1 = as(user1) { create(:post, tag_string: "fav:true") }
      post2 = as(user2) { create(:post, tag_string: "fav:true") }
      post3 = as(user3) { create(:post, tag_string: "fav:true") }

      assert_tag_match([post1], "fav:#{user1.name}")
      assert_tag_match([post2], "fav:#{user2.name}")
      assert_tag_match([], "fav:#{user3.name}")

      assert_tag_match([], "fav:#{user1.name} fav:#{user2.name}")
      assert_tag_match([post1], "fav:#{user1.name} -fav:#{user2.name}")
      assert_tag_match([post3], "-fav:#{user1.name} -fav:#{user2.name}")

      assert_tag_match([], "fav:dne")

      assert_tag_match([post3, post2], "-fav:#{user1.name}")
      assert_tag_match([post3], "-fav:#{user1.name} -fav:#{user2.name}")
      assert_tag_match([post3, post2, post1], "-fav:dne")

      as(user3) do
        assert_tag_match([post3], "fav:#{user3.name}")
        assert_tag_match([post2, post1], "-fav:#{user3.name}")
      end
    end

    should "return posts for the ordfav:<name> metatag" do
      post1 = create(:post, tag_string: "fav:#{CurrentUser.user.name}")
      post2 = create(:post, tag_string: "fav:#{CurrentUser.user.name}")

      assert_tag_match([post2, post1], "ordfav:#{CurrentUser.user.name}")
      assert_tag_match([], "ordfav:does_not_exist")

      assert_tag_match([post2, post1], "ordfav:#{CurrentUser.user.name} commentary:false")
      assert_tag_match([post2, post1], "ordfav:#{CurrentUser.user.name} favcount:>0")
      assert_tag_match([post2, post1], "ordfav:#{CurrentUser.user.name} comments:0")
      assert_tag_match([post2, post1], "ordfav:#{CurrentUser.user.name} -has:comments")
    end

    should "return posts for the pool:<name> metatag" do
      SqsService.any_instance.stubs(:send_message)

      pool1 = create(:pool, name: "test_a", category: "series")
      pool2 = create(:pool, name: "test_b", category: "collection")
      post1 = create(:post, tag_string: "pool:test_a")
      post2 = create(:post, tag_string: "pool:test_b")

      assert_tag_match([post1], "pool:#{pool1.id}")
      assert_tag_match([post2], "pool:#{pool2.id}")

      assert_tag_match([post1], "pool:TEST_A")
      assert_tag_match([post2], "pool:Test_B")
      assert_tag_match([post2], 'pool:"Test B"')
      assert_tag_match([post2], "pool:'Test B'")

      assert_tag_match([post1], "pool:test_a")
      assert_tag_match([post2], "-pool:test_a")

      assert_tag_match([], "pool:test_a pool:test_b")
      assert_tag_match([], "-pool:test_a -pool:test_b")

      assert_tag_match([post2, post1], "pool:test*")

      assert_tag_match([post2, post1], "pool:any")
      assert_tag_match([post2, post1], "-pool:none")
      assert_tag_match([], "-pool:any")
      assert_tag_match([], "pool:none")

      assert_tag_match([post1], "pool:series")
      assert_tag_match([post2], "-pool:series")
      assert_tag_match([post2], "pool:collection")
      assert_tag_match([post1], "-pool:collection")
    end

    should "return posts for the ordpool:<name> metatag" do
      posts = create_list(:post, 2, tag_string: "newpool:test")

      assert_tag_match(posts, "ordpool:test")
    end

    should "return posts for the parent:<N> metatag" do
      post = create(:post)
      parent = create(:post)
      child = create(:post, parent: parent)

      assert_tag_match([parent, post], "parent:none")
      assert_tag_match([child], "-parent:none")

      assert_tag_match([child], "parent:any")
      assert_tag_match([parent, post], "-parent:any")

      assert_tag_match([child, parent], "parent:#{parent.id}")
      assert_tag_match([child], "parent:#{child.id}")

      assert_tag_match([post], "-parent:#{parent.id}")
      assert_tag_match([parent, post], "-parent:#{child.id}")

      assert_tag_match([child], "parent:#{parent.id} parent:#{child.id}")

      assert_tag_match([], "parent:garbage")
      assert_tag_match([child, parent, post], "-parent:garbage")

      assert_tag_match([child, post], "child:none")
      assert_tag_match([parent], "child:any")
      assert_tag_match([], "child:garbage")

      assert_tag_match([parent], "-child:none")
      assert_tag_match([child, post], "-child:any")
      assert_tag_match([child, parent, post], "-child:garbage")
    end

    should "return posts when using the status of the parent/child" do
      parent_of_deleted = create(:post)
      deleted = create(:post, is_deleted: true, tag_string: "parent:#{parent_of_deleted.id}")
      child_of_deleted = create(:post, tag_string: "parent:#{deleted.id}")
      all = [child_of_deleted, deleted, parent_of_deleted]

      assert_tag_match([child_of_deleted], "parent:deleted")
      assert_tag_match(all - [child_of_deleted], "-parent:deleted")

      assert_tag_match([parent_of_deleted], "child:deleted")
      assert_tag_match(all - [parent_of_deleted], "-child:deleted")
    end

    should "return posts for the favgroup:<name> metatag" do
      post1 = create(:post)
      post2 = create(:post)
      post3 = create(:post)

      favgroup1 = create(:favorite_group, creator: CurrentUser.user, post_ids: [post1.id])
      favgroup2 = create(:favorite_group, creator: CurrentUser.user, post_ids: [post2.id])
      favgroup3 = create(:private_favorite_group, post_ids: [post3.id])

      assert_tag_match([post1], "favgroup:#{favgroup1.id}")
      assert_tag_match([post2], "favgroup:#{favgroup2.name}")
      assert_tag_match([post2, post1], "favgroup:any")
      assert_tag_match([], "favgroup:#{favgroup3.name}")
      assert_tag_match([], "favgroup:dne")

      assert_tag_match([post3, post2], "-favgroup:#{favgroup1.id}")
      assert_tag_match([post3, post1], "-favgroup:#{favgroup2.name}")
      assert_tag_match([post3], "-favgroup:any")
      assert_tag_match([post3], "favgroup:none")
      assert_tag_match([post3, post2, post1], "-favgroup:#{favgroup3.name}")
      assert_tag_match([post3, post2, post1], "-favgroup:dne")

      assert_tag_match([post3], "-favgroup:#{favgroup1.name} -favgroup:#{favgroup2.name}")

      as(favgroup3.creator) do
        assert_tag_match([post1], "favgroup:#{favgroup1.id}")
        assert_tag_match([post2], "favgroup:#{favgroup2.id}")
        assert_tag_match([post3], "favgroup:#{favgroup3.id}")

        assert_tag_match([], "favgroup:#{favgroup1.name}")
        assert_tag_match([], "favgroup:#{favgroup2.name}")
        assert_tag_match([post3], "favgroup:#{favgroup3.name}")
        assert_tag_match([post3], "favgroup:any")
      end
    end

    should "return posts for the ordfavgroup:<name> metatag" do
      post1 = create(:post)
      post2 = create(:post)
      post3 = create(:post)

      favgroup1 = create(:favorite_group, creator: CurrentUser.user, post_ids: [post1.id, post2.id])
      favgroup2 = create(:private_favorite_group, post_ids: [post2.id, post3.id])

      assert_tag_match([post1, post2], "ordfavgroup:#{favgroup1.id}")
      assert_tag_match([post1, post2], "ordfavgroup:#{favgroup1.name}")
      assert_tag_match([], "ordfavgroup:#{favgroup2.id}")
      assert_tag_match([], "ordfavgroup:#{favgroup2.name}")

      as(favgroup2.creator) do
        assert_tag_match([post2, post3], "ordfavgroup:#{favgroup2.id}")
        assert_tag_match([post2, post3], "ordfavgroup:#{favgroup2.name}")
        assert_tag_match([post1, post2], "ordfavgroup:#{favgroup1.id}")
        assert_tag_match([], "ordfavgroup:#{favgroup1.name}")
      end
    end

    should "return posts for the user:<name> metatag" do
      users = create_list(:user, 2, created_at: 2.weeks.ago)
      posts = users.map { |u| create(:post, uploader: u) }

      assert_tag_match([posts[0]], "user:#{users[0].name}")
      assert_tag_match([posts[1]], "-user:#{users[0].name}")
      assert_tag_match([posts[1]], "filetype:jpg -user:#{users[0].name}")
    end

    should "return posts for the approver:<name> metatag" do
      users = create_list(:user, 2)
      posts = users.map { |u| create(:post, approver: u) }
      posts << create(:post, approver: nil)

      assert_tag_match([posts[0]], "approver:#{users[0].name}")
      assert_tag_match([posts[2], posts[1]], "-approver:#{users[0].name}")
      assert_tag_match([posts[2], posts[0]], "-approver:#{users[1].name}")
      assert_tag_match([posts[1], posts[0]], "approver:any")
      assert_tag_match([posts[2]], "approver:none")
      assert_tag_match([posts[2]], "approver:NONE")
      assert_tag_match([], "approver:does_not_exist")
    end

    should "return posts for the flagger:<name> metatag" do
      posts = create_list(:post, 2)
      flag = create(:post_flag, post: posts[0])

      assert_tag_match([posts[0]], "flagger:#{flag.creator.name}", current_user: flag.creator)
      assert_tag_match([posts[1]], "-flagger:#{flag.creator.name}", current_user: flag.creator)

      assert_tag_match([], "flagger:#{flag.creator.name}", current_user: User.anonymous)
      assert_tag_match([posts[1], posts[0]], "-flagger:#{flag.creator.name}", current_user: User.anonymous)

      assert_tag_match([posts[0]], "flagger:any")
      assert_tag_match([posts[1]], "flagger:none")
      assert_tag_match([posts[1]], "flagger:NONE")
      assert_tag_match([], "flagger:does_not_exist")
    end

    should "return self-flagged posts for the flagger:<name> metatag" do
      flagger = create(:user)
      posts = create_list(:post, 2, uploader: flagger)
      flag = create(:post_flag, post: posts[0], creator: flagger)

      assert_tag_match([], "flagger:#{flagger.name} user:#{flagger.name}", current_user: User.anonymous)
      assert_tag_match([posts[0]], "flagger:#{flagger.name} user:#{flagger.name}", current_user: flagger)
      assert_tag_match([posts[0]], "flagger:#{flagger.name} user:#{flagger.name}", current_user: create(:mod_user))
    end

    should "return posts for the commenter:<name> metatag" do
      users = create_list(:user, 2, created_at: 2.weeks.ago)
      posts = create_list(:post, 2)
      comms = users.zip(posts).map { |u, p| as(u) { create(:comment, creator: u, post: p) } }

      assert_tag_match([posts[0]], "commenter:#{users[0].name}")
      assert_tag_match([posts[1]], "commenter:#{users[1].name}")
      assert_tag_match([posts[1]], "-commenter:#{users[0].name}")
      assert_tag_match([posts[0]], "-commenter:#{users[1].name}")
    end

    should "return posts with deleted comments correctly for the commenter:<name> metatag" do
      user = create(:user)
      c1 = create(:comment, creator: user)
      c2 = create(:comment, creator: user, is_deleted: true)

      assert_tag_match([c1.post], "commenter:#{user.name}", current_user: User.anonymous)
      assert_tag_match([c2.post, c1.post], "commenter:#{user.name}", current_user: user)
      assert_tag_match([c2.post, c1.post], "commenter:#{user.name}", current_user: create(:mod_user))
    end

    should "return posts for the commenter:<any|none> metatag" do
      posts = create_list(:post, 2)
      create(:comment, creator: create(:user, created_at: 2.weeks.ago), post: posts[0], is_deleted: false)
      create(:comment, creator: create(:user, created_at: 2.weeks.ago), post: posts[1], is_deleted: true)

      assert_tag_match(posts.reverse, "commenter:any")
      assert_tag_match([], "commenter:none")
    end

    should "return posts for the noter:<name> metatag" do
      users = create_list(:user, 2)
      posts = create_list(:post, 2)
      notes = users.zip(posts).map do |u, p|
        as(u) { create(:note, post: p) }
      end

      assert_tag_match([posts[0]], "noter:#{users[0].name}")
      assert_tag_match([posts[1]], "noter:#{users[1].name}")
      assert_tag_match([posts[1]], "-noter:#{users[0].name}")
      assert_tag_match([posts[0]], "-noter:#{users[1].name}")
    end

    should "return posts for the noter:<any|none> metatag" do
      posts = create_list(:post, 2)
      create(:note, post: posts[0], is_active: true)
      create(:note, post: posts[1], is_active: false)

      assert_tag_match(posts.reverse, "noter:any")
      assert_tag_match(posts.reverse, "-noter:none")
      assert_tag_match([], "noter:none")
      assert_tag_match([], "-noter:any")
    end

    should "return posts for the noteupdater:<name> metatag" do
      user1 = create(:user)
      user2 = create(:user)
      note1 = as(user1) { create(:note) }
      note2 = as(user2) { create(:note) }

      assert_tag_match([note1.post], "noteupdater:#{user1.name}")
      assert_tag_match([note2.post], "noteupdater:#{user2.name}")
      assert_tag_match([note2.post], "-noteupdater:#{user1.name}")
      assert_tag_match([note1.post], "-noteupdater:#{user2.name}")
    end

    should "return posts for the note_count:<N> metatag" do
      posts = create_list(:post, 3)
      create(:note, post: posts[0], is_active: true)
      create(:note, post: posts[1], is_active: false)

      assert_tag_match([posts[1], posts[0]], "note_count:1")
      assert_tag_match([posts[0]], "active_note_count:1")
      assert_tag_match([posts[1]], "deleted_note_count:1")

      assert_tag_match([posts[1], posts[0]], "notes:1")
      assert_tag_match([posts[0]], "active_notes:1")
      assert_tag_match([posts[1]], "deleted_notes:1")

      assert_tag_match([posts[2]], "-note_count:1")
    end

    should "return posts for the flag_count:<N> metatag" do
      posts = create_list(:post, 3)
      create(:post_flag, post: posts[1], status: :succeeded)
      create(:post_flag, post: posts[2], status: :rejected, created_at: 4.days.ago)
      create(:post_flag, post: posts[2], status: :pending)

      assert_tag_match([posts[0]], "flag_count:0")
      assert_tag_match([posts[1]], "flag_count:1")
      assert_tag_match([posts[2]], "flag_count:2")

      assert_tag_match([posts[0]], "flags:0")
      assert_tag_match([posts[1]], "flags:1")
      assert_tag_match([posts[2]], "flags:2")

      assert_tag_match([posts[2], posts[0]], "-flags:1")
    end

    should "return posts for the commentaryupdater:<name> metatag" do
      user1 = create(:user)
      user2 = create(:user)
      post1 = create(:post)
      post2 = create(:post)
      artcomm1 = as(user1) { create(:artist_commentary, post: post1) }
      artcomm2 = as(user2) { create(:artist_commentary, post: post2) }

      assert_tag_match([post1], "commentaryupdater:#{user1.name}")
      assert_tag_match([post2], "commentaryupdater:#{user2.name}")
      assert_tag_match([post2], "-commentaryupdater:#{user1.name}")
      assert_tag_match([post1], "-commentaryupdater:#{user2.name}")

      assert_tag_match([post1], "artcomm:#{user1.name}")
      assert_tag_match([post2], "artcomm:#{user2.name}")
      assert_tag_match([post2], "-artcomm:#{user1.name}")
      assert_tag_match([post1], "-artcomm:#{user2.name}")

      assert_tag_match([post2, post1], "commentaryupdater:any")
      assert_tag_match([], "commentaryupdater:none")
    end

    should "return posts for the commentary:<query> metatag" do
      post1 = create(:post)
      post2 = create(:post)
      post3 = create(:post)
      post4 = create(:post)

      artcomm1 = create(:artist_commentary, post: post1, translated_title: "azur lane")
      artcomm2 = create(:artist_commentary, post: post2, translated_title: "", translated_description: "")
      artcomm3 = create(:artist_commentary, post: post3, original_title: "", original_description: "", translated_title: "", translated_description: "")

      assert_tag_match([post2, post1], "commentary:true")
      assert_tag_match([post4, post3], "commentary:false")

      assert_tag_match([post2, post1], "commentary:TRUE")
      assert_tag_match([post4, post3], "commentary:FALSE")

      assert_tag_match([post4, post3], "-commentary:true")
      assert_tag_match([post2, post1], "-commentary:false")

      assert_tag_match([post1], "commentary:translated")
      assert_tag_match([post4, post3, post2], "-commentary:translated")

      assert_tag_match([post2], "commentary:untranslated")
      assert_tag_match([post4, post3, post1], "-commentary:untranslated")

      assert_tag_match([post1], 'commentary:"azur lane"')
      assert_tag_match([post4, post3, post2], '-commentary:"azur lane"')

      assert_tag_match([], "commentary:'true'")
      assert_tag_match([], "commentary:'false'")
      assert_tag_match([], "commentary:'translated'")
      assert_tag_match([], "commentary:'untranslated'")
    end

    should "return posts for the comment:<query> metatag" do
      post1 = create(:post)
      post2 = create(:post)

      comment1 = create(:comment, post: post1, body: "petting cats")
      comment2 = create(:comment, post: post2, body: "walking dogs")

      assert_tag_match([post1], "comment:petting")
      assert_tag_match([post1], "comment:pet")
      assert_tag_match([post1], "comment:cats")
      assert_tag_match([post1], "comment:cat")
      assert_tag_match([post1], "comment:*at*")

      assert_tag_match([post2], "comment:walk")
      assert_tag_match([post2], "comment:dog")

      assert_tag_match([post2], "-comment:cat")
      assert_tag_match([post1], "-comment:dog")

      assert_tag_match([post2, post1], "comment:*ing*")
    end

    should "return posts for the note:<query> metatag" do
      post1 = create(:post)
      post2 = create(:post)

      note1 = create(:note, post: post1, body: "petting cats")
      note2 = create(:note, post: post2, body: "walking dogs")

      assert_tag_match([post1], "note:petting")
      assert_tag_match([post1], "note:pet")
      assert_tag_match([post1], "note:cats")
      assert_tag_match([post1], "note:cat")
      assert_tag_match([post1], "note:*at*")

      assert_tag_match([post2], "note:walk")
      assert_tag_match([post2], "note:dog")

      assert_tag_match([post2], "-note:cat")
      assert_tag_match([post1], "-note:dog")

      assert_tag_match([post2, post1], "note:*ing*")
    end

    should "return posts for the date:<d> metatag" do
      post = create(:post, created_at: Time.zone.parse("2017-05-15 12:00"))

      assert_tag_match([post], "date:2017-05-15")
      assert_tag_match([post], "date:2017/05/15")
      assert_tag_match([post], "date:2017.05.15")

      assert_tag_match([post], "date:15-5-2017")
      assert_tag_match([post], "date:15/5/2017")
      assert_tag_match([post], "date:15.5.2017")

      assert_tag_match([], "-date:2017-05-15")
    end

    should "return posts for the age:<n> metatag" do
      post = create(:post)

      assert_tag_match([post], "age:<60s")
      assert_tag_match([post], "age:<1mi")
      assert_tag_match([post], "age:<1h")
      assert_tag_match([post], "age:<1d")
      assert_tag_match([post], "age:<1w")
      assert_tag_match([post], "age:<1mo")
      assert_tag_match([post], "age:<1y")

      assert_tag_match([post], "age:<=1y")
      assert_tag_match([post], "age:>0s")
      assert_tag_match([post], "age:>=0s")
      assert_tag_match([post], "age:0s..1min")
      assert_tag_match([post], "age:1min..0s")

      assert_tag_match([], "age:>1y")
      assert_tag_match([], "age:>=1y")
      assert_tag_match([], "age:1y..2y")
      assert_tag_match([], "age:>1y age:<1y")

      assert_tag_match([post], "-age:>1y")
      assert_tag_match([], "-age:<1y")

      assert_tag_match([], "age:<60")
    end

    should "return posts for the ratio:<x:y> metatag" do
      post = create(:post_with_file, filename: "test.jpg")

      assert_tag_match([post], "ratio:1.49")
      assert_tag_match([post], "ratio:.149e1")
      assert_tag_match([post], "ratio:0.149e1")
      assert_tag_match([post], "ratio:149e-2")
      assert_tag_match([post], "ratio:1490:1000")
      assert_tag_match([post], "ratio:149:100")
      assert_tag_match([post], "ratio:149/100")

      assert_tag_match([], "-ratio:1.49")
    end

    should "return posts for the mpixels:N metatag" do
      post = create(:post_with_file, filename: "test.jpg")

      assert_tag_match([post], "mpixels:0.1675")
      assert_tag_match([post], "mpixels:+0.1675")
      assert_tag_match([post], "mpixels:.1675")
      assert_tag_match([post], "mpixels:+.1675")
      assert_tag_match([post], "mpixels:1675e-4")

      assert_tag_match([], "mpixels:0.2")
      assert_tag_match([], "-mpixels:0.1675")
    end

    should "return posts for the duration:<x> metatag" do
      post = create(:post, media_asset: create(:media_asset, file: "test/files/test-512x512.webm"))

      assert_tag_match([post], "duration:0.48")
      assert_tag_match([post], "duration:>0.4")
      assert_tag_match([post], "duration:<0.5")
      assert_tag_match([], "duration:>1")
    end

    should "return posts for the is:<status> metatag" do
      pending = create(:post, is_pending: true)
      flagged = create(:post, is_flagged: true)
      deleted = create(:post, is_deleted: true)
      banned  = create(:post, is_banned: true)
      appealed = create(:post, is_deleted: true)
      appeal = create(:post_appeal, post: appealed)

      assert_tag_match([appealed, flagged, pending], "is:modqueue")
      assert_tag_match([pending], "is:pending")
      assert_tag_match([flagged], "is:flagged")
      assert_tag_match([appealed], "is:appealed")
      assert_tag_match([appealed, deleted], "is:deleted")
      assert_tag_match([banned],  "is:banned")
      assert_tag_match([banned], "is:active")
      assert_tag_match([banned], "is:active is:banned")
    end

    should "return posts for the is:<rating> metatag" do
      g = create(:post, rating: "g")
      s = create(:post, rating: "s")
      q = create(:post, rating: "q")
      e = create(:post, rating: "e")
      all = [e, q, s, g]

      assert_tag_match([g], "is:general")
      assert_tag_match([s], "is:safe")
      assert_tag_match([s], "is:sensitive")
      assert_tag_match([q], "is:questionable")
      assert_tag_match([e], "is:explicit")
      assert_tag_match([s, g], "is:sfw")
      assert_tag_match([e, q], "is:nsfw")
    end

    should "return posts for the is:<filetype> metatag" do
      jpg = create(:post, file_ext: "jpg")
      png = create(:post, file_ext: "png")
      gif = create(:post, file_ext: "gif")
      mp4 = create(:post, file_ext: "mp4")
      webm = create(:post, file_ext: "webm")
      swf = create(:post, file_ext: "swf")
      zip = create(:post, file_ext: "zip")

      assert_tag_match([jpg], "is:jpg")
      assert_tag_match([png], "is:png")
      assert_tag_match([gif], "is:gif")
      assert_tag_match([mp4], "is:mp4")
      assert_tag_match([webm], "is:webm")
      assert_tag_match([swf], "is:swf")
      assert_tag_match([zip], "is:zip")
    end

    should "return posts for the is:<parent> metatag" do
      parent = create(:post)
      child = create(:post, parent: parent)

      assert_tag_match([parent], "is:parent")
      assert_tag_match([child], "is:child")
      assert_tag_match([], "is:blah")
    end

    should "return posts for the has:<value> metatag" do
      parent = create(:post)
      child = create(:post, parent: parent)

      appeal = create(:post_appeal)
      flag = create(:post_flag)
      replacement = create(:post_replacement)
      comment = create(:comment)
      commentary = create(:artist_commentary)
      note = create(:note)

      pooled = create(:post)
      pool = create(:pool, post_ids: [pooled.id])

      assert_tag_match([child], "has:parent")
      assert_tag_match([parent], "has:child")
      assert_tag_match([parent], "has:children")
      assert_tag_match([appeal.post], "has:appeals")
      assert_tag_match([flag.post], "has:flags")
      assert_tag_match([replacement.post], "has:replacements")
      assert_tag_match([comment.post], "has:comments")
      assert_tag_match([commentary.post], "has:commentary")
      assert_tag_match([note.post], "has:notes")
      assert_tag_match([pooled], "has:pools")
      assert_tag_match([], "has:blah")
    end

    should "return posts for the has:<source> metatag" do
      post1 = create(:post, source: "blah")
      post2 = create(:post, source: nil)

      assert_tag_match([post1], "has:source")
    end

    should "return posts for the status:<type> metatag" do
      pending = create(:post, is_pending: true)
      flagged = create(:post, is_flagged: true)
      deleted = create(:post, is_deleted: true)
      banned  = create(:post, is_banned: true)
      appealed = create(:post, is_deleted: true)
      appeal = create(:post_appeal, post: appealed)
      all = [appealed, banned, deleted, flagged, pending]

      assert_tag_match([appealed, flagged, pending], "status:modqueue")
      assert_tag_match([pending], "status:pending")
      assert_tag_match([flagged], "status:flagged")
      assert_tag_match([appealed], "status:appealed")
      assert_tag_match([appealed, deleted], "status:deleted")
      assert_tag_match([banned],  "status:banned")
      assert_tag_match([banned], "status:active")
      assert_tag_match([banned], "status:active status:banned")
      assert_tag_match(all, "status:any")
      assert_tag_match(all, "status:all")

      assert_tag_match(all - [flagged, pending, appealed], "-status:modqueue")
      assert_tag_match(all - [pending], "-status:pending")
      assert_tag_match(all - [flagged], "-status:flagged")
      assert_tag_match(all - [appealed], "-status:appealed")
      assert_tag_match(all - [deleted, appealed], "-status:deleted")
      assert_tag_match(all - [banned],  "-status:banned")
      assert_tag_match(all - [banned], "-status:active")

      assert_tag_match([], "status:garbage")
      assert_tag_match(all, "-status:garbage")
    end

    should "return posts for the status:unmoderated metatag" do
      flagged = create(:post)
      pending = create(:post, is_pending: true)
      disapproved = create(:post, is_pending: true)
      appealed = create(:post, is_deleted: true)

      create(:post_flag, post: flagged, creator: create(:user, created_at: 2.weeks.ago))
      create(:post_appeal, post: appealed)
      create(:post_disapproval, user: CurrentUser.user, post: disapproved, reason: "disinterest")

      assert_tag_match([appealed, pending, flagged], "status:unmoderated")
      assert_tag_match([disapproved], "-status:unmoderated")
    end

    should "return nothing for the -status:any metatag" do
      create(:post)

      assert_tag_match([], "-status:any")
      assert_tag_match([], "-status:all")
    end

    should "return posts for the filetype:<ext> metatag" do
      png = create(:post, file_ext: "png")
      jpg = create(:post, file_ext: "jpg")

      assert_tag_match([png], "filetype:png")
      assert_tag_match([jpg], "-filetype:png")
      assert_tag_match([jpg, png], "filetype:png,jpg")
      assert_tag_match([], "filetype:png filetype:jpg")
      assert_tag_match([], "-filetype:png -filetype:jpg")
      assert_tag_match([], "filetype:garbage")
    end

    should "return posts for the embedded:<true|false> metatag" do
      p1 = create(:post, has_embedded_notes: true)
      p2 = create(:post, has_embedded_notes: false)

      assert_tag_match([p1], "embedded:true")
      assert_tag_match([p2], "embedded:false")

      assert_tag_match([p2], "-embedded:true")
      assert_tag_match([p1], "-embedded:false")

      assert_tag_match([], "embedded:false embedded:true")
      assert_tag_match([], "embedded:garbage")
      assert_tag_match([p2, p1], "-embedded:garbage")
    end

    should "return posts for the tagcount:<n> metatags" do
      post = create(:post, tag_string: "artist:wokada copyright:vocaloid char:hatsune_miku twintails")

      assert_tag_match([post], "tagcount:4")
      assert_tag_match([post], "arttags:1")
      assert_tag_match([post], "copytags:1")
      assert_tag_match([post], "chartags:1")
      assert_tag_match([post], "gentags:1")

      assert_tag_match([], "-gentags:1")
      assert_tag_match([], "-tagcount:4")
    end

    should "return posts for the md5:<md5> metatag" do
      post1 = create(:post_with_file, filename: "test.jpg")
      post2 = create(:post)

      assert_tag_match([post1], "md5:ecef68c44edb8a0d6a3070b5f8e8ee76")
      assert_tag_match([post1], "md5:ECEF68C44EDB8A0D6A3070B5F8E8EE76")
      assert_tag_match([post1], "md5:081a5c3b92d8980d1aadbd215bfac5b9,ecef68c44edb8a0d6a3070b5f8e8ee76")

      assert_tag_match([post2], "-md5:ecef68c44edb8a0d6a3070b5f8e8ee76")
      assert_tag_match([post2], "-md5:ECEF68C44EDB8A0D6A3070B5F8E8EE76")

      assert_tag_match([], "md5:xyz")
      assert_tag_match([], "md5:ecef68c44edb8a0d6a3070b5f8e8ee76 md5:xyz")

      assert_tag_match([post2, post1], "-md5:xyz")
    end

    should "return posts for a source:<text> search" do
      post1 = create(:post, source: "abc def")
      post2 = create(:post, source: "abcdefg")
      post3 = create(:post, source: "")

      assert_tag_match([post1], 'source:"abc def"')
      assert_tag_match([post1], "source:'abc def'")
      assert_tag_match([post2], "source:abcde")
      assert_tag_match([post2], "source:ABCDE")
      assert_tag_match([post3, post1], "-source:abcde")

      assert_tag_match([post3], "source:none")
      assert_tag_match([post3], "source:NONE")
      assert_tag_match([post3], 'source:""')
      assert_tag_match([post3], "source:''")
      assert_tag_match([post3], "source:")
      assert_tag_match([post2, post1], "-source:none")
      assert_tag_match([post2, post1], "-source:''")
      assert_tag_match([post2, post1], '-source:""')

      assert_tag_match([], "source:'none'")
      assert_tag_match([], "source:none source:abcde")
      assert_tag_match([], "source:abcde source:xzy")
    end

    should "return posts for a pixiv source search" do
      url = "http://i1.pixiv.net/img123/img/artist-name/789.png"
      post = create(:post, source: url)

      assert_tag_match([post], "source:*.pixiv.net/img*/artist-name/*")
      assert_tag_match([],     "source:*.pixiv.net/img*/artist-fake/*")
      assert_tag_match([post], "source:http://*.pixiv.net/img*/img/artist-name/*")
      assert_tag_match([],     "source:http://*.pixiv.net/img*/img/artist-fake/*")
    end

    should "return posts for a pixiv id search (type 1)" do
      url = "http://i1.pixiv.net/img-inf/img/2013/03/14/03/02/36/34228050_s.jpg"
      post = create(:post, source: url)
      assert_tag_match([post], "pixiv_id:34228050")
    end

    should "return posts for a pixiv id search (type 2)" do
      url = "http://i1.pixiv.net/img123/img/artist-name/789.png"
      post = create(:post, source: url)
      assert_tag_match([post], "pixiv_id:789")
    end

    should "return posts for a pixiv id search (type 3)" do
      url = "http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=19113635&page=0"
      post = create(:post, source: url)
      assert_tag_match([post], "pixiv_id:19113635")
    end

    should "return posts for a pixiv id search (type 4)" do
      url = "http://i2.pixiv.net/img70/img/disappearedstump/34551381_p3.jpg?1364424318"
      post = create(:post, source: url)
      assert_tag_match([post], "pixiv_id:34551381")
    end

    should "return posts for a pixiv_id:any search" do
      url = "http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p0.png"
      post = create(:post, source: url)
      assert_tag_match([post], "pixiv_id:any")
    end

    should "return posts for a pixiv_id: search" do
      post1 = create(:post, pixiv_id: nil)
      post2 = create(:post, pixiv_id: 42, source: "http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/42_p0.png")

      assert_tag_match([post2], "pixiv_id:42")
      assert_tag_match([post1], "-pixiv_id:42")

      assert_tag_match([post2], "pixiv_id:>=42")
      assert_tag_match([],      "pixiv_id:<42")

      assert_tag_match([],      "-pixiv_id:>=42")
      assert_tag_match([post2], "-pixiv_id:<42")

      assert_tag_match([post1], "pixiv_id:none")
      assert_tag_match([post2], "pixiv_id:any")

      assert_tag_match([post2], "-pixiv_id:none")
      assert_tag_match([post1], "-pixiv_id:any")

      assert_tag_match([post1], "pixiv:none")
      assert_tag_match([post2], "pixiv:any")

      assert_tag_match([], "-pixiv_id:>40,<50")
      assert_tag_match([post2], "-pixiv_id:<40,>50")
    end

    should "return posts for the search: metatag" do
      @post1 = create(:post, tag_string: "aaa")
      @post2 = create(:post, tag_string: "bbb")
      create(:saved_search, query: "aaa", labels: ["zzz"], user: CurrentUser.user)
      create(:saved_search, query: "bbb", user: CurrentUser.user)

      Danbooru.config.stubs(:redis_url).returns("redis://localhost:6379")
      Redis.any_instance.stubs(:exists?).with("search:aaa").returns(true)
      Redis.any_instance.stubs(:exists?).with("search:bbb").returns(true)
      Redis.any_instance.stubs(:smembers).with("search:aaa").returns([@post1.id])
      Redis.any_instance.stubs(:smembers).with("search:bbb").returns([@post2.id])

      assert_tag_match([@post1], "search:zzz")
      assert_tag_match([@post1], "search:ZZZ")
      assert_tag_match([@post2, @post1], "search:all")
      assert_tag_match([@post2, @post1], "search:ALL")
      assert_tag_match([], "search:does_not_exist")

      assert_tag_match([@post2], "-search:zzz")
      assert_tag_match([@post2], "-search:ZZZ")
      assert_tag_match([], "-search:all")
      assert_tag_match([], "-search:ALL")
      assert_tag_match([@post2, @post1], "-search:does_not_exist")
    end

    should "return posts for a rating:<s|q|e> metatag" do
      s = create(:post, rating: "s")
      q = create(:post, rating: "q")
      e = create(:post, rating: "e")
      all = [e, q, s]

      assert_tag_match([s], "rating:s")
      assert_tag_match([q], "rating:q")
      assert_tag_match([e], "rating:e")
      assert_tag_match([e, q], "rating:q,e")
      assert_tag_match([], "rating:s rating:q")

      assert_tag_match(all - [s], "-rating:s")
      assert_tag_match(all - [q], "-rating:q")
      assert_tag_match(all - [e], "-rating:e")
    end

    context "for the upvote:<user> metatag" do
      setup do
        @user = create(:gold_user)
        @upvote = create(:post_vote, user: @user, score: 1)
        @downvote = create(:post_vote, user: @user, score: -1)
      end

      should "show public upvotes to all users" do
        as(User.anonymous) do
          assert_tag_match([@upvote.post], "upvote:#{@user.name}")
          assert_tag_match([@downvote.post], "-upvote:#{@user.name}")
        end
      end

      should "not show private upvotes to other users" do
        @user.update!(enable_private_favorites: true)

        as(User.anonymous) do
          assert_tag_match([], "upvote:#{@user.name}")
          assert_tag_match([@downvote.post, @upvote.post], "-upvote:#{@user.name}")
        end
      end

      should "show private upvotes to admins" do
        @user.update!(enable_private_favorites: true)

        as(create(:admin_user)) do
          assert_tag_match([@upvote.post], "upvote:#{@user.name}")
          assert_tag_match([@downvote.post], "-upvote:#{@user.name}")
        end
      end

      should "show private upvotes to the voter themselves" do
        as(@user) do
          assert_tag_match([@upvote.post], "upvote:#{@user.name}")
          assert_tag_match([@downvote.post], "-upvote:#{@user.name}")
        end
      end
    end

    context "for the downvote:<user> metatag" do
      setup do
        @user = create(:user, enable_private_favorites: true)
        @upvote = create(:post_vote, user: @user, score: 1)
        @downvote = create(:post_vote, user: @user, score: -1)
      end

      should "not show downvotes to other users" do
        as(User.anonymous) do
          assert_tag_match([], "downvote:#{@user.name}")
          assert_tag_match([@downvote.post, @upvote.post], "-downvote:#{@user.name}")
        end
      end

      should "show downvotes to admins" do
        as(create(:admin_user)) do
          assert_tag_match([@downvote.post], "downvote:#{@user.name}")
          assert_tag_match([@upvote.post], "-downvote:#{@user.name}")
        end
      end

      should "show downvotes to the voter themselves" do
        as(@user) do
          assert_tag_match([@downvote.post], "downvote:#{@user.name}")
          assert_tag_match([@upvote.post], "-downvote:#{@user.name}")
        end
      end
    end

    should "return posts for a upvote:<user>, downvote:<user> metatag" do
      CurrentUser.scoped(create(:mod_user)) do
        upvoted   = create(:post, tag_string: "upvote:self")
        downvoted = create(:post, tag_string: "downvote:self")

        assert_tag_match([upvoted], "upvote:#{CurrentUser.user.name}")
        assert_tag_match([downvoted], "downvote:#{CurrentUser.user.name}")
        assert_tag_match([], "upvote:nobody upvote:#{CurrentUser.user.name}")
        assert_tag_match([], "downvote:nobody downvote:#{CurrentUser.user.name}")

        assert_tag_match([downvoted], "-upvote:#{CurrentUser.user.name}")
        assert_tag_match([upvoted], "-downvote:#{CurrentUser.user.name}")
      end
    end

    should "return posts for a disapproved:<type> metatag" do
      disapprover = create(:user)
      pending     = create(:post, is_pending: true)
      disapproved = create(:post, is_pending: true)
      disapproval = create(:post_disapproval, user: disapprover, post: disapproved, reason: "disinterest")

      as(disapprover) do
        assert_tag_match([disapproved], "disapproved:#{disapprover.name}")
        assert_tag_match([disapproved], "disapproved:#{disapprover.name.upcase}")
        assert_tag_match([disapproved], "disapproved:disinterest")
        assert_tag_match([disapproved], "disapproved:DISINTEREST")
        assert_tag_match([], "disapproved:breaks_rules")
        assert_tag_match([], "disapproved:breaks_rules disapproved:disinterest")

        assert_tag_match([pending], "-disapproved:#{disapprover.name}")
        assert_tag_match([pending], "-disapproved:disinterest")
        assert_tag_match([disapproved, pending], "-disapproved:breaks_rules")
      end

      as(create(:user)) do
        assert_tag_match([], "disapproved:#{disapprover.name}")
      end

      as(create(:mod_user)) do
        assert_tag_match([disapproved], "disapproved:#{disapprover.name}")
      end
    end

    should "return posts for an exif:<value> metatag" do
      jpg = create(:post_with_file, filename: "test.jpg")
      gif = create(:post_with_file, filename: "test.gif")
      png = create(:post_with_file, filename: "test.png")

      assert_tag_match([jpg], "exif:File:ColorComponents")
      assert_tag_match([jpg], "exif:File:ColorComponents=3")
      assert_tag_match([gif], "exif:GIF:GIFVersion")
      assert_tag_match([gif], "exif:GIF:GIFVersion=89a")
      assert_tag_match([png], "exif:PNG:ColorType")
      assert_tag_match([png], "exif:PNG:ColorType=RGB")
      assert_tag_match([], "exif:DNE")
    end

    should "return posts for the random:<N> metatag" do
      post = create(:post)

      assert_tag_match([], "random:0")
      assert_tag_match([post], "random:1")
      assert_tag_match([post], "random:1000")
    end

    should "return posts ordered by a particular attribute" do
      posts = (1..2).map do |n|
        tags = ["tagme", "gentag1 gentag2 artist:arttag char:chartag copy:copytag"]

        p = create(
          :post,
          score: n,
          up_score: n,
          down_score: -n,
          md5: n.to_s,
          fav_count: n,
          file_size: 1.megabyte * n,
          # posts[0] is portrait, posts[1] is landscape. posts[1].mpixels > posts[0].mpixels.
          image_height: 100 * n * n,
          image_width: 100 * (3 - n) * n,
          tag_string: tags[n - 1]
        )

        u = create(:user, created_at: 2.weeks.ago)
        create(:artist_commentary, post: p)
        create(:comment, post: p, creator: u, do_not_bump_post: false)
        create(:note, post: p)
        p
      end

      create(:note, post: posts.second)

      assert_tag_match(posts.reverse, "order:id_desc")
      assert_tag_match(posts.reverse, "order:score")
      assert_tag_match(posts.reverse, "order:upvotes")
      assert_tag_match(posts.reverse, "order:downvotes")
      assert_tag_match(posts.reverse, "order:favcount")
      assert_tag_match(posts.reverse, "order:change")
      assert_tag_match(posts.reverse, "order:comment")
      assert_tag_match(posts.reverse, "order:comment_bumped")
      assert_tag_match(posts.reverse, "order:note")
      assert_tag_match(posts.reverse, "order:artcomm")
      assert_tag_match(posts.reverse, "order:mpixels")
      assert_tag_match(posts.reverse, "order:portrait")
      assert_tag_match(posts.reverse, "order:filesize")
      assert_tag_match(posts.reverse, "order:tagcount")
      assert_tag_match(posts.reverse, "order:gentags")
      assert_tag_match(posts.reverse, "order:arttags")
      assert_tag_match(posts.reverse, "order:chartags")
      assert_tag_match(posts.reverse, "order:copytags")
      assert_tag_match(posts.reverse, "order:rank")
      assert_tag_match(posts.reverse, "order:note_count")
      assert_tag_match(posts.reverse, "order:note_count_desc")
      assert_tag_match(posts.reverse, "order:notes")
      assert_tag_match(posts.reverse, "order:notes_desc")
      assert_tag_match(posts.reverse, "order:md5")
      assert_tag_match(posts.reverse, "order:md5_desc")
      assert_tag_match(posts.reverse, "order:duration_desc")

      assert_tag_match(posts, "order:id_asc")
      assert_tag_match(posts, "order:score_asc")
      assert_tag_match(posts, "order:upvotes_asc")
      assert_tag_match(posts, "order:downvotes_asc")
      assert_tag_match(posts, "order:favcount_asc")
      assert_tag_match(posts, "order:change_asc")
      assert_tag_match(posts, "order:comment_asc")
      assert_tag_match(posts, "order:comment_bumped_asc")
      assert_tag_match(posts, "order:artcomm_asc")
      assert_tag_match(posts, "order:note_asc")
      assert_tag_match(posts, "order:mpixels_asc")
      assert_tag_match(posts, "order:landscape")
      assert_tag_match(posts, "order:filesize_asc")
      assert_tag_match(posts, "order:tagcount_asc")
      assert_tag_match(posts, "order:gentags_asc")
      assert_tag_match(posts, "order:arttags_asc")
      assert_tag_match(posts, "order:chartags_asc")
      assert_tag_match(posts, "order:copytags_asc")
      assert_tag_match(posts, "order:note_count_asc")
      assert_tag_match(posts, "order:notes_asc")
      assert_tag_match(posts, "order:md5_asc")
      assert_tag_match(posts, "order:duration_asc")

      # ordering is unpredictable so can't be tested.
      assert_tag_match([posts.first], "id:#{posts.first.id} order:none")
    end

    should "return posts for order:comment_bumped" do
      post1 = create(:post)
      post2 = create(:post)
      post3 = create(:post)
      user = create(:gold_user)

      as(user) do
        comment1 = create(:comment, creator: user, post: post1)
        comment2 = create(:comment, creator: user, post: post2, do_not_bump_post: true)
        comment3 = create(:comment, creator: user, post: post3)
      end

      assert_tag_match([post3, post1, post2], "order:comment_bumped")
      assert_tag_match([post2, post1, post3], "order:comment_bumped_asc")
    end

    should "return posts for order:custom" do
      p1 = create(:post)
      p2 = create(:post)
      p3 = create(:post)

      as(create(:gold_user)) do
        assert_tag_match([p2, p1, p3], "id:#{p2.id},#{p1.id},#{p3.id} order:custom")
        assert_tag_match([p1], "id:#{p1.id} order:custom")
        assert_tag_match([], "id:>0 order:custom")
        assert_tag_match([], "id:1,2 id:2,3 order:custom")
        assert_tag_match([], "order:custom")
      end
    end

    should "return posts for order:random" do
      post = create(:post)

      assert_tag_match([post], "order:random")
    end

    should "return posts for a filesize search" do
      post = create(:post, file_size: 1.megabyte)

      assert_tag_match([post], "filesize:1mb")
      assert_tag_match([post], "filesize:1000kb")
      assert_tag_match([post], "filesize:1048576b")
    end

    should "return posts for an unaliased:<tag> search" do
      post = create(:post, tag_string: "gray_eyes fav:self")
      create(:tag_alias, antecedent_name: "gray_eyes", consequent_name: "grey_eyes")

      assert_tag_match([], "gray_eyes")
      assert_tag_match([post], "-gray_eyes")

      assert_tag_match([post], "unaliased:gray_eyes")
      assert_tag_match([], "-unaliased:gray_eyes")

      assert_tag_match([], "unaliased:fav:#{CurrentUser.id}")
    end

    should "not perform fuzzy matching for an exact filesize search" do
      post = create(:post, file_size: 1.megabyte)

      assert_tag_match([], "filesize:1048000b")
      assert_tag_match([], "filesize:1048000")
    end

    should "resolve aliases to the actual tag" do
      create(:tag_alias, antecedent_name: "kitten", consequent_name: "cat")
      post1 = create(:post, tag_string: "cat")
      post2 = create(:post, tag_string: "dog")

      assert_tag_match([post1], "kitten")
      assert_tag_match([post2], "-kitten")
    end

    should "resolve abbreviations to the actual tag" do
      tag1 = create(:tag, name: "hair_ribbon", post_count: 300_000)
      tag2 = create(:tag, name: "hakurei_reimu", post_count: 50_000)
      post1 = create(:post, tag_string: "hair_ribbon")
      post2 = create(:post, tag_string: "hakurei_reimu")

      assert_tag_match([post1], "/hr")
      assert_tag_match([post2], "-/hr")
    end

    should "fail if the search exceeds the tag limit" do
      post1 = create(:post, rating: "s")

      assert_raise(PostQuery::TagLimitError) do
        PostQuery.search("a b c user:bob fav:bob pool:disgustingly_adorable", tag_limit: 5)
      end
    end

    should "not count free tags against the user's search limit" do
      post1 = create(:post, tag_string: "aaa bbb rating:s")

      assert_tag_match([post1], "aaa bbb rating:s")
      assert_tag_match([post1], "aaa bbb status:active")
      assert_tag_match([post1], "aaa bbb limit:20")
      assert_tag_match([post1], "aaa bbb filesize:<100mb width:<10000 height:<10000 limit:20")
    end

    should "succeed for exclusive tag searches with no other tag" do
      post1 = create(:post, rating: "s", tag_string: "aaa")
      assert_tag_match([], "-aaa")
    end

    should "succeed for exclusive tag searches combined with a metatag" do
      post1 = create(:post, rating: "s", tag_string: "aaa")
      assert_tag_match([], "-aaa id:>0")
      assert_tag_match([], "-a* rating:s")
    end

    should "succeed for nested OR clauses" do
      post1 = create(:post, tag_string: "a c")
      post2 = create(:post, tag_string: "b d")
      post3 = create(:post, tag_string: "a")
      post4 = create(:post, tag_string: "d")

      assert_tag_match([post3, post2, post1], "~a ~b")
      assert_tag_match([post3, post2, post1], "a or b")

      assert_tag_match([post4, post2, post1], "~c ~d")
      assert_tag_match([post4, post2, post1], "c or d")

      assert_tag_match([post2, post1], "(a or b) (c or d)")
      assert_tag_match([post2, post1], "(~a ~b) (~c ~d)")

      assert_tag_match([post2, post1], "a c or b d")
      assert_tag_match([post2, post1], "(a c) or (b d)")
      assert_tag_match([post2, post1], "~(a c) or ~(b d)")
    end

    should "succeed for metatags combined with OR clauses" do
      post1 = create(:post, rating: "s")
      post2 = create(:post, rating: "q")
      post3 = create(:post, rating: "e")

      assert_tag_match([post2, post1], "~rating:s ~rating:q")
      assert_tag_match([post3, post2, post1], "~rating:s ~rating:q ~rating:e")

      assert_tag_match([post2, post1], "rating:s or rating:q")
      assert_tag_match([post3, post2, post1], "rating:s or rating:q or rating:e")

      assert_tag_match([post2, post1], "id:#{post1.id} or rating:q")
    end

    should "work on a relation with pre-existing scopes" do
      post1 = create(:post, rating: "g", is_pending: true, tag_string: ["1girl"])
      post2 = create(:post, rating: "s", is_flagged: true, tag_string: ["1boy"])
      create(:post_disapproval, post: post2, reason: "poor_quality")

      assert_tag_match([post1], "1girl", relation: Post.pending)
      assert_tag_match([post1], "1girl", relation: Post.in_modqueue)
      assert_tag_match([post1], "1boy", relation: Post.in_modqueue)
      assert_tag_match([post2, post1], "comments:0", relation: Post.in_modqueue)
      assert_tag_match([post2, post1], "comments:0 notes:0", relation: Post.in_modqueue)

      assert_tag_match([post2], "-1girl", relation: Post.in_modqueue)
      assert_tag_match([post2], "disapproved:poor_quality", relation: Post.in_modqueue)

      assert_tag_match([], "rating:g", relation: Post.where(rating: "e"))
      assert_tag_match([], "id:#{post1.id}", relation: Post.where(id: 0))
      assert_tag_match([], "order:artcomm", relation: Post.in_modqueue)
    end

    should "not allow conflicting order metatags" do
      assert_search_error("order:score ordfav:a")
      assert_search_error("order:score ordfavgroup:a")
      assert_search_error("order:score ordpool:a")
      assert_search_error("ordfav:a ordpool:b")
    end

    should "not allow metatags that can't be used more than once" do
      assert_search_error("order:score order:favcount")
      assert_search_error("ordfav:a ordfav:b")
      assert_search_error("ordfavgroup:a ordfavgroup:b")
      assert_search_error("ordpool:a ordpool:b")
      assert_search_error("limit:5 limit:10")
      assert_search_error("random:5 random:10")
    end

    should "not allow non-negatable metatags to be negated" do
      assert_search_error("-order:score")
      assert_search_error("-ordfav:a")
      assert_search_error("-ordfavgroup:a")
      assert_search_error("-ordpool:a")
      assert_search_error("-limit:20")
      assert_search_error("-random:20")
    end

    should "not allow non-OR'able metatags to be OR'd" do
      assert_search_error("a or order:score")
      assert_search_error("a or ordfav:a")
      assert_search_error("a or ordfavgroup:a")
      assert_search_error("a or ordpool:a")
      assert_search_error("a or limit:20")
      assert_search_error("a or random:20")
    end
  end

  context "#fast_count" do
    setup do
      create(:tag, name: "grey_skirt", post_count: 100)
      create(:tag_alias, antecedent_name: "gray_skirt", consequent_name: "grey_skirt")
      create(:post, tag_string: "aaa", score: 42)
    end

    context "for a single basic tag" do
      should "return the post_count from the tags table" do
        assert_fast_count(100, "grey_skirt")
      end
    end

    context "for a aliased tag" do
      should "return the post count of the consequent tag" do
        assert_fast_count(100, "gray_skirt")
      end
    end

    context "for a single metatag" do
      should "return the correct cached count" do
        build(:tag, name: "score:42", post_count: -100).save(validate: false)
        Cache.put("pfc:score:42", 100)
        assert_fast_count(100, "score:42")
      end

      should "return the correct cached count for a pool:<id> search" do
        pool = create(:pool, post_ids: [1, 2, 3])

        build(:tag, name: "pool:#{pool.id}", post_count: -100).save(validate: false)
        Cache.put("pfc:pool:1234", 100)

        assert_fast_count(3, "pool:#{pool.id}")
        assert_fast_count(3, "pool:#{pool.name}")
        assert_fast_count(3, "ordpool:#{pool.id}")
        assert_fast_count(3, "ordpool:#{pool.name}")

        assert_fast_count(Post.count, "-pool:#{pool.id}")
        assert_fast_count(Post.count, "-pool:#{pool.name}")
      end

      should "return the correct favorite count for a fav:<name> search" do
        fav = create(:favorite)
        User.where(id: fav.user).update_all(favorite_count: 42) # XXX favorite_count is readonly; update it this way to bypass the readonly check.

        assert_fast_count(42, "fav:#{fav.user.name}")
        assert_fast_count(42, "ordfav:#{fav.user.name}")

        assert_fast_count(1, "-fav:#{fav.user.name}")
      end

      should "return the correct favorite count for a fav:<name> search for a user with private favorites" do
        fav = create(:private_favorite)

        assert_fast_count(0, "fav:#{fav.user.name}")
        assert_fast_count(0, "ordfav:#{fav.user.name}")
      end

      should "return the correct favorite count for a fav:<name> search for a nonexistent user" do
        assert_fast_count(0, "fav:doesnotexist")
        assert_fast_count(0, "ordfav:doesnotexist")
      end
    end

    context "for a multi-tag search" do
      should "return the cached count, if it exists" do
        Cache.put("pfc:aaa score:42", 100)
        assert_fast_count(100, "aaa score:42")
      end

      should "return the true count, if not cached" do
        assert_fast_count(1, "aaa score:42")
      end
    end

    context "a blank search" do
      should "should execute a search" do
        assert_fast_count(1, "", {}, { estimate_count: false })
        assert_nothing_raised { PostQuery.new("").fast_count(estimate_count: true) }
      end

      should "return 0 for a nonexisting tag" do
        assert_fast_count(0, "bbb")
      end

      context "in safe mode" do
        should "work for a blank search" do
          assert_fast_count(0, "", { safe_mode: true }, { estimate_count: false })
          assert_nothing_raised { PostQuery.new("", safe_mode: true).fast_count(estimate_count: true) }
        end

        should "work for a nil search" do
          assert_fast_count(0, nil, { safe_mode: true }, { estimate_count: false })
          assert_nothing_raised { PostQuery.new("", safe_mode: true).fast_count(estimate_count: true) }
        end

        should "not fail for a two tag search by a member" do
          post1 = create(:post, tag_string: "aaa bbb rating:g")
          post2 = create(:post, tag_string: "aaa bbb rating:e")

          assert_fast_count(1, "aaa bbb", { safe_mode: true })
        end
      end
    end

    context "for a user-dependent metatag" do
      should "cache the count separately for different users" do
        @user = create(:user, enable_private_favorites: true)
        @post = as(@user) { create(:post, tag_string: "fav:#{@user.name}") }
        @comment = create(:comment, post: @post, creator: @user, is_deleted: true)

        assert_equal(1, PostQuery.new("fav:#{@user.name}", current_user: @user).fast_count)
        assert_equal(0, PostQuery.new("fav:#{@user.name}").fast_count)

        assert_equal(1, PostQuery.new("commenter:#{@user.name}", current_user: @user).fast_count)
        assert_equal(0, PostQuery.new("commenter:#{@user.name}").fast_count)

        assert_equal(1, PostQuery.new("comm:#{@user.name}", current_user: @user).fast_count)
        assert_equal(0, PostQuery.new("comm:#{@user.name}").fast_count)
      end
    end
  end
end
