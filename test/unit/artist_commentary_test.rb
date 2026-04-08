require "test_helper"

class ArtistCommentaryTest < ActiveSupport::TestCase
  should "A post should not have more than one commentary" do
    post = create(:post)

    assert_raise(ActiveRecord::RecordInvalid) do
      create(:artist_commentary, post_id: post.id)
      create(:artist_commentary, post_id: post.id)
    end
  end

  context "An artist commentary" do
    context "when searched" do
      setup do
        @post1 = create(:post, tag_string: "artcomm1")
        @post2 = create(:post, tag_string: "artcomm2")
        @artcomm1 = create(:artist_commentary, post_id: @post1.id, original_title: "foo", translated_title: "bar")
        @artcomm2 = create(:artist_commentary, post_id: @post2.id, original_title: "", original_description: "", translated_title: "", translated_description: "")
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
        @artcomm = create(:artist_commentary, original_title: "foo")

        assert_equal(1, @artcomm.versions.size)
        assert_equal("foo", @artcomm.versions.last.original_title)
      end
    end

    context "when updated" do
      setup do
        @user = create(:user)
        @artcomm = as(@user) { create(:artist_commentary).reload }
      end

      should "add tags if requested" do
        as(@user) { @artcomm.update(translated_title: "bar", commentary_tags: "commentary") }
        assert_equal(true, @artcomm.post.reload.has_tag?("commentary"))

        as(@user) { @artcomm.update(commentary_tags: "partial_commentary") }
        assert_equal(false, @artcomm.post.reload.has_tag?("commentary"))
        assert_equal(true, @artcomm.post.has_tag?("partial_commentary"))
      end

      should "remove tags if requested" do
        @artcomm.post.update!(tag_string: "partial_commentary commentary")
        as(@user) { @artcomm.update!(commentary_tags: "none") }

        assert_not(@artcomm.post.reload.has_tag?("commentary"))
        assert_not(@artcomm.post.has_tag?("partial_commentary"))
      end

      should "not add unrelated tags" do
        as(@user) { @artcomm.update(commentary_tags: "foo") }
        assert_not(@artcomm.post.reload.has_tag?("foo"))
      end

      should "not create new version if nothing changed" do
        as(@user) { @artcomm.save }
        assert_equal(1, @artcomm.versions.size)
      end

      should "create a new version if outside merge window" do
        travel(2.hours) do
          as(@user) { @artcomm.update!(original_title: "bar") }

          assert_equal(2, @artcomm.reload.versions.size)
          assert_equal("bar", @artcomm.versions.last.original_title)
        end
      end

      should "merge with the previous version if inside merge window" do
        as(@user) { @artcomm.update!(original_title: "bar") }

        assert_equal(1, @artcomm.reload.versions.size)
        assert_equal("bar", @artcomm.versions.last.original_title)
      end

      context "during normalization" do
        subject { build(:artist_commentary) }

        # \u00A0 - nonbreaking space.
        should normalize_attribute(:original_title).from("  foo\u00A0\t\n").to("foo")
        should normalize_attribute(:original_description).from("  foo\u00A0\t\n").to("foo")
        should normalize_attribute(:translated_title).from("  foo\u00A0\t\n").to("foo")
        should normalize_attribute(:translated_description).from("  foo\u00A0\t\n").to("foo")

        should normalize_attribute(:original_description).from(" ").to("")
        should normalize_attribute(:original_description).from("  \u200B  ").to("")
        should normalize_attribute(:original_description).from(" foo ").to("foo")
        should normalize_attribute(:original_description).from("foo\tbar").to("foo bar")
        should normalize_attribute(:original_description).from("foo\nbar").to("foo\r\nbar")
        should normalize_attribute(:original_description).from("Pokémon".unicode_normalize(:nfd)).to("Pokémon".unicode_normalize(:nfc))
      end
    end

    context "during validation" do
      subject { build(:artist_commentary) }

      should_not allow_value("x" * 700).for(:original_title)
      should_not allow_value("x" * 700).for(:translated_title)
      should_not allow_value("x" * 60_000).for(:original_description)
      should_not allow_value("x" * 60_000).for(:translated_description)
    end
  end
end
