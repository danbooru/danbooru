require "test_helper"

class NoteTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      @user = create(:user)
      CurrentUser.user = @user
    end

    teardown do
      CurrentUser.user = nil
    end

    context "#merge_version" do
      setup do
        @post = create(:post)
        @note = create(:note, post: @post)
      end

      should "not increment version" do
        @note.update(x: 100)
        assert_equal(1, @note.versions.count)
        assert_equal(1, @note.versions.first.version)
      end
    end

    context "for a post that already has a note" do
      setup do
        @post = create(:post)
        @note = create(:note, post: @post)
      end

      context "when the note is deleted the post" do
        should "null out its last_noted_at_field" do
          assert_not_nil(@post.reload.last_noted_at)
          @note.update!(is_active: false)
          assert_nil(@post.reload.last_noted_at)
        end
      end
    end

    context "creating a note" do
      setup do
        @post = create(:post, image_width: 1000, image_height: 1000)
      end

      should "not validate if the note is outside the image" do
        @note = build(:note, x: 1001, y: 500, post: @post)
        @note.save
        assert_equal(["Note must be inside the image"], @note.errors.full_messages)
      end

      should "not validate if the note is larger than the image" do
        @note = build(:note, x: 500, y: 500, height: 501, width: 500, post: @post)
        @note.save
        assert_equal(["Note must be inside the image"], @note.errors.full_messages)
      end

      should "not validate if the note has zero width" do
        @note = build(:note, x: 500, y: 500, width: 0, height: 100, post: @post)

        assert_equal(false, @note.valid?)
        assert_equal(["Width must be at least 10 pixels"], @note.errors.full_messages)
      end

      should "not validate if the note has zero height" do
        @note = build(:note, x: 500, y: 500, width: 100, height: 0, post: @post)

        assert_equal(false, @note.valid?)
        assert_equal(["Height must be at least 10 pixels"], @note.errors.full_messages)
      end

      should "not validate if the note is smaller than 10x10" do
        @note = build(:note, x: 500, y: 500, width: 9, height: 9, post: @post)

        assert_equal(false, @note.valid?)
        assert_equal(["Width must be at least 10 pixels", "Height must be at least 10 pixels"], @note.errors.full_messages)
      end

      should "validate if the note is 10x10" do
        @note = build(:note, x: 500, y: 500, width: 10, height: 10, post: @post)

        assert_equal(true, @note.valid?)
      end

      should "allow notes the size of the whole image on images smaller than 10x10" do
        @note = build(:note, x: 0, y: 0, width: 5, height: 8, post: create(:post, image_width: 5, image_height: 8))

        assert_equal(true, @note.valid?)
      end

      should "not shrink the note below 10x10 when copying it to a smaller post" do
        @note = create(:note, x: 980, y: 980, width: 20, height: 20, post: @post)
        @small_post = create(:post, image_width: 100, image_height: 100)
        @note.copy_to(@small_post)

        assert_equal([[90, 90, 10, 10]], @small_post.notes.pluck(:x, :y, :width, :height))
      end

      should "not shrink the note below 10x10 when rescaling it" do
        @note = create(:note, x: 980, y: 980, width: 20, height: 20, post: @post)
        @post.update!(image_width: 100, image_height: 100)
        @note.rescale!(0.1, 0.1)

        assert_equal([90, 90, 10, 10], [@note.reload.x, @note.y, @note.width, @note.height])
      end

      should "not validate if the body is blank" do
        @note = build(:note, body: "   ", post: @post)

        assert_equal(false, @note.valid?)
        assert_equal(["Body can't be blank"], @note.errors.full_messages)
      end

      should "not validate if the post is a video" do
        @note = build(:note, post: create(:post, file_ext: "webm"))

        assert_equal(false, @note.valid?)
        assert_equal(["Post cannot have notes"], @note.errors.full_messages)
      end

      should "not validate if the post already has the maximum number of active notes" do
        stub_const(Note, :MAX_NOTES_PER_POST, 2) do
          create_list(:note, 2, post: @post)
          @note = build(:note, post: @post)

          assert_equal(false, @note.valid?)
          assert_equal(["Post can't have more than 2 notes"], @note.errors.full_messages)
        end
      end

      should "not count deleted notes towards the maximum" do
        stub_const(Note, :MAX_NOTES_PER_POST, 2) do
          create(:note, post: @post)
          create(:note, post: @post, is_active: false)

          assert_equal(true, build(:note, post: @post).valid?)
        end
      end

      should "not allow undeleting a note if the post already has the maximum number of active notes" do
        stub_const(Note, :MAX_NOTES_PER_POST, 2) do
          @deleted_note = create(:note, post: @post, is_active: false)
          create_list(:note, 2, post: @post)

          assert_equal(false, @deleted_note.update(is_active: true))
          assert_equal(["Post can't have more than 2 notes"], @deleted_note.errors.full_messages)
        end
      end

      should "allow editing an active note if the post is at the maximum number of active notes" do
        stub_const(Note, :MAX_NOTES_PER_POST, 2) do
          @note = create(:note, post: @post)
          create(:note, post: @post)

          assert_equal(true, @note.update(body: "edited"))
        end
      end

      should "create a version" do
        assert_difference("NoteVersion.count", 1) do
          travel(1.day) do
            @note = create(:note, post: @post)
          end
        end

        assert_equal(1, @note.versions.count)
        assert_equal(@note.body, @note.versions.first.body)
        assert_equal(1, @note.version)
        assert_equal(1, @note.versions.first.version)
        assert_equal(@user.id, @note.versions.first.updater_id)
      end

      should "update the post's last_noted_at field" do
        assert_nil(@post.last_noted_at)
        @note = create(:note, post: @post)
        @post.reload
        assert_not_nil(@post.last_noted_at)
      end
    end

    context "updating a note" do
      setup do
        @post = create(:post, image_width: 1000, image_height: 1000)
        @note = create(:note, post: @post)
        @note.stubs(:merge_version?).returns(false)
      end

      should "increment the updater's note_update_count" do
        @user.reload
        assert_difference("@user.note_update_count", 1) do
          @note.update(body: "zzz")
          @user.reload
        end
      end

      should "update the post's last_noted_at field" do
        assert_equal(@post.reload.last_noted_at.to_i, @note.updated_at.to_i)
        assert_changes("@post.reload.last_noted_at") { @note.update(x: 500) }
        assert_equal(@post.reload.last_noted_at.to_i, @note.reload.updated_at.to_i)
      end

      should "create a version" do
        assert_difference("NoteVersion.count", 1) do
          travel(1.day) do
            @note.update(body: "fafafa")
          end
        end
        assert_equal(2, @note.versions.count)
        assert_equal(2, @note.versions.last.version)
        assert_equal("fafafa", @note.versions.last.body)
        assert_equal(2, @note.version)
        assert_equal(@user.id, @note.versions.last.updater_id)
      end

      context "without making any changes" do
        should "not create a new version" do
          assert_no_difference("@note.versions.count") do
            @note.save
          end
        end
      end
    end

    context "searching for a note" do
      setup do
        @note = create(:note, body: "aaa")
      end

      context "where the body contains the string 'aaa'" do
        should "return a hit" do
          assert_search_equals(@note, body_matches: "aaa")
        end
      end

      context "where the body contains the string 'bbb'" do
        should "return no hits" do
          assert_search_equals([], body_matches: "bbb")
        end
      end
    end

    context "when validating notes" do
      should allow_value("a" * 5000).for(:body)

      should_not allow_value("").for(:body)
      should_not allow_value("   ").for(:body)
      should_not allow_value("\u200B").for(:body)
      should_not allow_value("a" * 5001).for(:body)
    end

    context "during normalization" do
      should normalize_attribute(:body).from(" ").to("")
      should normalize_attribute(:body).from("  \u200B  ").to("")
      should normalize_attribute(:body).from(" foo ").to("foo")
      should normalize_attribute(:body).from("foo\tbar").to("foo bar")
      should normalize_attribute(:body).from("foo\nbar").to("foo\r\nbar")
      should normalize_attribute(:body).from("Pokémon".unicode_normalize(:nfd)).to("Pokémon".unicode_normalize(:nfc))
    end
  end
end
