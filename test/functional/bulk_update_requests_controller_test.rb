require "test_helper"

class BulkUpdateRequestsControllerTest < ActionDispatch::IntegrationTest
  # Approve the BUR through the controller, and assert that it was approved and processed.
  #
  # @param bur [BulkUpdateRequest, String] the BUR, or a script to create a new BUR from
  def assert_approve_succeeds(bur, approver)
    bur = create(:bulk_update_request, script: bur) if bur.is_a?(String)
    perform_enqueued_jobs { post_auth approve_bulk_update_request_path(bur), approver }

    assert_redirected_to bulk_update_request_path(bur)
    assert_equal("approved", bur.reload.status)
    assert_equal(approver, bur.approver)
    bur
  end

  # Try to approve the BUR through the controller, and assert that it was refused and left pending.
  #
  # @param bur [BulkUpdateRequest, String] the BUR, or a script to create a new BUR from
  # @param error [String, nil] the expected error notice. If given, the request is made as JS so the notice can be checked.
  def assert_approve_fails(bur, approver, error = nil)
    bur = create(:bulk_update_request, script: bur) if bur.is_a?(String)
    format = error.present? ? :js : nil
    perform_enqueued_jobs { post_auth approve_bulk_update_request_path(bur, format: format), approver }

    if error.present?
      assert_js_notice(:error, error)
    else
      assert_response 403
    end
    assert_equal("pending", bur.reload.status)
    bur
  end

  context "BulkUpdateRequestsController" do
    setup do
      @user = create(:user)
      @builder = create(:builder_user)
      @mod = create(:mod_user)
      @admin = create(:admin_user)
      as(@admin) { @forum_topic = create(:forum_topic, category_id: 0) }
      as(@user) { @bulk_update_request = create(:bulk_update_request, user: @user, forum_topic: @forum_topic, script: "create alias aaa -> bbb") }
    end

    context "#new" do
      should "render" do
        get_auth new_bulk_update_request_path, @user
        assert_response :success
      end
    end

    context "#edit" do
      should "render" do
        get_auth edit_bulk_update_request_path(@bulk_update_request), @user
        assert_response :success
      end
    end

    context "#create" do
      should "succeed" do
        assert_difference("BulkUpdateRequest.count", 1) do
          post_auth bulk_update_requests_path, @user, params: { bulk_update_request: attributes_for(:bulk_update_request) }
          assert_response :redirect
        end
      end

      should "fail for an invalid script" do
        assert_difference("BulkUpdateRequest.count", 0) do
          post_auth bulk_update_requests_path, @user, params: { bulk_update_request: attributes_for(:bulk_update_request).merge(script: "create alis gray -> grey") }
          assert_response :success
        end
      end

      should "fail for a blank reason" do
        assert_difference("BulkUpdateRequest.count", 0) do
          post_auth bulk_update_requests_path, @user, params: { bulk_update_request: attributes_for(:bulk_update_request).merge(reason: "") }
          assert_response :success
        end
      end

      should "show the forum post's error when the reason mentions too many users" do
        reason = 11.times.map { |i| "@user_#{i}" }.join(" ")

        assert_no_difference(["BulkUpdateRequest.count", "ForumTopic.count", "ForumPost.count"]) do
          post_auth bulk_update_requests_path, @user, params: { bulk_update_request: attributes_for(:bulk_update_request).merge(reason: reason) }
        end

        assert_response :success
        assert_select "#notice", text: /can't mention more than 10 users/
        assert_select "#notice", text: /is invalid/, count: 0
      end

      should "show the forum post's error when the reason mentions too many users in an existing topic" do
        reason = 11.times.map { |i| "@user_#{i}" }.join(" ")

        assert_no_difference(["BulkUpdateRequest.count", "ForumPost.count"]) do
          post_auth bulk_update_requests_path, @user, params: { bulk_update_request: attributes_for(:bulk_update_request).merge(reason: reason, forum_topic_id: @forum_topic.id) }
        end

        assert_response :success
        assert_select "#notice", text: /can't mention more than 10 users/
        assert_select "#notice", text: /is invalid/, count: 0
      end

      should "show the forum post's error when the user's mention limit is exhausted" do
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
        RateLimit.create!(action: "mentions", key: @user.cache_key, points: 0, limited: false)

        assert_no_difference(["BulkUpdateRequest.count", "Dmail.count"]) do
          post_auth bulk_update_requests_path, @user, params: { bulk_update_request: attributes_for(:bulk_update_request).merge(reason: "hi @#{@mod.name}") }
        end

        assert_response :success
        assert_select "#notice", text: /mentioned too many users recently/
      end
    end

    context "#update" do
      should "allow admins to update other people's requests" do
        put_auth bulk_update_request_path(@bulk_update_request.id), create(:admin_user), params: { bulk_update_request: { script: "create alias zzz -> 222" }}
        assert_redirected_to bulk_update_request_path(@bulk_update_request)
        assert_equal("create alias zzz -> 222", @bulk_update_request.reload.script)
      end

      should "not allow builders to update other people's requests" do
        put_auth bulk_update_request_path(@bulk_update_request.id), create(:builder_user), params: { bulk_update_request: { script: "create alias zzz -> 222" }}
        assert_response 403
        assert_equal("create alias aaa -> bbb", @bulk_update_request.reload.script)
      end

      should "not allow members to update other people's requests" do
        put_auth bulk_update_request_path(@bulk_update_request.id), create(:user), params: { bulk_update_request: { script: "create alias zzz -> 222" }}
        assert_response 403
        assert_equal("create alias aaa -> bbb", @bulk_update_request.reload.script)
      end

      should "allow users to update their own request when it has <5 votes" do
        4.times { create(:forum_post_vote, forum_post: @bulk_update_request.forum_post, creator: build(:user), score: 1) }
        put_auth bulk_update_request_path(@bulk_update_request.id), @user, params: { bulk_update_request: { script: "create alias zzz -> 222" }}
        assert_redirected_to bulk_update_request_path(@bulk_update_request)
        assert_equal("create alias zzz -> 222", @bulk_update_request.reload.script)
      end

      should "not allow users to update their own request when it has 5 votes or more" do
        5.times { create(:forum_post_vote, forum_post: @bulk_update_request.forum_post, creator: build(:user), score: 1) }
        put_auth bulk_update_request_path(@bulk_update_request.id), @user, params: { bulk_update_request: { script: "create alias zzz -> 222" }}
        assert_response 403
        assert_equal("create alias aaa -> bbb", @bulk_update_request.reload.script)
      end

      should "allow users to reject their own request when it has 5 votes or more" do
        5.times { create(:forum_post_vote, forum_post: @bulk_update_request.forum_post, creator: build(:user), score: 1) }
        delete_auth bulk_update_request_path(@bulk_update_request.id), @user
        assert_redirected_to bulk_update_request_path(@bulk_update_request)
        assert_equal("rejected", @bulk_update_request.reload.status)
      end

      should "not allow users to update their own request if it's approved while updating it" do
        stale_bur = BulkUpdateRequest.find(@bulk_update_request.id)
        @bulk_update_request.update!(status: "processing", approver: @admin)
        BulkUpdateRequest.stubs(:find).with(@bulk_update_request.id.to_s).returns(stale_bur)

        put_auth bulk_update_request_path(@bulk_update_request.id), @user, params: { bulk_update_request: { script: "create alias zzz -> 222" }}
        assert_response 403
        assert_equal("create alias aaa -> bbb", @bulk_update_request.reload.script)
      end

      should "fail for an invalid script" do
        put_auth bulk_update_request_path(@bulk_update_request.id), @user, params: { bulk_update_request: { script: "create alis gray -> grey" }}
        assert_response :success
        assert_equal("create alias aaa -> bbb", @bulk_update_request.reload.script)
      end
    end

    context "#index" do
      setup do
        @other_bur = create(:bulk_update_request, user: @builder, script: "create alias cirno -> 9")
        @rejected_bur = create(:bulk_update_request, status: "rejected")
        @approved_bur = create(:bulk_update_request, status: "approved", approver: @admin)
      end

      should "render" do
        get bulk_update_requests_path
        assert_response :success
      end

      should respond_to_search.with { [@approved_bur, @rejected_bur, @other_bur, @bulk_update_request] }
      should respond_to_search(order: "id_desc").with { [@approved_bur, @rejected_bur, @other_bur, @bulk_update_request] }
      should respond_to_search(status: "pending").with { [@other_bur, @bulk_update_request] }
      should respond_to_search(script_matches: "cirno -> 9").with { @other_bur }
      should respond_to_search(tags_include_any: "cirno").with { @other_bur }

      context "using includes" do
        should respond_to_search(forum_topic_id: -> { @forum_topic.id }).with { @bulk_update_request }
        should respond_to_search(forum_topic: { category_id: 0 }).with { @bulk_update_request }
        should respond_to_search(user_id: -> { @user.id }).with { @bulk_update_request }
        should respond_to_search(user: { level: User::Levels::BUILDER }).with { @other_bur }
        should respond_to_search(has_approver: "true").with { @approved_bur }
        should respond_to_search(has_approver: "false").with { [@rejected_bur, @other_bur, @bulk_update_request] }
      end

      should "not show a BUR in a private topic to users who can't see the topic" do
        admin_topic = create(:forum_topic, title: "Secret admin topic", min_level: User::Levels::ADMIN)
        admin_bur = as(@admin) { create(:bulk_update_request, user: @admin, forum_topic: admin_topic, script: "create alias secret_a -> secret_b") }
        create(:forum_post_vote, forum_post: admin_bur.forum_post, creator: @admin, score: 1)

        get bulk_update_requests_path(search: { id: admin_bur.id }), as: :json
        assert_response :success
        assert_equal([], response.parsed_body)

        get_auth bulk_update_requests_path(search: { id: admin_bur.id }), @user
        assert_response :success
        assert_select "#bulk-update-request-#{admin_bur.id}", count: 0
        assert_not_includes(response.body, "Secret admin topic")

        get_auth bulk_update_requests_path(search: { id: admin_bur.id }), @mod
        assert_response :success
        assert_select "#bulk-update-request-#{admin_bur.id}", count: 0
        assert_not_includes(response.body, "Secret admin topic")

        get_auth bulk_update_requests_path(search: { id: admin_bur.id }), @admin
        assert_response :success
        assert_select "#bulk-update-request-#{admin_bur.id}", count: 1
        assert_includes(response.body, "Secret admin topic")
        assert_includes(response.body, "+1 /")
      end

      should "not show a BUR in a deleted topic to users who can't see deleted posts" do
        deleted_topic = create(:forum_topic, title: "Deleted topic title")
        deleted_bur = as(@mod) { create(:bulk_update_request, user: @mod, forum_topic: deleted_topic, script: "create alias del_a -> del_b") }
        create(:forum_post_vote, forum_post: deleted_bur.forum_post, creator: @mod, score: 1)
        deleted_topic.soft_delete!(updater: @mod)

        get bulk_update_requests_path(search: { id: deleted_bur.id })
        assert_response :success
        assert_select "#bulk-update-request-#{deleted_bur.id}", count: 0
        assert_not_includes(response.body, "Deleted topic title")
        assert_not_includes(response.body, "+1 /")

        get bulk_update_requests_path(search: { id: deleted_bur.id }), as: :json
        assert_response :success
        assert_equal([], response.parsed_body)

        get_auth bulk_update_requests_path(search: { id: deleted_bur.id }), @mod
        assert_response :success
        assert_select "#bulk-update-request-#{deleted_bur.id}", count: 1
        assert_includes(response.body, "Deleted topic title")
        assert_includes(response.body, "+1 /")
      end

      should "not allow searching by score for a BUR in a private or deleted topic" do
        deleted_topic = create(:forum_topic, title: "Deleted topic title")
        deleted_bur = as(@mod) { create(:bulk_update_request, user: @mod, forum_topic: deleted_topic, script: "create alias del_a -> del_b") }
        create(:forum_post_vote, forum_post: deleted_bur.forum_post, creator: @mod, score: 1)
        deleted_topic.soft_delete!(updater: @mod)

        get bulk_update_requests_path(search: { id: deleted_bur.id, score: 1 }), as: :json
        assert_response :success
        assert_equal([], response.parsed_body)

        get_auth bulk_update_requests_path(search: { id: deleted_bur.id, score: 1 }), @mod, as: :json
        assert_response :success
        assert_equal([deleted_bur.id], response.parsed_body.pluck("id"))
      end
    end

    context "#show" do
      should "render" do
        get bulk_update_request_path(@bulk_update_request)
        assert_response :success
      end

      should "not allow viewing a BUR in a private topic for users who can't see the topic" do
        private_topic = create(:mod_up_forum_topic, title: "Secret mod topic")
        private_bur = as(@mod) { create(:bulk_update_request, user: @mod, forum_topic: private_topic, script: "create alias secret_a -> secret_b") }
        voter = create(:moderator_user, name: "secret_voter")
        create(:forum_post_vote, forum_post: private_bur.forum_post, creator: voter, score: 1)

        get bulk_update_request_path(private_bur)
        assert_response 403

        get_auth bulk_update_request_path(private_bur), @user
        assert_response 403

        get_auth bulk_update_request_path(private_bur), @mod
        assert_response :success
        assert_includes(response.body, "Secret mod topic")
        assert_includes(response.body, "secret_voter")
        assert_select ".forum-post-votes", count: 1
      end

      should "not allow viewing a BUR in a deleted topic for users who can't see deleted posts" do
        deleted_topic = create(:forum_topic, title: "Deleted topic title")
        deleted_bur = as(@mod) { create(:bulk_update_request, user: @mod, forum_topic: deleted_topic, script: "create alias del_a -> del_b") }
        voter = create(:moderator_user, name: "deleted_topic_voter")
        create(:forum_post_vote, forum_post: deleted_bur.forum_post, creator: voter, score: 1)
        deleted_topic.soft_delete!(updater: @mod)

        get bulk_update_request_path(deleted_bur)
        assert_response 403

        get_auth bulk_update_request_path(deleted_bur), @user
        assert_response 403

        get_auth bulk_update_request_path(deleted_bur), @mod
        assert_response :success
        assert_includes(response.body, "Deleted topic title")
        assert_includes(response.body, "deleted_topic_voter")
        assert_select ".forum-post-votes", count: 1
      end
    end

    context "#destroy" do
      context "for the creator" do
        should "succeed" do
          delete_auth bulk_update_request_path(@bulk_update_request), @user
          assert_response :redirect
          assert_equal("rejected", @bulk_update_request.reload.status)
        end
      end

      context "for another Builder" do
        should "fail" do
          assert_difference("BulkUpdateRequest.count", 0) do
            delete_auth bulk_update_request_path(@bulk_update_request), create(:builder_user)
            assert_response 403
          end
        end
      end

      context "for an admin" do
        should "succeed" do
          delete_auth bulk_update_request_path(@bulk_update_request), @admin
          assert_response :redirect
          assert_equal("rejected", @bulk_update_request.reload.status)
        end
      end

      context "for a moderator" do
        should "succeed for a BUR they can approve" do
          delete_auth bulk_update_request_path(@bulk_update_request), @mod
          assert_response :redirect
          assert_equal("rejected", @bulk_update_request.reload.status)
        end

        should "fail for a BUR that requires an admin" do
          create(:tag, name: "big_tag_a", post_count: 10_000)
          create(:tag, name: "big_tag_b", post_count: 10_000)
          @bulk_update_request.update!(script: "alias big_tag_a -> big_tag_b")

          delete_auth bulk_update_request_path(@bulk_update_request), @mod
          assert_response 403
          assert_equal("pending", @bulk_update_request.reload.status)
        end
      end

      context "for a builder who can approve the BUR" do
        should "fail" do
          create(:tag, name: "artist_a", category: Tag.categories.artist, post_count: 10)
          @bulk_update_request.update!(script: "alias artist_a -> artist_b")

          delete_auth bulk_update_request_path(@bulk_update_request), @builder
          assert_response 403
          assert_equal("pending", @bulk_update_request.reload.status)
        end
      end
    end

    context "#approve" do
      context "for a member" do
        should "fail" do
          assert_approve_fails(@bulk_update_request, @user)
        end
      end

      context "for a builder" do
        should "succeed for a small artist move" do
          create(:tag, name: "artist1a", category: Tag.categories.artist, post_count: 10)
          create(:tag, name: "artist1b", category: Tag.categories.general, post_count: 0)
          create(:tag, name: "artist2a", category: Tag.categories.artist, post_count: 20)

          assert_approve_succeeds("rename artist1a -> artist1b\ncreate alias artist2a -> artist2b", @builder)
          assert_equal(true, TagAlias.exists?(antecedent_name: "artist2a", consequent_name: "artist2b", status: "active"))
        end

        should "fail when approving a BUR with a mix of allowed and disallowed lines" do
          create(:tag, name: "artist1a", category: Tag.categories.artist, post_count: 10)
          create(:tag, name: "artist1b", category: Tag.categories.general, post_count: 0)
          create(:tag, name: "artist1c", category: Tag.categories.artist, post_count: 101)
          create(:tag, name: "artist1d", category: Tag.categories.general, post_count: 300)

          assert_approve_fails("rename artist1a -> artist1b\ncreate alias artist1c -> artist1d", @builder)
          assert_equal(false, TagAlias.exists?(antecedent_name: "artist1c", consequent_name: "artist1d"))
        end

        should "fail if the script is changed to a disallowed script while approving the BUR" do
          create(:tag, name: "artist1a", category: Tag.categories.artist, post_count: 10)
          create(:tag, name: "artist1b", category: Tag.categories.general, post_count: 0)
          create(:tag, name: "artist1c", category: Tag.categories.artist, post_count: 101)
          create(:tag, name: "artist1d", category: Tag.categories.general, post_count: 300)
          @bulk_update_request = create(:bulk_update_request, script: "rename artist1a -> artist1b")

          stale_bur = BulkUpdateRequest.find(@bulk_update_request.id)
          @bulk_update_request.update!(script: "create alias artist1c -> artist1d")
          BulkUpdateRequest.stubs(:find).with(@bulk_update_request.id.to_s).returns(stale_bur)

          assert_approve_fails(@bulk_update_request, @builder)
          assert_equal(false, TagAlias.exists?(antecedent_name: "artist1c", consequent_name: "artist1d"))
        end

        should "fail when moving a non-artist tag" do
          create(:tag, name: "foo", post_count: 0)

          assert_approve_fails("alias foo -> bar", @builder)
          assert_equal(false, TagAlias.exists?(antecedent_name: "foo", consequent_name: "bar"))
        end

        should "fail for a large artist move" do
          create(:tag, name: "artist1", category: Tag.categories.artist, post_count: 1000)

          assert_approve_fails("create alias artist1 -> artist2", @builder)
          assert_equal(false, TagAlias.exists?(antecedent_name: "artist1", consequent_name: "artist2"))
        end

        should "fail when deprecating a tag" do
          create(:tag, name: "small_tag", post_count: 10)
          create(:wiki_page, title: "small_tag", body: "asd")

          assert_approve_fails("deprecate small_tag", @builder)
          assert_equal(false, Tag.find_by(name: "small_tag").is_deprecated?)
        end

        should "fail when changing the category of a small tag" do
          create(:tag, name: "small_tag", post_count: 10)

          assert_approve_fails("category small_tag -> character", @builder)
          assert_equal(true, Tag.find_by(name: "small_tag").general?)
        end
      end

      context "for a mod" do
        should "succeed when approving small character implications" do
          create(:tag, name: "foo_(summer)", category: Tag.categories.character, post_count: 10)
          create(:tag, name: "foo", category: Tag.categories.character, post_count: 200)
          create(:wiki_page, title: "foo_(summer)", body: "asd")
          create(:wiki_page, title: "foo", body: "asd")

          assert_approve_succeeds("imply foo_(summer) -> foo", @mod)
          assert_equal(true, TagImplication.exists?(antecedent_name: "foo_(summer)", consequent_name: "foo", status: "active"))
        end

        should "succeed when implying a small tag to a large tag" do
          create(:tag, name: "foo_(summer)", post_count: 10)
          create(:tag, name: "foo", post_count: 1000)
          create(:wiki_page, title: "foo_(summer)", body: "asd")
          create(:wiki_page, title: "foo", body: "asd")

          assert_approve_succeeds("imply foo_(summer) -> foo", @mod)
          assert_equal(true, TagImplication.exists?(antecedent_name: "foo_(summer)", consequent_name: "foo", status: "active"))
        end

        should "fail when implying a large tag to a large tag" do
          create(:tag, name: "foo_(summer)", category: Tag.categories.character, post_count: 201)
          create(:tag, name: "foo", category: Tag.categories.character, post_count: 1000)
          create(:wiki_page, title: "foo_(summer)", body: "asd")
          create(:wiki_page, title: "foo", body: "asd")

          assert_approve_fails("imply foo_(summer) -> foo", @mod)
          assert_equal(false, TagImplication.exists?(antecedent_name: "foo_(summer)", consequent_name: "foo", status: "active"))
        end

        should "succeed when aliasing two small non-artist tags" do
          create(:tag, name: "char1a", category: Tag.categories.character, post_count: 10)
          create(:tag, name: "char1b", category: Tag.categories.character, post_count: 20)

          assert_approve_succeeds("alias char1a -> char1b", @mod)
          assert_equal(true, TagAlias.exists?(antecedent_name: "char1a", consequent_name: "char1b", status: "active"))
        end

        should "succeed when adding an utility alias" do
          create(:tag, name: "char1b", category: Tag.categories.character, post_count: 20)

          assert_approve_succeeds("alias no_tag -> char1b", @mod)
          assert_equal(true, TagAlias.exists?(antecedent_name: "no_tag", consequent_name: "char1b", status: "active"))
        end

        should "succeed when aliasing a small tag to a large tag" do
          create(:tag, name: "char1a", category: Tag.categories.character, post_count: 10)
          create(:tag, name: "char1b", category: Tag.categories.character, post_count: 1000)

          assert_approve_succeeds("alias char1a -> char1b", @mod)
          assert_equal(true, TagAlias.exists?(antecedent_name: "char1a", consequent_name: "char1b", status: "active"))
        end

        should "fail when aliasing a large tag to a large tag" do
          create(:tag, name: "char1a", category: Tag.categories.character, post_count: 201)
          create(:tag, name: "char1b", category: Tag.categories.character, post_count: 300)

          assert_approve_fails("alias char1a -> char1b", @mod)
          assert_equal(false, TagAlias.exists?(antecedent_name: "char1a", consequent_name: "char1b"))
        end

        should "fail when aliasing a small tag to a large tag that would change the large tag's category" do
          create(:tag, name: "char1a", category: Tag.categories.character, post_count: 10)
          create(:tag, name: "gen1b", category: Tag.categories.general, post_count: 1000)

          assert_approve_fails("alias char1a -> gen1b", @mod)
          assert_equal(false, TagAlias.exists?(antecedent_name: "char1a", consequent_name: "gen1b"))
        end

        should "fail when aliasing a small tag with implications to a large tag" do
          create(:tag, name: "char1a", category: Tag.categories.character, post_count: 10)
          create(:tag, name: "char1b", category: Tag.categories.character, post_count: 1000)
          create(:tag_implication, antecedent_name: "char1a", consequent_name: "copyright1")

          assert_approve_fails("alias char1a -> char1b", @mod, "Can't approve create alias [[char1a]] -> [[char1b]] ([[char1a]] has implications; requires Admin)")
          assert_equal(false, TagAlias.exists?(antecedent_name: "char1a", consequent_name: "char1b"))
        end

        should "fail when aliasing a small banned artist to a large artist" do
          create(:tag, name: "art1a", category: Tag.categories.artist, post_count: 10)
          create(:tag, name: "art1b", category: Tag.categories.artist, post_count: 1000)
          create(:artist, name: "art1a", is_banned: true)
          artist = create(:artist, name: "art1b")

          assert_approve_fails("alias art1a -> art1b", @mod, "Can't approve create alias [[art1a]] -> [[art1b]] ([[art1a]] is a banned artist; requires Admin)")
          assert_equal(false, artist.reload.is_banned?)
        end

        should "fail when aliasing a small tag with a large cosplay tag to a large tag" do
          create(:tag, name: "char1a", category: Tag.categories.character, post_count: 10)
          create(:tag, name: "char1b", category: Tag.categories.character, post_count: 1000)
          create(:tag, name: "char1a_(cosplay)", category: Tag.categories.character, post_count: 1000)

          assert_approve_fails("alias char1a -> char1b", @mod, "Can't approve create alias [[char1a]] -> [[char1b]] ([[char1a_(cosplay)]] is too large; requires Admin)")
          assert_equal(false, TagAlias.exists?(antecedent_name: "char1a", consequent_name: "char1b"))
        end

        should "succeed when aliasing a small tag with a small cosplay tag to a large tag" do
          create(:tag, name: "char1a", category: Tag.categories.character, post_count: 10)
          create(:tag, name: "char1b", category: Tag.categories.character, post_count: 1000)
          create(:tag, name: "char1a_(cosplay)", category: Tag.categories.character, post_count: 5)

          assert_approve_succeeds("alias char1a -> char1b", @mod)
          assert_equal(true, TagAlias.exists?(antecedent_name: "char1a", consequent_name: "char1b", status: "active"))
        end

        should "fail when aliasing a small artist with a large style tag to a large artist" do
          create(:tag, name: "art1a", category: Tag.categories.artist, post_count: 10)
          create(:tag, name: "art1b", category: Tag.categories.artist, post_count: 1000)
          create(:tag, name: "art1a_(style)", category: Tag.categories.general, post_count: 1000)

          assert_approve_fails("alias art1a -> art1b", @mod, "Can't approve create alias [[art1a]] -> [[art1b]] ([[art1a_(style)]] is too large; requires Admin)")
          assert_equal(false, TagAlias.exists?(antecedent_name: "art1a", consequent_name: "art1b"))
        end

        should "fail when aliasing a small general tag with a large style tag to a large artist" do
          create(:tag, name: "gen1a", category: Tag.categories.general, post_count: 10)
          create(:tag, name: "art1b", category: Tag.categories.artist, post_count: 1000)
          create(:tag, name: "gen1a_(style)", category: Tag.categories.general, post_count: 1000)

          assert_approve_fails("alias gen1a -> art1b", @mod, "Can't approve create alias [[gen1a]] -> [[art1b]] ([[gen1a_(style)]] is too large; requires Admin)")
        end

        should "fail when an earlier line changes the small tag's category before aliasing it to a large tag" do
          create(:tag, name: "gen1a", category: Tag.categories.general, post_count: 10)
          create(:tag, name: "gen1b", category: Tag.categories.general, post_count: 1000)

          assert_approve_fails("category gen1a -> character\nalias gen1a -> gen1b", @mod, "Can't approve create alias [[gen1a]] -> [[gen1b]] (requires Admin)")
          assert_equal(false, TagAlias.exists?(antecedent_name: "gen1a", consequent_name: "gen1b"))
          assert_equal(true, Tag.find_by_name("gen1b").general?)
        end

        should "fail when an earlier line adds an implication to the small tag before aliasing it to a large tag" do
          create(:tag, name: "gen1a", category: Tag.categories.general, post_count: 10)
          create(:tag, name: "gen1b", category: Tag.categories.general, post_count: 1000)
          create(:tag, name: "gen1c", category: Tag.categories.general, post_count: 5)
          create(:wiki_page, title: "gen1a")
          create(:wiki_page, title: "gen1c")

          assert_approve_fails("imply gen1a -> gen1c\nalias gen1a -> gen1b", @mod, "Can't approve create alias [[gen1a]] -> [[gen1b]] ([[gen1a]] has implications; requires Admin)")
          assert_equal(false, TagAlias.exists?(antecedent_name: "gen1a", consequent_name: "gen1b"))
          assert_equal(false, TagImplication.exists?(antecedent_name: "gen1b", consequent_name: "gen1c"))
        end

        should "succeed when an earlier line changes the small tag's category before aliasing it to a small tag" do
          create(:tag, name: "gen1a", category: Tag.categories.general, post_count: 10)
          create(:tag, name: "gen1b", category: Tag.categories.general, post_count: 20)

          assert_approve_succeeds("category gen1a -> character\nalias gen1a -> gen1b", @mod)
          assert_equal(true, TagAlias.exists?(antecedent_name: "gen1a", consequent_name: "gen1b", status: "active"))
        end

        should "succeed when deprecating an empty tag" do
          create(:tag, name: "no_tag", post_count: 0)
          create(:wiki_page, title: "no_tag", body: "asd")

          assert_approve_succeeds("deprecate no_tag", @mod)
          assert_equal(true, Tag.find_by(name: "no_tag").is_deprecated?)
        end

        should "succeed when deprecating a small tag" do
          create(:tag, name: "small_tag", post_count: 10)
          create(:wiki_page, title: "small_tag", body: "asd")

          assert_approve_succeeds("deprecate small_tag", @mod)
          assert_equal(true, Tag.find_by(name: "small_tag").is_deprecated?)
        end

        should "fail when deprecating a tag that's too large" do
          create(:tag, name: "large_tag", post_count: 300)
          create(:wiki_page, title: "large_tag", body: "asd")

          assert_approve_fails("deprecate large_tag", @mod)
          assert_equal(false, Tag.find_by(name: "large_tag").is_deprecated?)
        end

        should "succeed when changing the category of a small tag" do
          create(:tag, name: "small_tag", post_count: 200)

          assert_approve_succeeds("category small_tag -> character", @mod)
          assert_equal(true, Tag.find_by(name: "small_tag").character?)
        end

        should "fail when changing the category of a tag that's too large" do
          create(:tag, name: "large_tag", post_count: 201)

          assert_approve_fails("category large_tag -> character", @mod)
          assert_equal(true, Tag.find_by(name: "large_tag").general?)
        end

        should "succeed when removing a small artist alias" do
          create(:tag, name: "artist1", category: Tag.categories.artist, post_count: 0)
          create(:tag, name: "artist2", category: Tag.categories.artist, post_count: 20)
          create(:tag_alias, antecedent_name: "artist1", consequent_name: "artist2")

          assert_approve_succeeds("remove alias artist1 -> artist2", @mod)
          assert_equal(true, TagAlias.find_by(antecedent_name: "artist1", consequent_name: "artist2").is_deleted?)
        end

        should "fail when removing a large artist alias" do
          create(:tag, name: "artist1", category: Tag.categories.artist, post_count: 0)
          create(:tag, name: "artist2", category: Tag.categories.artist, post_count: 300)
          create(:tag_alias, antecedent_name: "artist1", consequent_name: "artist2")

          assert_approve_fails("remove alias artist1 -> artist2", @mod)
          assert_equal(false, TagAlias.find_by(antecedent_name: "artist1", consequent_name: "artist2").is_deleted?)
        end

        should "fail when removing a non-artist alias" do
          create(:tag, name: "char1a", category: Tag.categories.character, post_count: 0)
          create(:tag, name: "char1b", category: Tag.categories.character, post_count: 20)
          create(:tag_alias, antecedent_name: "char1a", consequent_name: "char1b")

          assert_approve_fails("remove alias char1a -> char1b", @mod)
          assert_equal(false, TagAlias.find_by(antecedent_name: "char1a", consequent_name: "char1b").is_deleted?)
        end
      end

      context "for an admin" do
        should "succeed" do
          post_auth approve_bulk_update_request_path(@bulk_update_request), @admin

          assert_response :redirect
          assert_equal("processing", @bulk_update_request.reload.status)
          perform_enqueued_jobs
          assert_equal("approved", @bulk_update_request.reload.status)
        end

        should "fail if the BUR is approved by someone else at the same time" do
          stale_bur = BulkUpdateRequest.find(@bulk_update_request.id)
          @bulk_update_request.update!(status: "processing", approver: @mod)
          BulkUpdateRequest.stubs(:find).with(@bulk_update_request.id.to_s).returns(stale_bur)

          post_auth approve_bulk_update_request_path(@bulk_update_request), @admin

          assert_response 403
          assert_equal(@mod, @bulk_update_request.reload.approver)
        end
      end
    end
  end
end
