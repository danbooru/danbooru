require File.dirname(__FILE__) + '/../test_helper'

class PostTest < ActiveSupport::TestCase
  context "During moderation a post" do
    setup do
      @post = Factory.create(:post)
      @user = Factory.create(:user)
    end
    
    should "be unapproved once and only once" do
      @post.unapprove!("bad", @user, "127.0.0.1")
      assert(@post.is_flagged?, "Post should be flagged.")
      assert_not_nil(@post.unapproval, "Post should have an unapproval record.")
      assert_equal("bad", @post.unapproval.reason)
      
      assert_raise(Unapproval::Error) {@post.unapprove!("bad", @user, "127.0.0.1")}
    end
    
    should "not unapprove if no reason is given" do
      assert_raise(Unapproval::Error) {@post.unapprove!("", @user, "127.0.0.1")}
    end
    
    should "be deleted" do
      @post.delete!
      assert(@post.is_deleted?, "Post should be deleted.")
    end
    
    should "be approved" do
      @post.approve!
      assert(!@post.is_pending?, "Post should not be pending.")
      
      @deleted_post = Factory.create(:post, :is_deleted => true)
      @deleted_post.approve!
      assert(!@post.is_deleted?, "Post should not be deleted.")
    end
  end
  
  context "A post version" do
    should "be created on any save" do
      @user = Factory.create(:user)
      @post = Factory.create(:post)
      assert_equal(1, @post.versions.size)
      
      @post.update_attributes(:rating => "e", :updater_id => @user.id, :updater_ip_addr => "125.0.0.0")
      assert_equal(2, @post.versions.size)
      assert_equal(@user.id, @post.versions.last.updater_id)
      assert_equal("125.0.0.0", @post.versions.last.updater_ip_addr)
    end
  end
  
  context "A post's tags" do
    setup do
      @post = Factory.create(:post)
    end
    
    should "have an array representation" do
      assert_equal(%w(tag1 tag2), @post.tag_array)
    end
    
    should "be counted" do
      @user = Factory.create(:user)
      @artist_tag = Factory.create(:artist_tag)
      @copyright_tag = Factory.create(:copyright_tag)
      @general_tag = Factory.create(:tag)
      @new_post = Factory.create(:post, :tag_string => "#{@artist_tag.name} #{@copyright_tag.name} #{@general_tag.name}")
      assert_equal(1, @new_post.tag_count_artist)
      assert_equal(1, @new_post.tag_count_copyright)
      assert_equal(1, @new_post.tag_count_general)
      assert_equal(0, @new_post.tag_count_character)
      assert_equal(3, @new_post.tag_count)

      @new_post.update_attributes(:tag_string => "babs", :updater_id => @user.id, :updater_ip_addr => "127.0.0.1")
      assert_equal(0, @new_post.tag_count_artist)
      assert_equal(0, @new_post.tag_count_copyright)
      assert_equal(1, @new_post.tag_count_general)
      assert_equal(0, @new_post.tag_count_character)
      assert_equal(1, @new_post.tag_count)
    end
    
    should "be merged with any changes that were made after loading the initial set of tags part 1" do
      @user = Factory.create(:user)
      @post = Factory.create(:post, :tag_string => "aaa bbb ccc")
            
      # user a adds <ddd>
      @post_edited_by_user_a = Post.find(@post.id)
      @post_edited_by_user_a.update_attributes(
        :updater_id => @user.id,
        :updater_ip_addr => "127.0.0.1",
        :old_tag_string => "aaa bbb ccc",
        :tag_string => "aaa bbb ccc ddd"
      )
      
      # user b removes <ccc> adds <eee>
      @post_edited_by_user_b = Post.find(@post.id)
      @post_edited_by_user_b.update_attributes(
        :updater_id => @user.id,
        :updater_ip_addr => "127.0.0.1",
        :old_tag_string => "aaa bbb ccc",
        :tag_string => "aaa bbb eee"
      )
      
      # final should be <aaa>, <bbb>, <ddd>, <eee>
      @final_post = Post.find(@post.id)      
      assert_equal(%w(aaa bbb ddd eee), Tag.scan_tags(@final_post.tag_string).sort)
    end

    should "be merged with any changes that were made after loading the initial set of tags part 2" do
      # This is the same as part 1, only the order of operations is reversed.
      # The results should be the same.
      
      @user = Factory.create(:user)
      @post = Factory.create(:post, :tag_string => "aaa bbb ccc")
            
      # user a removes <ccc> adds <eee>
      @post_edited_by_user_a = Post.find(@post.id)
      @post_edited_by_user_a.update_attributes(
        :updater_id => @user.id,
        :updater_ip_addr => "127.0.0.1",
        :old_tag_string => "aaa bbb ccc",
        :tag_string => "aaa bbb eee"
      )
      
      # user b adds <ddd>
      @post_edited_by_user_b = Post.find(@post.id)
      @post_edited_by_user_b.update_attributes(
        :updater_id => @user.id,
        :updater_ip_addr => "127.0.0.1",
        :old_tag_string => "aaa bbb ccc",
        :tag_string => "aaa bbb ccc ddd"
      )
      
      # final should be <aaa>, <bbb>, <ddd>, <eee>
      @final_post = Post.find(@post.id)      
      assert_equal(%w(aaa bbb ddd eee), Tag.scan_tags(@final_post.tag_string).sort)
    end
  end
  
  context "Adding a meta-tag" do
    setup do
      @post = Factory.create(:post)
    end

    should "be ignored" do
      @user = Factory.create(:user)
      
      @post.update_attributes(
        :updater_id => @user.id,
        :updater_ip_addr => "127.0.0.1",
        :tag_string => "aaa pool:1234 pool:test rating:s fav:bob"
      )
      assert_equal("aaa", @post.tag_string)
    end
  end
  
  context "Favoriting a post" do
    should "update the favorite string" do
      @user = Factory.create(:user)
      @post = Factory.create(:post)
      @post.add_favorite(@user.id)
      assert_equal("fav:#{@user.id}", @post.fav_string)
      
      @post.remove_favorite(@user.id)
      assert_equal("", @post.fav_string)
    end
  end
end
