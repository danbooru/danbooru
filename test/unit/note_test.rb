require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      @user = FactoryBot.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "#merge_version" do
      setup do
        @post = FactoryBot.create(:post)
        @note = FactoryBot.create(:note, :post => @post)
      end

      should "not increment version" do
        @note.update(x: 100)
        assert_equal(1, @note.versions.count)
        assert_equal(1, @note.versions.first.version)
      end
    end

    context "for a post that already has a note" do
      setup do
        @post = FactoryBot.create(:post)
        @note = FactoryBot.create(:note, :post => @post)
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
        @post = FactoryBot.create(:post, :image_width => 1000, :image_height => 1000)
      end

      should "not validate if the note is outside the image" do
        @note = FactoryBot.build(:note, :x => 1001, :y => 500, :post => @post)
        @note.save
        assert_equal(["Note must be inside the image"], @note.errors.full_messages)
      end

      should "not validate if the note is larger than the image" do
        @note = FactoryBot.build(:note, :x => 500, :y => 500, :height => 501, :width => 500, :post => @post)
        @note.save
        assert_equal(["Note must be inside the image"], @note.errors.full_messages)
      end

      should "not validate if the body is blank" do
        @note = FactoryBot.build(:note, body: "   ", :post => @post)

        assert_equal(false, @note.valid?)
        assert_equal(["Body can't be blank"], @note.errors.full_messages)
      end

      should "create a version" do
        assert_difference("NoteVersion.count", 1) do
          travel(1.day) do
            @note = FactoryBot.create(:note, :post => @post)
          end
        end

        assert_equal(1, @note.versions.count)
        assert_equal(@note.body, @note.versions.first.body)
        assert_equal(1, @note.version)
        assert_equal(1, @note.versions.first.version)
        assert_equal(@user.id, @note.versions.first.updater_id)
        assert_equal(CurrentUser.ip_addr, @note.versions.first.updater_ip_addr.to_s)
      end

      should "update the post's last_noted_at field" do
        assert_nil(@post.last_noted_at)
        @note = FactoryBot.create(:note, :post => @post)
        @post.reload
        assert_not_nil(@post.last_noted_at)
      end

      context "for a note-locked post" do
        setup do
          CurrentUser.scoped(create(:builder_user)) do
            create(:post_lock, post: @post, notes_lock: true)
          end
        end

        should "fail" do
          assert_difference("Note.count", 0) do
            @note = FactoryBot.build(:note, :post => @post)
            @note.save
          end
          assert_equal(["Post has an active notes lock"], @note.errors.full_messages)
        end
      end
    end

    context "updating a note" do
      setup do
        @post = FactoryBot.create(:post, :image_width => 1000, :image_height => 1000)
        @note = FactoryBot.create(:note, :post => @post)
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
        assert_equal(CurrentUser.ip_addr, @note.versions.last.updater_ip_addr.to_s)
      end

      context "for a note-locked post" do
        setup do
          CurrentUser.scoped(create(:builder_user)) do
            create(:post_lock, post: @post, notes_lock: true)
          end
        end

        should "fail" do
          @note.update(x: 500)
          assert_equal(["Post has an active notes lock"], @note.errors.full_messages)
        end
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
        @note = FactoryBot.create(:note, :body => "aaa")
      end

      context "where the body contains the string 'aaa'" do
        should "return a hit" do
          assert_equal(1, Note.search(body_matches: "aaa").count)
        end
      end

      context "where the body contains the string 'bbb'" do
        should "return no hits" do
          assert_equal(0, Note.search(body_matches: "bbb").count)
        end
      end
    end
  end
end
