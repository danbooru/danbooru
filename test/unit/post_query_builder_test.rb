require 'test_helper'

class PostQueryBuilderTest < ActiveSupport::TestCase
  def assert_tag_match(posts, query)
    assert_equal(posts.map(&:id), Post.user_tag_match(query).pluck(:id))
  end

  def assert_fast_count(count, query, query_options = {}, fast_count_options = {})
    assert_equal(count, PostQueryBuilder.new(query, **query_options).normalized_query.fast_count(**fast_count_options))
  end

  def assert_parse_equals(expected, query)
    assert_equal(expected, PostQueryBuilder.new(query).split_query)

    # parsing, serializing, then parsing again should produce the same result.
    assert_equal(PostQueryBuilder.new(query).to_s, PostQueryBuilder.new(PostQueryBuilder.new(query).to_s).to_s)
  end

  setup do
    CurrentUser.user = create(:user)
    CurrentUser.ip_addr = "127.0.0.1"
  end

  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
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

    should "return posts for the ( tag" do
      post1 = create(:post, tag_string: "(")
      post2 = create(:post, tag_string: "aaa bbb")

      assert_tag_match([post1], "(")
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

    should "ignore invalid operator syntax" do
      assert_nothing_raised do
        assert_tag_match([], "-")
        assert_tag_match([], "~")
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

      assert_tag_match([posts[1], posts[0]], "-id:>#{posts[1].id}")
      assert_tag_match([posts[2], posts[1]], "-id:<#{posts[1].id}")
      assert_tag_match([posts[0]], "-id:>=#{posts[1].id}")
      assert_tag_match([posts[2]], "-id:<=#{posts[1].id}")
      assert_tag_match([posts[0]], "-id:#{posts[1].id}..#{posts[2].id}")
      assert_tag_match([posts[0]], "-id:#{posts[1].id},#{posts[2].id}")

      assert_tag_match([], "id:#{posts[0].id} id:#{posts[2].id}")
      assert_tag_match([posts[0]], "-id:#{posts[1].id} -id:#{posts[2].id}")
      assert_tag_match([posts[1]], "id:>#{posts[0].id} id:<#{posts[2].id}")
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
      assert_tag_match([], "fav:dne")

      assert_tag_match([post3, post2], "-fav:#{user1.name}")
      assert_tag_match([post3, post2, post1], "-fav:dne")

      as(user3) do
        assert_tag_match([post3], "fav:#{user3.name}")
        assert_tag_match([post2, post1], "-fav:#{user3.name}")
      end
    end

    should "return posts for the ordfav:<name> metatag" do
      post1 = create(:post, tag_string: "fav:#{CurrentUser.name}")
      post2 = create(:post, tag_string: "fav:#{CurrentUser.name}")

      assert_tag_match([post2, post1], "ordfav:#{CurrentUser.name}")
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

    should "return posts for the ordpool:<name> metatag for a series pool containing duplicate posts" do
      posts = create_list(:post, 2)
      pool = create(:pool, name: "test", category: "series", post_ids: [posts[0].id, posts[1].id, posts[1].id])

      assert_tag_match([posts[0], posts[1], posts[1]], "ordpool:test")
    end

    should "return posts for the parent:<N> metatag" do
      parent = create(:post)
      child = create(:post, tag_string: "parent:#{parent.id}")

      assert_tag_match([parent], "parent:none")
      assert_tag_match([child], "-parent:none")

      assert_tag_match([child], "parent:any")
      assert_tag_match([parent], "-parent:any")

      assert_tag_match([child, parent], "parent:#{parent.id}")
      assert_tag_match([child], "parent:#{child.id}")

      assert_tag_match([], "-parent:#{parent.id}")
      assert_tag_match([], "-parent:#{child.id}")

      assert_tag_match([child], "parent:#{parent.id} parent:#{child.id}")

      assert_tag_match([child], "child:none")
      assert_tag_match([parent], "child:any")
      assert_tag_match([], "child:garbage")

      assert_tag_match([parent], "-child:none")
      assert_tag_match([child], "-child:any")
      assert_tag_match([child, parent], "-child:garbage")
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
      favgroup3 = create(:favorite_group, creator: create(:user), post_ids: [post3.id], is_public: false)

      assert_tag_match([post1], "favgroup:#{favgroup1.id}")
      assert_tag_match([post2], "favgroup:#{favgroup2.name}")
      assert_tag_match([], "favgroup:#{favgroup3.name}")
      assert_tag_match([], "favgroup:dne")

      assert_tag_match([post3, post2], "-favgroup:#{favgroup1.id}")
      assert_tag_match([post3, post1], "-favgroup:#{favgroup2.name}")
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
      end
    end

    should "return posts for the ordfavgroup:<name> metatag" do
      post1 = create(:post)
      post2 = create(:post)
      post3 = create(:post)

      favgroup1 = create(:favorite_group, creator: CurrentUser.user, post_ids: [post1.id, post2.id])
      favgroup2 = create(:favorite_group, creator: create(:user), post_ids: [post2.id, post3.id], is_public: false)

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
      assert_tag_match([posts[1]], "-approver:#{users[0].name}")
      assert_tag_match([posts[1], posts[0]], "approver:any")
      assert_tag_match([posts[2]], "approver:none")
      assert_tag_match([posts[2]], "approver:NONE")
      assert_tag_match([], "approver:does_not_exist")
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
      post = create(:post, created_at: Time.parse("2017-01-01 12:00"))

      assert_tag_match([post], "date:2017-01-01")
      assert_tag_match([], "-date:2017-01-01")
    end

    should "return posts for the age:<n> metatag" do
      post = create(:post)

      assert_tag_match([post], "age:<60")
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
      assert_tag_match([post], "age:0s..1m")
      assert_tag_match([post], "age:1m..0s")

      assert_tag_match([], "age:>1y")
      assert_tag_match([], "age:>=1y")
      assert_tag_match([], "age:1y..2y")
      assert_tag_match([], "age:>1y age:<1y")

      assert_tag_match([post], "-age:>1y")
      assert_tag_match([], "-age:<1y")
    end

    should "return posts for the ratio:<x:y> metatag" do
      post = create(:post, image_width: 1000, image_height: 500)

      assert_tag_match([post], "ratio:2:1")
      assert_tag_match([post], "ratio:2.0")
      assert_tag_match([], "-ratio:2.0")
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
      flagged = create(:post, is_flagged: true)
      pending = create(:post, is_pending: true)
      disapproved = create(:post, is_pending: true)
      appealed = create(:post, is_deleted: true)

      create(:post_flag, post: flagged, creator: create(:user, created_at: 2.weeks.ago))
      create(:post_appeal, post: appealed)
      create(:post_disapproval, user: CurrentUser.user, post: disapproved, reason: "disinterest")

      assert_tag_match([appealed, pending, flagged], "status:unmoderated")
      assert_tag_match([disapproved], "-status:unmoderated")
    end

    should "respect the 'Deleted post filter' option when using the status: metatag" do
      deleted = create(:post, is_deleted: true, is_banned: true)
      undeleted = create(:post, is_banned: true)

      CurrentUser.hide_deleted_posts = true
      assert_tag_match([undeleted], "status:banned")
      assert_tag_match([undeleted], "status:active")
      assert_tag_match([deleted], "status:deleted")
      assert_tag_match([undeleted, deleted], "status:any")
      assert_tag_match([undeleted, deleted], "status:all")
      assert_tag_match([deleted], "status:banned status:deleted")

      assert_tag_match([], "-status:banned")
      assert_tag_match([deleted], "-status:active")
      assert_tag_match([undeleted], "-status:deleted")
      #assert_tag_match([deleted], "-status:any") # XXX Broken
      #assert_tag_match([deleted], "-status:all")

      CurrentUser.hide_deleted_posts = false
      assert_tag_match([undeleted, deleted], "status:banned")
      assert_tag_match([undeleted], "status:active")
      assert_tag_match([deleted], "status:deleted")
      assert_tag_match([undeleted, deleted], "status:any")
      assert_tag_match([undeleted, deleted], "status:all")

      assert_fast_count(2, "status:banned")
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
      post1 = create(:post, md5: "abcd")
      post2 = create(:post)

      assert_tag_match([post1], "md5:abcd")
      assert_tag_match([post1], "md5:ABCD")
      assert_tag_match([post1], "md5:123,abcd")
      assert_tag_match([], "md5:abcd md5:xyz")

      assert_tag_match([post2], "-md5:abcd")
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

    should "return posts for a pixiv_id:none search" do
      post = create(:post)
      assert_tag_match([post], "pixiv_id:none")
    end

    should "return posts for the search: metatag" do
      @post1 = create(:post, tag_string: "aaa")
      @post2 = create(:post, tag_string: "bbb")
      create(:saved_search, query: "aaa", labels: ["zzz"], user: CurrentUser.user)
      create(:saved_search, query: "bbb", user: CurrentUser.user)

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
      assert_tag_match([], "rating:s rating:q")

      assert_tag_match(all - [s], "-rating:s")
      assert_tag_match(all - [q], "-rating:q")
      assert_tag_match(all - [e], "-rating:e")
    end

    should "return posts for a locked:<rating|note|status> metatag" do
      rating_locked = create(:post, is_rating_locked: true)
      note_locked   = create(:post, is_note_locked: true)
      status_locked = create(:post, is_status_locked: true)
      all = [status_locked, note_locked, rating_locked]

      assert_tag_match([rating_locked], "locked:rating")
      assert_tag_match([note_locked], "locked:note")
      assert_tag_match([status_locked], "locked:status")

      assert_tag_match(all - [rating_locked], "-locked:rating")
      assert_tag_match(all - [note_locked], "-locked:note")
      assert_tag_match(all - [status_locked], "-locked:status")

      assert_tag_match([rating_locked], "locked:RATING")
      assert_tag_match([status_locked], "-locked:rating -locked:note")
      assert_tag_match([], "locked:rating locked:note")

      assert_tag_match([], "locked:garbage")
      assert_tag_match(all, "-locked:garbage")
    end

    should "return posts for a upvote:<user>, downvote:<user> metatag" do
      CurrentUser.scoped(create(:mod_user)) do
        upvoted   = create(:post, tag_string: "upvote:self")
        downvoted = create(:post, tag_string: "downvote:self")

        assert_tag_match([upvoted], "upvote:#{CurrentUser.name}")
        assert_tag_match([downvoted], "downvote:#{CurrentUser.name}")
        assert_tag_match([], "upvote:nobody upvote:#{CurrentUser.name}")
        assert_tag_match([], "downvote:nobody downvote:#{CurrentUser.name}")

        assert_tag_match([downvoted], "-upvote:#{CurrentUser.name}")
        assert_tag_match([upvoted], "-downvote:#{CurrentUser.name}")
      end
    end

    should "return posts for a disapproved:<type> metatag" do
      CurrentUser.scoped(create(:mod_user)) do
        pending     = create(:post, is_pending: true)
        disapproved = create(:post, is_pending: true)
        disapproval = create(:post_disapproval, user: CurrentUser.user, post: disapproved, reason: "disinterest")

        assert_tag_match([disapproved], "disapproved:#{CurrentUser.name}")
        assert_tag_match([disapproved], "disapproved:#{CurrentUser.name.upcase}")
        assert_tag_match([disapproved], "disapproved:disinterest")
        assert_tag_match([disapproved], "disapproved:DISINTEREST")
        assert_tag_match([], "disapproved:breaks_rules")
        assert_tag_match([], "disapproved:breaks_rules disapproved:disinterest")

        assert_tag_match([pending], "-disapproved:#{CurrentUser.name}")
        assert_tag_match([pending], "-disapproved:disinterest")
        assert_tag_match([disapproved, pending], "-disapproved:breaks_rules")
      end
    end

    should "return posts ordered by a particular attribute" do
      posts = (1..2).map do |n|
        tags = ["tagme", "gentag1 gentag2 artist:arttag char:chartag copy:copytag"]

        p = create(
          :post,
          score: n,
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

      assert_tag_match(posts, "order:id_asc")
      assert_tag_match(posts, "order:score_asc")
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
        assert_tag_match([], "id:#{p1.id} order:custom")
        assert_tag_match([], "id:>0 order:custom")
        assert_tag_match([], "id:1,2 id:2,3 order:custom")
        assert_tag_match([], "order:custom")
      end
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

    should "fail for more than 6 tags" do
      post1 = create(:post, rating: "s")

      assert_raise(::Post::SearchError) do
        Post.user_tag_match("a b c rating:s width:10 height:10 user:bob")
      end
    end

    should "not count free tags against the user's search limit" do
      post1 = create(:post, tag_string: "aaa bbb rating:s")

      assert_tag_match([post1], "aaa bbb rating:s")
      assert_tag_match([post1], "aaa bbb status:active")
      assert_tag_match([post1], "aaa bbb limit:20")
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
  end

  context "Parsing:" do
    should "split a query" do
      assert_equal(%w(aaa bbb), PostQueryBuilder.new("aaa bbb").split_query)
    end

    should "not strip out valid characters when scanning" do
      assert_equal(%w(aaa bbb), PostQueryBuilder.new("aaa bbb").split_query)
      assert_equal(%w(favgroup:yondemasu_yo,_azazel-san. pool:ichigo_100%), PostQueryBuilder.new("favgroup:yondemasu_yo,_azazel-san. pool:ichigo_100%").split_query)
    end

    should "parse single tags correctly" do
      assert_equal(true, PostQueryBuilder.new("foo").is_single_tag?)
      assert_equal(true, PostQueryBuilder.new("-foo").is_single_tag?)
      assert_equal(true, PostQueryBuilder.new("~foo").is_single_tag?)
      assert_equal(true, PostQueryBuilder.new("foo*").is_single_tag?)
      assert_equal(false, PostQueryBuilder.new("fav:1234").is_single_tag?)
      assert_equal(false, PostQueryBuilder.new("pool:1234").is_single_tag?)
      assert_equal(false, PostQueryBuilder.new('source:"foo bar baz"').is_single_tag?)
      assert_equal(false, PostQueryBuilder.new("foo bar").is_single_tag?)
    end

    should "parse simple tags correctly" do
      assert_equal(true, PostQueryBuilder.new("foo").is_simple_tag?)
      assert_equal(false, PostQueryBuilder.new("-foo").is_simple_tag?)
      assert_equal(false, PostQueryBuilder.new("~foo").is_simple_tag?)
      assert_equal(false, PostQueryBuilder.new("foo*").is_simple_tag?)
      assert_equal(false, PostQueryBuilder.new("fav:1234").is_simple_tag?)
      assert_equal(false, PostQueryBuilder.new("FAV:1234").is_simple_tag?)
      assert_equal(false, PostQueryBuilder.new("pool:1234").is_simple_tag?)
      assert_equal(false, PostQueryBuilder.new('source:"foo bar baz"').is_simple_tag?)
      assert_equal(false, PostQueryBuilder.new("foo bar").is_simple_tag?)
    end

    should "parse quoted metatags correctly" do
      assert_parse_equals(%w[status:"active" source:"https"], %q(status:'active' source:'https'))
      assert_parse_equals(%w[source:"https" status:"active"], %q(source:'https' status:'active'))
      assert_parse_equals(%w[status:"active" source:"https"], %q(status:"active" source:'https'))
      assert_parse_equals(%w[status:"active" source:"https"], %q(status:'active' source:"https"))
      assert_parse_equals(%w[status:"active" source:https], %q(status:'active' source:https))
      assert_parse_equals(%w[status:active source:"https"], %q(status:active source:'https'))

      assert_parse_equals(%w[limit:"5" status:"active" source:"x"], %q(limit:"5" status:"active" source:"x"))
      assert_parse_equals(%w[source:"" limit:"1" status:"deleted"], %q(source:"" limit:'1' status:'deleted'))

      assert_parse_equals(['source:"bar baz"', 'don\'t_say_"lazy"'], %q(source:"bar baz" don't_say_"lazy"))
      assert_parse_equals(['source:"bar baz"', 'don\'t_say_"lazy"'], %q(source:"bar baz" don't_say_"lazy"))
      assert_parse_equals(['source:"bar baz"', 'don\'t_say_"lazy"'], %q(source:'bar baz' don't_say_"lazy"))

      assert_parse_equals([%q(source:"foo")], %q(source:"\f\o\o"))
      assert_parse_equals([%q(source:"foo")], %q(source:'\f\o\o'))
      assert_parse_equals([%q(source:foo\bar)], %q(source:foo\bar))
      assert_parse_equals([%q(source:"foo)], %q(source:"foo))
      assert_parse_equals([%q(source:'foo)], %q(source:'foo))
      assert_parse_equals([%q(source:"foo bar")], %q(source:foo\ bar))
      assert_parse_equals([%q(source:"\"foo bar\\\\")], %q(source:"foo\ bar\\))

      assert_parse_equals(['source:"don\'t_say_\\"lazy\\""', 'don\'t_say_"lazy"'], %q(source:"don't_say_\"lazy\"" don't_say_"lazy"))
      assert_parse_equals(['source:"don\'t_say_\\"lazy\\""', 'don\'t_say_"lazy"'], %q(source:'don\'t_say_"lazy"' don't_say_"lazy"))
    end
  end

  context "The normalized_query method" do
    should "work" do
      create(:tag_alias, antecedent_name: "gray", consequent_name: "grey")

      assert_equal("foo", PostQueryBuilder.new("foo").normalized_query.to_s)
      assert_equal("foo", PostQueryBuilder.new(" foo ").normalized_query.to_s)
      assert_equal("foo", PostQueryBuilder.new("FOO").normalized_query.to_s)
      assert_equal("foo", PostQueryBuilder.new("foo foo").normalized_query.to_s)
      assert_equal("grey", PostQueryBuilder.new("gray").normalized_query.to_s)
      assert_equal("aaa bbb", PostQueryBuilder.new("bbb aaa").normalized_query.to_s)
      assert_equal("-aaa bbb", PostQueryBuilder.new("bbb -aaa").normalized_query.to_s)
      assert_equal("~aaa ~bbb", PostQueryBuilder.new("~bbb ~aaa").normalized_query.to_s)
      assert_equal("commentary:true bbb", PostQueryBuilder.new("bbb commentary:true").normalized_query.to_s)
      assert_equal('commentary:"true" bbb', PostQueryBuilder.new("bbb commentary:'true'").normalized_query.to_s)
      assert_equal('-commentary:true bbb', PostQueryBuilder.new("bbb -commentary:true").normalized_query.to_s)
      assert_equal('-commentary:"true" bbb', PostQueryBuilder.new("bbb -commentary:'true'").normalized_query.to_s)
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
        PostQueryBuilder.new("score:42").set_cached_count(100)
        assert_fast_count(100, "score:42")
      end

      should "return the correct cached count for a pool:<id> search" do
        build(:tag, name: "pool:1234", post_count: -100).save(validate: false)
        PostQueryBuilder.new("pool:1234").set_cached_count(100)
        assert_fast_count(100, "pool:1234")
      end
    end

    context "for a multi-tag search" do
      should "return the cached count, if it exists" do
        PostQueryBuilder.new("score:42 aaa").set_cached_count(100)
        assert_fast_count(100, "aaa score:42")
      end

      should "return the true count, if not cached" do
        assert_fast_count(1, "aaa score:42")
      end

      should "set the expiration time" do
        Cache.expects(:put).with(PostQueryBuilder.new("score:42 aaa").count_cache_key, 1, 180)
        assert_fast_count(1, "aaa score:42")
      end

      should "work with the hide_deleted_posts option turned on" do
        create(:post, tag_string: "aaa", score: 42, is_deleted: true)
        assert_fast_count(1, "aaa score:42", { hide_deleted_posts: true })
        assert_fast_count(2, "aaa score:42", { hide_deleted_posts: false })
      end
    end

    context "a blank search" do
      should "should execute a search" do
        assert_fast_count(1, "", {}, { estimate_count: false })
        assert_nothing_raised { PostQueryBuilder.new("").normalized_query.fast_count(estimate_count: true) }
      end

      should "return 0 for a nonexisting tag" do
        assert_fast_count(0, "bbb")
      end

      context "in safe mode" do
        should "work for a blank search" do
          assert_fast_count(0, "", { safe_mode: true }, { estimate_count: false })
          assert_nothing_raised { PostQueryBuilder.new("", safe_mode: true).normalized_query.fast_count(estimate_count: true) }
        end

        should "work for a nil search" do
          assert_fast_count(0, nil, { safe_mode: true }, { estimate_count: false })
          assert_nothing_raised { PostQueryBuilder.new("", safe_mode: true).normalized_query.fast_count(estimate_count: true) }
        end

        should "not fail for a two tag search by a member" do
          post1 = create(:post, tag_string: "aaa bbb rating:s")
          post2 = create(:post, tag_string: "aaa bbb rating:e")

          assert_fast_count(1, "aaa bbb", { safe_mode: true })
        end
      end
    end

    context "for a user-dependent metatag" do
      should "cache the count separately for different users" do
        @user = create(:user, enable_private_favorites: true)
        @post = as(@user) { create(:post, tag_string: "fav:#{@user.name}") }

        assert_equal(1, PostQueryBuilder.new("fav:#{@user.name}", @user).fast_count)
        assert_equal(0, PostQueryBuilder.new("fav:#{@user.name}").fast_count)
      end
    end
  end
end
