require File.dirname(__FILE__) + '/../test_helper'

class NoteTest < ActiveSupport::TestCase
  context "A note" do
    setup do
      MEMCACHE.flush_all
    end
    
    should "create versions" do
      note = nil
      assert_difference("NoteVersion.count") do
        note = Factory.create(:note)
      end
      version = NoteVersion.last
      assert_equal(note.body, version.body)      
      assert_difference("NoteVersion.count") do
        note.update_attributes(:updater_id => note.creator_id, :updater_ip_addr => "127.0.0.1", :body => "fafafa")
      end
      version = NoteVersion.last
      assert_equal("fafafa", version.body)
    end
    
    should "allow undoing any change from a user" do
      vandal = Factory.create(:user)
      reverter = Factory.create(:user)
      note = Factory.create(:note, :x => 100, :y => 100)
      note.update_attributes(:x => 2000, :y => 2000, :updater_id => vandal.id, :updater_ip_addr => "127.0.0.1")
      note.reload
      assert_equal(2000, note.x)
      assert_equal(2000, note.y)
      Note.undo_changes_by_user(vandal.id, reverter.id, "127.0.0.1")
      note.reload
      assert_equal(100, note.x)
      assert_equal(100, note.y)
    end
    
    should "not validate if the post is note locked" do
      post = Factory.create(:post, :is_note_locked => true)
      note = Factory.build(:note, :post => post)
      assert_difference("Note.count", 0) do
        note.save
      end
      assert(note.errors.any?)
    end
    
    should "update the post when saved" do
      post = Factory.create(:post)
      assert_nil(post.last_noted_at)
      note = Factory.create(:note, :post => post)
      post.reload
      assert_not_nil(post.last_noted_at)
    end
    
    should "know when the post is note locked" do
      post = Factory.create(:post, :is_note_locked => true)
      note = Factory.build(:note, :post => post)
      assert(note.is_locked?)
    end
    
    should "return hits when searched" do
      notes = []
      notes << Factory.create(:note, :body => "aaa bbb ccc")
      notes << Factory.create(:note, :body => "bbb ccc ddd", :is_active => false)
      notes << Factory.create(:note, :body => "eee")
      results = Note.build_relation(:query => "bbb").all
      assert_equal(2, results.size)
      results = Note.build_relation(:query => "bbb", :status => "Active").all
      assert_equal(1, results.size)
      assert_equal(notes[0].id, results[0].id)
    end
  end
end
