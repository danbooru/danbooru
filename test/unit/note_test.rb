require_relative '../test_helper'

class NoteTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "creating a note" do
      setup do
        @post = Factory.create(:post)
      end
      
      should "create a version" do
        assert_difference("NoteVersion.count", 1) do
          @note = Factory.create(:note, :post => @post)
        end

        assert_equal(1, @note.versions.count)
        assert_equal(@note.body, @note.versions.first.body)
      end
      
      should "update the post's last_noted_at field" do
        assert_nil(@post.last_noted_at)
        @note = Factory.create(:note, :post => @post)
        @post.reload
        assert_not_nil(@post.last_noted_at)
      end

      context "for a note-locked post" do
        setup do
          @post.update_attribute(:is_note_locked, true)
        end

        should "fail" do
          assert_difference("Note.count", 0) do
            @note = Factory.build(:note, :post => @post)
            @note.save
          end
          assert_equal(["Post is note locked"], @note.errors.full_messages)
        end        
      end
    end
    
    context "updating a note" do
      setup do
        @post = Factory.create(:post)
        @note = Factory.create(:note, :post => @post)
      end
      
      should "update the post's last_noted_at field" do
        assert_nil(@post.last_noted_at)
        @note.update_attributes(:x => 1000)
        @post.reload
        assert_equal(@post.last_noted_at, @note.updated_at)
      end
      
      should "create a version" do
        assert_difference("NoteVersion.count", 1) do
          @note.update_attributes(:body => "fafafa")
        end
        assert_equal(2, @note.versions.count)
        assert_equal("fafafa", @note.versions.last.body)
      end
      
      context "for a note-locked post" do
        setup do
          @post.update_attribute(:is_note_locked, true)
        end
        
        should "fail" do
          @note.update_attributes(:x => 1000)
          assert_equal(["Post is note locked"], @note.errors.full_messages)
        end
      end
    end
    
    context "when notes have been vandalized by one user" do
      setup do
        @vandal = Factory.create(:user)
        @note = Factory.create(:note, :x => 100, :y => 100)
        CurrentUser.scoped(@vandal, "127.0.0.1") do
          @note.update_attributes(:x => 2000, :y => 2000)
        end
      end
      
      context "the act of undoing all changes by that user" do
        should "revert any affected notes" do
          Note.undo_changes_by_user(@vandal.id)
          @note.reload
          assert_equal(100, @note.x)
          assert_equal(100, @note.y)
        end
      end
    end

    context "searching for a note" do
      setup do
        @note = Factory.create(:note, :body => "aaa")
      end
      
      context "where the body contains the string 'aaa'" do
        should "return a hit" do
          assert_equal(1, Note.body_matches("aaa").count)
        end
      end
      
      context "where the body contains the string 'bbb'" do
        should "return no hits" do
          assert_equal(0, Note.body_matches("bbb").count)
        end
      end
    end
  end
end
