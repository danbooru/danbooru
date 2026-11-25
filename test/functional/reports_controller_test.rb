require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  context "The reports controller" do
    setup do
      @user = create(:user)
    end

    context "index action" do
      should "render for anonymous users" do
        get reports_path

        assert_response :success
      end
    end

    context "show action" do
      should "render the access denied page for anonymous users" do
        get report_path("posts")

        assert_response 403
      end

      should "work for every report and group" do
        {
          "posts" => %w[uploader uploader.level approver rating is_deleted],
          "post_approvals" => %w[user],
          "post_appeals" => %w[creator status],
          "post_flags" => %w[status],
          "post_replacements" => %w[creator],
          "post_votes" => %w[],
          "media_assets" => %w[file_ext status],
          "pools" => %w[category is_deleted],
          "comments" => %w[creator do_not_bump_post is_deleted is_sticky],
          "comment_votes" => %w[],
          "forum_posts" => %w[creator is_deleted],
          "bulk_update_requests" => %w[user approver status],
          "tag_aliases" => %w[status approver],
          "tag_implications" => %w[status approver],
          "artist_versions" => %w[updater],
          "artist_commentary_versions" => %w[updater],
          "note_versions" => %w[updater],
          "wiki_page_versions" => %w[updater],
          "mod_actions" => %w[creator category subject_type],
          "bans" => %w[banner duration],
          "users" => %w[level],
        }.each do |report, groups|
          [nil, *groups].each do |group|
            get_auth report_path(report, search: { group: group }.compact), @user
            assert_response :success, "#{report} grouped by #{group.inspect}"

            get_auth report_path(report, search: { group: group, period: "day" }.compact), @user
            assert_response :success, "#{report} grouped by #{group.inspect} over time"
          end
        end
      end

      context "posts report" do
        setup do
          @post = create(:post)
        end

        should "work" do
          get_auth report_path("posts"), @user

          assert_response :success
        end

        should "work with the period param" do
          get_auth report_path("posts", search: { period: "month" }), @user

          assert_response :success
        end

        should "work with the group param" do
          get_auth report_path("posts", search: { group: "uploader" }), @user

          assert_response :success
        end

        should "work with the period and group params" do
          get_auth report_path("posts", search: { period: "month", group: "uploader" }), @user

          assert_response :success
        end

        should "work with the group param when the dataset is empty" do
          get_auth report_path("posts", search: { tags: "does_not_exist", group: "uploader" }), @user

          assert_response :success
        end

        should "fail for oversized group limits" do
          create(:post)

          get_auth report_path("posts", search: { group: "uploader", group_limit: 9_999_999, period: "second", from: 10.years.ago.to_date.iso8601, to: Time.zone.now.to_date.iso8601 }), @user

          assert_response 422
          assert_select "p", text: "Error: The group limit can't be more than 200."
        end

        should "fail when the date range is too long for the period" do
          get_auth report_path("posts", search: { period: "day", from: 10.years.ago.to_date.iso8601, to: Time.zone.now.to_date.iso8601 }), @user

          assert_response 422
          assert_select "p", text: "Error: The date range can't be longer than 2000 days. Choose a longer period or a shorter date range."
        end

        should "ignore params that aren't strings" do
          get_auth report_path("posts", search: { period: ["day"] }), @user
          assert_response :success

          get_auth report_path("posts", search: { group: ["a"] }), @user
          assert_response :success

          get_auth report_path("posts", search: { group_limit: ["1"] }), @user
          assert_response :success

          get_auth report_path("posts", search: { columns: { a: 1 }}), @user
          assert_response :success

          get_auth report_path("posts", search: { mode: ["a"] }), @user
          assert_response :success
        end

        should "fail for an invalid date" do
          get_auth report_path("posts", search: { from: "abc" }), @user
          assert_response 422
          assert_select "p", text: "Error: abc is not a valid date"

          get_auth report_path("posts", search: { period: "day", to: "2020-13-45" }), @user
          assert_response 422
          assert_select "p", text: "Error: 2020-13-45 is not a valid date"

          get_auth report_path("posts", search: { period: "day", from: "1.month.ago" }), @user
          assert_response 422
          assert_select "p", text: "Error: 1.month.ago is not a valid date"

          get_auth report_path("posts", search: { from: "1" * 200 }), @user
          assert_response 422
          assert_select "p", text: "Error: #{"1" * 97}... is not a valid date"
        end

        should "work without any search params" do
          travel_to(Time.zone.local(2026, 3, 31, 23, 30)) do
            get_auth report_path("posts"), @user

            assert_response :success
            assert_select "#search_from[value=?]", "2026-02-28"
            assert_select "#search_to[value=?]", "2026-03-31"
          end
        end

        should "show the parsed dates in the search form" do
          get_auth report_path("posts", search: { from: "2020-1-2 12:00", to: "2020-2-3", tags: "touhou", mode: "table" }), @user

          assert_response :success
          assert_select "#search_from[value=?]", "2020-01-02"
          assert_select "#search_to[value=?]", "2020-02-03"
          assert_select "#search_tags[value=?]", "touhou"
          assert_select "#search_mode[value=?]", "table"
        end

        should "not show non-string params in the search form" do
          get_auth report_path("posts", search: { tags: ["touhou"], mode: ["table"], group: ["uploader"] }), @user

          assert_response :success
          assert_select "#search_tags:not([value])"
          assert_select "#search_mode:not([value])"

          get_auth report_path("posts", search: { from: ["2020-01-01"], to: { a: 1 }}), @user
          assert_response :success
        end

        should "work with a date and time" do
          get_auth report_path("posts", search: { from: "2020-1-1 12:00", to: "2020-01-31", period: "day" }), @user
          assert_response :success
        end

        should "fail for an invalid period" do
          get_auth report_path("posts", search: { period: "decade" }), @user

          assert_response 422
          assert_select "p", text: "Error: The period must be one of: second, minute, hour, day, week, month, year."
        end

        should "work when filtering by a nested association" do
          get_auth report_path("posts", search: { uploader: { name: @post.uploader.name }}), @user

          assert_response :success
        end

        should "work when grouping by an associated attribute" do
          get_auth report_path("posts", search: { group: "uploader.level" }), @user

          assert_response :success
        end

        should "work when grouping by an associated attribute over time" do
          get_auth report_path("posts", search: { group: "uploader.level", period: "month" }), @user

          assert_response :success
        end

        should "show an All Time link that fills in the from field with post #1's creation date" do
          Post.delete_all
          post1 = create(:post, id: 1)

          get_auth report_path("posts"), @user

          assert_response :success
          assert_select "a", text: "All Time" do |links|
            assert_includes links.first["x-on:click.prevent"], post1.created_at.to_date.iso8601
          end
        end

        should "not show an All Time link when no posts exist" do
          Post.delete_all

          get_auth report_path("posts"), @user

          assert_response :success
          assert_select "a", text: "All Time", count: 0
        end
      end

      context "post approvals report" do
        should "work" do
          create(:post_approval)
          get_auth report_path("post_approvals"), @user

          assert_response :success
        end
      end

      context "post appeals report" do
        should "work" do
          create(:post_appeal)
          get_auth report_path("post_appeals"), @user

          assert_response :success
        end
      end

      context "post flags report" do
        should "work" do
          create(:post_flag)
          get_auth report_path("post_flags"), @user

          assert_response :success
        end
      end

      context "post replacements report" do
        should "work" do
          create(:post_replacement)
          get_auth report_path("post_replacements"), @user

          assert_response :success
        end
      end

      context "post votes report" do
        should "work" do
          create(:post_vote)
          get_auth report_path("post_votes"), @user

          assert_response :success
        end
      end

      context "media assets report" do
        should "work" do
          create(:media_asset)
          get_auth report_path("media_assets"), @user

          assert_response :success
        end
      end

      context "pools report" do
        should "work" do
          as(create(:user)) { create(:pool) }
          get_auth report_path("pools"), @user

          assert_response :success
        end
      end

      context "comments report" do
        should "work" do
          as(create(:user)) { create(:comment) }
          get_auth report_path("comments"), @user

          assert_response :success
        end
      end

      context "comment votes report" do
        should "work" do
          as(create(:user)) { create(:comment_vote) }
          get_auth report_path("comment_votes"), @user

          assert_response :success
        end
      end

      context "forum posts report" do
        should "work" do
          as(create(:user)) { create(:forum_post) }
          get_auth report_path("forum_posts"), @user

          assert_response :success
        end
      end

      context "bulk update requests report" do
        should "work" do
          create(:bulk_update_request)
          get_auth report_path("bulk_update_requests"), @user

          assert_response :success
        end
      end

      context "tag aliases report" do
        should "work" do
          create(:tag_alias)
          get_auth report_path("tag_aliases"), @user

          assert_response :success
        end
      end

      context "artist versions report" do
        should "work" do
          create(:artist)
          get_auth report_path("artist_versions"), @user

          assert_response :success
        end
      end

      context "artist commentary versions report" do
        should "work" do
          create(:artist_commentary)
          get_auth report_path("artist_commentary_versions"), @user

          assert_response :success
        end
      end

      context "note versions report" do
        should "work" do
          as(create(:user)) { create(:note) }
          get_auth report_path("note_versions"), @user

          assert_response :success
        end
      end

      context "wiki page versions report" do
        should "work" do
          create(:wiki_page)
          get_auth report_path("wiki_page_versions"), @user

          assert_response :success
        end
      end

      context "mod actions report" do
        should "work" do
          create(:mod_action)
          get_auth report_path("mod_actions"), @user

          assert_response :success
        end
      end

      context "bans report" do
        should "work" do
          create(:ban)
          get_auth report_path("bans"), @user

          assert_response :success
        end
      end

      context "visibility" do
        should "not count mod-only mod actions for non-moderators" do
          create(:mod_action, category: "email_address_update", description: "secret@example.com")

          get_auth report_path("mod_actions", format: :json, search: { category: "email_address_update", description_like: "*secret*" }), @user
          assert_response :success
          assert_equal([0], response.parsed_body.pluck("mod_actions"))

          get_auth report_path("mod_actions", format: :json, search: { category: "email_address_update", description_like: "*secret*" }), create(:moderator_user)
          assert_response :success
          assert_equal([1], response.parsed_body.pluck("mod_actions"))
        end

        should "not count private post votes" do
          vote = create(:post_vote, score: -1)

          get_auth report_path("post_votes", format: :json, search: { user_id: vote.user_id, post_id: vote.post_id, score: -1 }), @user
          assert_response :success
          assert_equal([0], response.parsed_body.pluck("votes"))
        end

        should "not count other users' comment votes" do
          as(create(:user)) { create(:comment_vote) }

          get_auth report_path("comment_votes", format: :json), @user
          assert_response :success
          assert_equal([0], response.parsed_body.pluck("votes"))
        end

        should "not count forum posts in restricted topics" do
          as(create(:user)) { create(:forum_post, topic: create(:mod_up_forum_topic), body: "secret") }

          get_auth report_path("forum_posts", format: :json, search: { body_matches: "secret" }), @user
          assert_response :success
          assert_equal([0], response.parsed_body.pluck("forum_posts"))
        end

        should "not reveal the creator of deleted comments when grouping by creator" do
          author = create(:user)
          comment = create(:comment, creator: author, is_deleted: true)

          get_auth report_path("comments", format: :json, search: { id: comment.id, group: "creator" }), @user
          assert_response :success
          assert_equal([], response.parsed_body)

          get_auth report_path("comments", format: :json, search: { id: comment.id, group: "creator", period: "day" }), @user
          assert_response :success
          assert_equal([], response.parsed_body)

          get_auth report_path("comments", format: :json, search: { id: comment.id, group: "creator" }), author
          assert_response :success
          assert_equal([author.pretty_name], response.parsed_body.pluck("creator"))

          get_auth report_path("comments", format: :json, search: { id: comment.id, group: "creator" }), create(:moderator_user)
          assert_response :success
          assert_equal([author.pretty_name], response.parsed_body.pluck("creator"))
        end

        should "not count deleted comments by other users in the commenters column" do
          author1 = create(:user)
          author2 = create(:user)
          deleted1 = create(:comment, creator: author1, is_deleted: true)
          deleted2 = create(:comment, creator: author2, is_deleted: true)

          get_auth report_path("comments", format: :json, search: { id: "#{deleted1.id},#{deleted2.id}", columns: "commenters" }), @user
          assert_response :success
          assert_equal([0], response.parsed_body.pluck("commenters"))

          get_auth report_path("comments", format: :json, search: { id: "#{deleted1.id},#{deleted2.id}", columns: "commenters" }), author1
          assert_response :success
          assert_equal([1], response.parsed_body.pluck("commenters"))

          get_auth report_path("comments", format: :json, search: { id: "#{deleted1.id},#{deleted2.id}", columns: "commenters" }), create(:moderator_user)
          assert_response :success
          assert_equal([2], response.parsed_body.pluck("commenters"))
        end

        should "not reveal hidden attributes of deleted comments when grouping by them" do
          comment = create(:comment, is_deleted: true, is_sticky: true, do_not_bump_post: true)

          get_auth report_path("comments", format: :json, search: { id: comment.id, group: "is_sticky" }), @user
          assert_response :success
          assert_equal([], response.parsed_body)

          get_auth report_path("comments", format: :json, search: { id: comment.id, group: "do_not_bump_post" }), @user
          assert_response :success
          assert_equal([], response.parsed_body)

          get_auth report_path("comments", format: :json, search: { id: comment.id, group: "is_sticky" }), create(:moderator_user)
          assert_response :success
          assert_equal([true], response.parsed_body.pluck("is_sticky"))
        end

        should "not let members compare flaggers in the post flags report" do
          flagger = create(:user)
          flag1 = create(:post_flag, creator: flagger)
          flag2 = create(:post_flag, creator: flagger)
          own_flag = create(:post_flag, creator: @user)

          get_auth report_path("post_flags", format: :json, search: { id: "#{flag1.id},#{flag2.id}", columns: "flaggers" }), @user
          assert_response :success
          assert_equal([0], response.parsed_body.pluck("flaggers"))

          get_auth report_path("post_flags", format: :json, search: { id: "#{own_flag.id},#{flag1.id}", columns: "flaggers" }), @user
          assert_response :success
          assert_equal([1], response.parsed_body.pluck("flaggers"))

          get_auth report_path("post_flags", format: :json, search: { id: "#{flag1.id},#{flag2.id}", columns: "flags" }), @user
          assert_response :success
          assert_equal([2], response.parsed_body.pluck("flags"))
        end

        should "not let moderators compare flaggers on their own uploads in the post flags report" do
          mod = create(:moderator_user)
          flagger = create(:user)
          other_flagger = create(:user)
          own_post = create(:post, uploader: mod)
          other_post = create(:post)
          flag_on_own_post = create(:post_flag, post: own_post, creator: flagger)
          flag_on_other_post = create(:post_flag, post: other_post, creator: other_flagger)

          get_auth report_path("post_flags", format: :json, search: { id: "#{flag_on_own_post.id},#{flag_on_other_post.id}", columns: "flaggers" }), mod
          assert_response :success
          assert_equal([1], response.parsed_body.pluck("flaggers"))

          get_auth report_path("post_flags", format: :json, search: { id: flag_on_own_post.id, columns: "flaggers" }), mod
          assert_response :success
          assert_equal([0], response.parsed_body.pluck("flaggers"))
        end
      end

      context "users report" do
        should "work" do
          create(:user)
          get_auth report_path("users"), @user

          assert_response :success
        end
      end

      context "unknown report" do
        should "work" do
          get_auth report_path("unknown"), @user

          assert_response 404
        end
      end
    end
  end
end
