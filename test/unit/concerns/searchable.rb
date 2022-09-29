require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
  context "#search method" do
    subject { Post }

    setup do
      @p1 = create(:post, source: "a1", score: 1, is_deleted: true)
      @p2 = create(:post, source: "b2", score: 2, is_deleted: false)
      @p3 = create(:post, source: "c3", score: 3, is_deleted: false)
    end

    context "for a nonexistent attribute" do
      should "raise an error" do
        assert_raises(ArgumentError) do
          Post.search_attributes({ answer: 42 }, [:answer], current_user: User.anonymous)
        end
      end
    end

    context "for a numeric attribute" do
      should "support basic operators" do
        assert_search_equals(@p1, score_eq: 1)
        assert_search_equals(@p3, score_gt: 2)
        assert_search_equals(@p1, score_lt: 2)
        assert_search_equals([@p3, @p1], score_not_eq: 2)
        assert_search_equals([@p3, @p2], score_gteq: 2)
        assert_search_equals([@p2, @p1], score_lteq: 2)
      end

      should "support embedded expressions" do
        assert_search_equals(@p1, score: "1")
        assert_search_equals(@p3, score: ">2")
        assert_search_equals(@p1, score: "<2")
        assert_search_equals([@p3, @p2], score: ">=2")
        assert_search_equals([@p2, @p1], score: "<=2")
        assert_search_equals([@p3, @p2], score: "3,2")
        assert_search_equals([@p2, @p1], score: "1...3")
        assert_search_equals([@p2, @p1], score: "3...1")
        assert_search_equals([@p3, @p2, @p1], score: "1..3")
        assert_search_equals([@p3, @p2, @p1], score: "3..1")

        assert_search_equals([@p3, @p2], score_not: "1")
        assert_search_equals(@p3, score_not: "1..2")
        assert_search_equals(@p1, score_not: ">1")
      end

      should "support multiple operators on the same attribute" do
        assert_search_equals(@p2, score_eq: 2, score_gt: 1)
        assert_search_equals(@p2, score_gt: 1, score_lt: 3)
        assert_search_equals(@p2, score_eq: 2, score_not: "1,3")
      end
    end

    context "for a string attribute" do
      should "support various operators" do
        assert_search_equals(@p1, source: "a1")
        assert_search_equals(@p1, source_eq: "a1")
        assert_search_equals(@p1, source_like: "a*")
        assert_search_equals(@p1, source_ilike: "A*")
        assert_search_equals(@p1, source_regex: "^a.*")

        assert_search_equals([], id: @p1.id, source_like: "A*")
        assert_search_equals([@p1], id: @p1.id, source_not_like: "A*")
        assert_search_equals([], id: @p1.id, source_regex: "^A.*")
        assert_search_equals([@p1], id: @p1.id, source_not_regex: "^A.*")

        assert_search_equals(@p1, source_array: ["a1", "blah"])
        assert_search_equals(@p1, source_comma: "a1,blah")
        assert_search_equals(@p1, source_space: "a1 blah")
        assert_search_equals(@p1, source_lower_array: ["a1", "BLAH"])
        assert_search_equals(@p1, source_lower_comma: "a1,BLAH")
        assert_search_equals(@p1, source_lower_space: "a1 BLAH")

        assert_search_equals([@p3, @p2], source_not_eq: "a1")
        assert_search_equals([@p3, @p2], source_not_like: "a*")
        assert_search_equals([@p3, @p2], source_not_ilike: "A*")
        assert_search_equals([@p3, @p2], source_not_regex: "^a.*")

        assert_search_equals([], source_present: "false")
        assert_search_equals([@p3, @p2, @p1], source_present: "true")
      end

      should "support multiple operators on the same attribute" do
        assert_search_equals([], source: "a1", source_not_eq: "a1")
        assert_search_equals(@p1, source: "a1", source_not_eq: "b2")
      end
    end

    context "for a boolean attribute" do
      should "work" do
        assert_search_equals(@p1, is_deleted: "true")
        assert_search_equals(@p1, is_deleted: "yes")
        assert_search_equals(@p1, is_deleted: "on")
        assert_search_equals(@p1, is_deleted: "1")

        assert_search_equals([@p3, @p2], is_deleted: "false")
        assert_search_equals([@p3, @p2], is_deleted: "no")
        assert_search_equals([@p3, @p2], is_deleted: "off")
        assert_search_equals([@p3, @p2], is_deleted: "0")
      end
    end

    context "for an inet attribute" do
      subject { UserSession }

      should "work" do
        @us1 = create(:user_session, ip_addr: "10.0.0.1")
        @us2 = create(:user_session, ip_addr: "11.0.0.1")

        assert_search_equals(@us1, ip_addr: "10.0.0.1")
        assert_search_equals(@us1, ip_addr: "10.0.0.1/24")
        assert_search_equals(@us1, ip_addr: "10.0.0.1,1.1.1.1")
        assert_search_equals(@us1, ip_addr: "10.0.0.1 1.1.1.1")

        assert_search_equals([@us2, @us1], ip_addr: "10.1.0.0/8,11.1.0.0/8")
        assert_search_equals([@us2, @us1], ip_addr: "10.1.0.0/8 11.1.0.0/8")

        assert_search_equals([], ip_addr: "10.0.0.x")
        assert_search_equals([], ip_addr: "10.0.0.x 11.0.0.y")
      end
    end

    context "for an enum attribute" do
      subject { PostFlag }

      should "work" do
        @pf1 = create(:post_flag, status: :pending)
        @pf2 = create(:post_flag, status: :rejected)

        assert_search_equals(@pf1, status: "pending")
        assert_search_equals(@pf1, status: "pending,blah")
        assert_search_equals(@pf1, status: "pending blah")

        assert_search_equals(@pf2, status_not: "pending")
        assert_search_equals([], status_not: "pending,rejected")

        assert_search_equals(@pf1, status_id: "0")
        assert_search_equals(@pf1, status_id_eq: "0")
        assert_search_equals([@pf2, @pf1], status_id: "0 2")
        assert_search_equals([@pf2, @pf1], status_id: "0,2")
        assert_search_equals([@pf2, @pf1], status_id: "0..2")
        assert_search_equals([@pf2], status_id: ">0")

        assert_search_equals(@pf2, status_id_not: "0")
        assert_search_equals(@pf2, status_id_not_eq: "0")
      end

      should "support multiple operators on the same attribute" do
        assert_search_equals(@pf1, status: "pending", status_id: PostFlag.statuses[:pending])
        assert_search_equals([], status: "pending", status_id: PostFlag.statuses[:rejected])
        assert_search_equals(@pf1, status_id: PostFlag.statuses[:pending], status_id_not: PostFlag.statuses[:rejected])
      end
    end

    context "for an array attribute" do
      subject { WikiPage }

      should "work" do
        @wp1 = create(:wiki_page, other_names: ["a1", "b2"])
        @wp2 = create(:wiki_page, other_names: ["c3", "d4"])

        assert_search_equals(@wp1, other_names_include_any: "a1")
        assert_search_equals(@wp1, other_names_include_any: "a1 blah")

        assert_search_equals(@wp1, other_names_include_all: "a1")
        assert_search_equals(@wp1, other_names_include_all: "a1 b2")

        assert_search_equals(@wp1, other_names_include_any_array: ["a1", "blah"])
        assert_search_equals(@wp1, other_names_include_all_array: ["a1", "b2"])

        assert_search_equals(@wp1, other_names_include_any_lower: "A1 BLAH")
        assert_search_equals(@wp1, other_names_include_all_lower: "A1 B2")

        assert_search_equals(@wp1, other_names_include_any_lower_array: ["A1", "BLAH"])
        assert_search_equals(@wp1, other_names_include_all_lower_array: ["A1", "B2"])

        assert_search_equals(@wp1, any_other_name_matches_regex: "^a")
        assert_search_equals(@wp1, any_other_name_matches_regex: "[ab][12]")

        assert_search_equals([@wp2, @wp1], other_name_count: 2)
      end

      should "support multiple operators on the same attribute" do
        assert_search_equals(@wp1, other_names_include_any: "a1", other_name_count: 2)
        assert_search_equals(@wp2, other_names_include_any: "c3", other_name_count: 2)
      end
    end

    context "for a belongs_to association" do
      context "for a user association" do
        should "work" do
          assert_search_equals(@p1, uploader_id: @p1.uploader_id)
          assert_search_equals(@p1, uploader_name: @p1.uploader.name)

          assert_search_equals(@p1, uploader: { id: @p1.uploader_id })
          assert_search_equals(@p1, uploader: { name: @p1.uploader.name })

          assert_search_equals(@p1, uploader: { name: @p1.uploader.name }, uploader_id: @p1.uploader.id)
          assert_search_equals([], uploader: { name: @p1.uploader.name }, uploader_id: @p2.uploader.id)
        end
      end

      context "for a post association" do
        should "work" do
          @p1.update!(parent: @p2)

          assert_search_equals(@p1, parent_id: @p2.id)
          assert_search_equals(@p1, parent: { id: @p2.id })

          assert_search_equals(@p1, parent_tags_match: "id:#{@p2.id}")
          assert_search_equals([], parent_tags_match: "id:0")

          assert_search_equals(@p2, children_tags_match: "id:#{@p1.id}")
          assert_search_equals([], children_tags_match: "id:0")

          assert_search_equals(@p1, has_parent: true)
          assert_search_equals([@p3, @p2], has_parent: false)
        end
      end

      context "for a polymorphic association" do
        subject { ModerationReport }

        should "work" do
          as(create(:user)) do
            @mr1 = create(:moderation_report, model: create(:comment))
            @mr2 = create(:moderation_report, model: create(:forum_post))
            @mr3 = create(:moderation_report, model: create(:dmail))
          end

          assert_search_equals(@mr1, model_type: "Comment")
          assert_search_equals(@mr2, model_type: "ForumPost")
          assert_search_equals(@mr3, model_type: "Dmail")

          assert_search_equals(@mr1, model_type: "Comment", model_id: @mr1.model.id)
          assert_search_equals(@mr2, model_type: "ForumPost", model_id: @mr2.model.id)
          assert_search_equals(@mr3, model_type: "Dmail", model_id: @mr3.model.id)

          assert_search_equals([@mr2, @mr1], model_type_not_eq: "Dmail")
          assert_search_equals([], model_type: "Dmail", model_id_not_eq: @mr3.model_id)

          assert_search_equals(@mr1, Comment: { body: @mr1.model.body })
          assert_search_equals(@mr2, ForumPost: { body: @mr2.model.body })

          assert_search_equals([], Dmail: { body: @mr3.model.body }, current_user: User.anonymous)
          assert_search_equals(@mr3, Dmail: { body: @mr3.model.body }, current_user: @mr3.model.owner)
        end
      end
    end

    context "for a has_many association" do
      should "work" do
        as(@p1.uploader) { create(:comment, post: @p1) }

        assert_search_equals(@p1, has_comments: true)
        assert_search_equals([@p3, @p2], has_comments: false)

        assert_search_equals(@p1, comments: { id: @p1.comments.first.id })
        assert_search_equals(@p1, has_comments: true, comments: { id: @p1.comments.first.id })
      end
    end

    context "for a `has_many through: ...` association" do
      subject { Upload }

      should "work" do
        @media_asset = create(:media_asset)
        @upload1 = create(:upload, upload_media_assets: [build(:upload_media_asset, media_asset: @media_asset)])
        @upload2 = create(:upload, upload_media_assets: [build(:upload_media_asset, media_asset: @media_asset)])

        assert_search_equals([@upload2, @upload1], media_asset: { md5: @media_asset.md5 })
      end
    end
  end
end
