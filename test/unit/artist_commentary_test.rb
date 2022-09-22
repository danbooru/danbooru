require 'test_helper'

class ArtistCommentaryTest < ActiveSupport::TestCase
  setup do
    user = FactoryBot.create(:user)
    CurrentUser.user = user
  end

  teardown do
    CurrentUser.user = nil
  end

  should "A post should not have more than one commentary" do
    post = FactoryBot.create(:post)

    assert_raise(ActiveRecord::RecordInvalid) do
      FactoryBot.create(:artist_commentary, post_id: post.id)
      FactoryBot.create(:artist_commentary, post_id: post.id)
    end
  end

  context "An artist commentary" do
    context "when searched" do
      setup do
        @post1 = FactoryBot.create(:post, tag_string: "artcomm1")
        @post2 = FactoryBot.create(:post, tag_string: "artcomm2")
        @artcomm1 = FactoryBot.create(:artist_commentary, post_id: @post1.id, original_title: "foo", translated_title: "bar")
        @artcomm2 = FactoryBot.create(:artist_commentary, post_id: @post2.id, original_title: "", original_description: "", translated_title: "", translated_description: "")
      end

      should "find the correct match" do
        assert_search_equals(@artcomm1, post_id: @post1.id.to_s)
        assert_search_equals(@artcomm1, text_matches: "foo")
        assert_search_equals(@artcomm1, text_matches: "f*")
        assert_search_equals(@artcomm1, post_tags_match: "artcomm1")

        assert_search_equals(@artcomm1, original_present: "yes")
        assert_search_equals(@artcomm2, original_present: "no")

        assert_search_equals(@artcomm1, translated_present: "yes")
        assert_search_equals(@artcomm2, translated_present: "no")
      end
    end

    context "when created" do
      should "create a new version" do
        @artcomm = FactoryBot.create(:artist_commentary, original_title: "foo")

        assert_equal(1, @artcomm.versions.size)
        assert_equal("foo", @artcomm.versions.last.original_title)
      end
    end

    context "when updated" do
      setup do
        @post = FactoryBot.create(:post)
        @artcomm = FactoryBot.create(:artist_commentary, post_id: @post.id)
        @artcomm.reload
      end

      should "add tags if requested" do
        @artcomm.update(translated_title: "bar", add_commentary_tag: "1")
        assert_equal(true, @post.reload.has_tag?("commentary"))
      end

      should "not create new version if nothing changed" do
        @artcomm.save
        assert_equal(1, @post.artist_commentary.versions.size)
      end

      should "create a new version if outside merge window" do
        travel(2.hours) do
          @artcomm.update(original_title: "bar")

          assert_equal(2, @post.artist_commentary.versions.size)
          assert_equal("bar", @artcomm.versions.last.original_title)
        end
      end

      should "merge with the previous version if inside merge window" do
        @artcomm.update(original_title: "bar")
        @artcomm.reload

        assert_equal(1, @post.artist_commentary.versions.size)
        assert_equal("bar", @artcomm.versions.last.original_title)
      end

      should "trim whitespace from all fields" do
        # \u00A0 - nonbreaking space.
        @artcomm.update(
          original_title: "  foo\u00A0\t\n",
          original_description: " foo\u00A0\t\n",
          translated_title: "  foo\u00A0\t\n",
          translated_description: "  foo\u00A0\n"
        )

        assert_equal("foo", @artcomm.original_title)
        assert_equal("foo", @artcomm.original_description)
        assert_equal("foo", @artcomm.translated_title)
        assert_equal("foo", @artcomm.translated_description)
      end
    end
  end
end
