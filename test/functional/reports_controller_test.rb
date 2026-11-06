require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  context "The reports controller" do
    context "show action" do
      context "posts report" do
        setup do
          @post = create(:post)
        end

        should "work" do
          get report_path("posts")

          assert_response :success
        end

        should "work with the period param" do
          get report_path("posts", search: { period: "month" })

          assert_response :success
        end

        should "work with the group param" do
          get report_path("posts", search: { group: "uploader" })

          assert_response :success
        end

        should "work with the period and group params" do
          get report_path("posts", search: { period: "month", group: "uploader" })

          assert_response :success
        end

        should "work with the group param when the dataset is empty" do
          get report_path("posts", search: { tags: "does_not_exist", group: "uploader" })

          assert_response :success
        end

        should "fail for oversized group limits" do
          create(:post)

          get report_path("posts", search: { group: "uploader", group_limit: 9_999_999, period: "second", from: 10.years.ago.to_date.iso8601, to: Time.zone.now.to_date.iso8601 })

          assert_response 500
        end

        should "fail for too many timeseries buckets" do
          create(:post)

          get report_path("posts", search: { period: "day", from: 10.years.ago.to_date.iso8601, to: Time.zone.now.to_date.iso8601 })

          assert_response 500
        end

        should "work when filtering by a nested association" do
          get report_path("posts", search: { uploader: { name: @post.uploader.name }})

          assert_response :success
        end

        should "work when grouping by an associated attribute" do
          get report_path("posts", search: { group: "uploader.level" })

          assert_response :success
        end

        should "work when grouping by an associated attribute over time" do
          get report_path("posts", search: { group: "uploader.level", period: "month" })

          assert_response :success
        end

        should "show an All Time link that fills in the from field with post #1's creation date" do
          Post.delete_all
          post1 = create(:post, id: 1)

          get report_path("posts")

          assert_response :success
          assert_select "a", text: "All Time" do |links|
            assert_includes links.first["x-on:click.prevent"], post1.created_at.to_date.iso8601
          end
        end

        should "not show an All Time link when no posts exist" do
          Post.delete_all

          get report_path("posts")

          assert_response :success
          assert_select "a", text: "All Time", count: 0
        end
      end

      context "post approvals report" do
        should "work" do
          create(:post_approval)
          get report_path("post_approvals")

          assert_response :success
        end
      end

      context "post appeals report" do
        should "work" do
          create(:post_appeal)
          get report_path("post_appeals")

          assert_response :success
        end
      end

      context "post flags report" do
        should "work" do
          create(:post_flag)
          get report_path("post_flags")

          assert_response :success
        end
      end

      context "post replacements report" do
        should "work" do
          create(:post_replacement)
          get report_path("post_replacements")

          assert_response :success
        end
      end

      context "post votes report" do
        should "work" do
          create(:post_vote)
          get report_path("post_votes")

          assert_response :success
        end
      end

      context "media assets report" do
        should "work" do
          create(:media_asset)
          get report_path("media_assets")

          assert_response :success
        end
      end

      context "pools report" do
        should "work" do
          as(create(:user)) { create(:pool) }
          get report_path("pools")

          assert_response :success
        end
      end

      context "comments report" do
        should "work" do
          as(create(:user)) { create(:comment) }
          get report_path("comments")

          assert_response :success
        end
      end

      context "comment votes report" do
        should "work" do
          as(create(:user)) { create(:comment_vote) }
          get report_path("comment_votes")

          assert_response :success
        end
      end

      context "forum posts report" do
        should "work" do
          as(create(:user)) { create(:forum_post) }
          get report_path("forum_posts")

          assert_response :success
        end
      end

      context "bulk update requests report" do
        should "work" do
          create(:bulk_update_request)
          get report_path("bulk_update_requests")

          assert_response :success
        end
      end

      context "tag aliases report" do
        should "work" do
          create(:tag_alias)
          get report_path("tag_aliases")

          assert_response :success
        end
      end

      context "artist versions report" do
        should "work" do
          create(:artist)
          get report_path("artist_versions")

          assert_response :success
        end
      end

      context "artist commentary versions report" do
        should "work" do
          create(:artist_commentary)
          get report_path("artist_commentary_versions")

          assert_response :success
        end
      end

      context "note versions report" do
        should "work" do
          as(create(:user)) { create(:note) }
          get report_path("note_versions")

          assert_response :success
        end
      end

      context "wiki page versions report" do
        should "work" do
          create(:wiki_page)
          get report_path("wiki_page_versions")

          assert_response :success
        end
      end

      context "mod actions report" do
        should "work" do
          create(:mod_action)
          get report_path("mod_actions")

          assert_response :success
        end
      end

      context "bans report" do
        should "work" do
          create(:ban)
          get report_path("bans")

          assert_response :success
        end
      end

      context "visibility" do
        should "not count mod-only mod actions for non-moderators" do
          create(:mod_action, category: "email_address_update", description: "secret@example.com")

          get report_path("mod_actions", format: :json, search: { category: "email_address_update", description_like: "*secret*" })
          assert_response :success
          assert_equal([0], response.parsed_body.pluck("mod_actions"))

          get_auth report_path("mod_actions", format: :json, search: { category: "email_address_update", description_like: "*secret*" }), create(:moderator_user)
          assert_response :success
          assert_equal([1], response.parsed_body.pluck("mod_actions"))
        end

        should "not count private post votes" do
          vote = create(:post_vote, score: -1)

          get report_path("post_votes", format: :json, search: { user_id: vote.user_id, post_id: vote.post_id, score: -1 })
          assert_response :success
          assert_equal([0], response.parsed_body.pluck("votes"))
        end

        should "not count comment votes for anonymous users" do
          as(create(:user)) { create(:comment_vote) }

          get report_path("comment_votes", format: :json)
          assert_response :success
          assert_equal([0], response.parsed_body.pluck("votes"))
        end

        should "not count forum posts in restricted topics" do
          as(create(:user)) { create(:forum_post, topic: create(:mod_up_forum_topic), body: "secret") }

          get report_path("forum_posts", format: :json, search: { body_matches: "secret" })
          assert_response :success
          assert_equal([0], response.parsed_body.pluck("forum_posts"))
        end
      end

      context "users report" do
        should "work" do
          create(:user)
          get report_path("users")

          assert_response :success
        end
      end

      context "unknown report" do
        should "work" do
          get report_path("unknown")

          assert_response 404
        end
      end
    end
  end
end
