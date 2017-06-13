require 'test_helper'

class ArtistCommentaryTest < ActiveSupport::TestCase
  setup do
    user = FactoryGirl.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
  end

  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  should "A post should not have more than one commentary" do
    post = FactoryGirl.create(:post)

    assert_raise(ActiveRecord::RecordInvalid) do
      FactoryGirl.create(:artist_commentary, post_id: post.id)
      FactoryGirl.create(:artist_commentary, post_id: post.id)
    end
  end

  context "An artist commentary" do
    context "when searched" do
      setup do
        @post1 = FactoryGirl.create(:post, tag_string: "artcomm1")
        @post2 = FactoryGirl.create(:post, tag_string: "artcomm2")
        @artcomm1 = FactoryGirl.create(:artist_commentary, post_id: @post1.id, original_title: "foo", translated_title: "bar")
        @artcomm2 = FactoryGirl.create(:artist_commentary, post_id: @post2.id, original_title: "", original_description: "", translated_title: "", translated_description: "")
      end

      should "find the correct match" do
        assert_equal([@artcomm1.id], ArtistCommentary.search(post_id: @post1.id.to_s).map(&:id))
        assert_equal([@artcomm1.id], ArtistCommentary.search(text_matches: "foo").map(&:id))
        assert_equal([@artcomm1.id], ArtistCommentary.search(text_matches: "f*").map(&:id))
        assert_equal([@artcomm1.id], ArtistCommentary.search(post_tags_match: "artcomm1").map(&:id))

        assert_equal([@artcomm1.id], ArtistCommentary.search(original_present: "yes").map(&:id))
        assert_equal([@artcomm2.id], ArtistCommentary.search(original_present: "no").map(&:id))

        assert_equal([@artcomm1.id], ArtistCommentary.search(translated_present: "yes").map(&:id))
        assert_equal([@artcomm2.id], ArtistCommentary.search(translated_present: "no").map(&:id))
      end
    end

    context "when created" do
      should "create a new version" do
        @artcomm = FactoryGirl.create(:artist_commentary, original_title: "foo")

        assert_equal(1, @artcomm.versions.size)
        assert_equal("foo", @artcomm.versions.last.original_title)
      end
    end
  end
end
