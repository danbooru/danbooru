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
      @post.set_tag_string("aaa bbb")
      assert_equal(%w(aaa bbb), @post.tag_array)
      assert_equal(%w(tag1 tag2), @post.tag_array_was)
    end

    should "reset the tag array cache when updated" do
      post = Factory.create(:post, :tag_string => "aaa bbb ccc")
      user = Factory.create(:user)
      assert_equal(%w(aaa bbb ccc), post.tag_array)
      post.tag_string = "ddd eee fff"
      post.update_attributes(
        :updater_id => user.id,
        :updater_ip_addr => "127.0.0.1",
        :tag_string => "ddd eee fff"
      )
      assert_equal("ddd eee fff", post.tag_string)
      assert_equal(%w(ddd eee fff), post.tag_array)
    end

    should "create the actual tag records" do
      assert_difference("Tag.count", 3) do
        post = Factory.create(:post, :tag_string => "aaa bbb ccc")
      end
    end

    should "update the post counts of relevant tag records" do
      post1 = Factory.create(:post, :tag_string => "aaa bbb ccc")
      post2 = Factory.create(:post, :tag_string => "bbb ccc ddd")
      post3 = Factory.create(:post, :tag_string => "ccc ddd eee")
      assert_equal(1, Tag.find_by_name("aaa").post_count)
      assert_equal(2, Tag.find_by_name("bbb").post_count)
      assert_equal(3, Tag.find_by_name("ccc").post_count)
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
      @post.add_favorite(@user)
      assert_equal("fav:#{@user.name}", @post.fav_string)
    
      @post.remove_favorite(@user)
      assert_equal("", @post.fav_string)
    end
  end
  
  context "Pooling a post" do
    should "work" do
      post = Factory.create(:post)
      pool = Factory.create(:pool)
      post.add_pool(pool)
      assert_equal("pool:#{pool.name}", post.pool_string)
      post.remove_pool(pool)
      assert_equal("", post.pool_string)
    end
  end
  
  context "A post's uploader" do
    should "be defined" do
      post = Factory.create(:post)
      user1 = Factory.create(:user)
      user2 = Factory.create(:user)
      user3 = Factory.create(:user)
      
      post.uploader = user1
      assert_equal("uploader:#{user1.name}", post.uploader_string)
      
      post.uploader_id = user2.id
      assert_equal("uploader:#{user2.name}", post.uploader_string)
      assert_equal(user2.id, post.uploader_id)
      assert_equal(user2.name, post.uploader_name)
    end
  end

  context "A tag search" do
    should "return posts for 1 tag" do
      post1 = Factory.create(:post, :tag_string => "aaa")
      post2 = Factory.create(:post, :tag_string => "aaa bbb")
      post3 = Factory.create(:post, :tag_string => "bbb ccc")
      relation = Post.find_by_tags("aaa")
      assert_equal(2, relation.count)
      assert_equal(post2.id, relation.all[0].id)
      assert_equal(post1.id, relation.all[1].id)
    end

    should "return posts for a 2 tag join" do
      post1 = Factory.create(:post, :tag_string => "aaa")
      post2 = Factory.create(:post, :tag_string => "aaa bbb")
      post3 = Factory.create(:post, :tag_string => "bbb ccc")
      relation = Post.find_by_tags("aaa bbb")
      assert_equal(1, relation.count)
      assert_equal(post2.id, relation.first.id)
    end
  
    should "return posts for 1 tag with exclusion" do
      post1 = Factory.create(:post, :tag_string => "aaa")
      post2 = Factory.create(:post, :tag_string => "aaa bbb")
      post3 = Factory.create(:post, :tag_string => "bbb ccc")
      relation = Post.find_by_tags("aaa -bbb")
      assert_equal(1, relation.count)
      assert_equal(post1.id, relation.first.id)
    end
  
    should "return posts for 1 tag with a pattern" do
      post1 = Factory.create(:post, :tag_string => "aaa")
      post2 = Factory.create(:post, :tag_string => "aaab bbb")
      post3 = Factory.create(:post, :tag_string => "bbb ccc")
      relation = Post.find_by_tags("a*")
      assert_equal(2, relation.count)
      assert_equal(post2.id, relation.all[0].id)
      assert_equal(post1.id, relation.all[1].id)          
    end
  
    should "return posts for 2 tags, one with a pattern" do
      post1 = Factory.create(:post, :tag_string => "aaa")
      post2 = Factory.create(:post, :tag_string => "aaab bbb")
      post3 = Factory.create(:post, :tag_string => "bbb ccc")
      relation = Post.find_by_tags("a* bbb")
      assert_equal(1, relation.count)
      assert_equal(post2.id, relation.first.id)
    end
  
    should "return posts for the <id> metatag" do
      post1 = Factory.create(:post)
      post2 = Factory.create(:post)
      post3 = Factory.create(:post)
      relation = Post.find_by_tags("id:#{post2.id}")
      assert_equal(1, relation.count)
      assert_equal(post2.id, relation.first.id)
      relation = Post.find_by_tags("id:>#{post2.id}")
      assert_equal(1, relation.count)
      assert_equal(post3.id, relation.first.id)
      relation = Post.find_by_tags("id:<#{post2.id}")
      assert_equal(1, relation.count)
      assert_equal(post1.id, relation.first.id)
    end
  
    should "return posts for the <fav> metatag" do
      post1 = Factory.create(:post)
      post2 = Factory.create(:post)
      post3 = Factory.create(:post)
      user = Factory.create(:user)
      post1.add_favorite(user)
      post1.save
      relation = Post.find_by_tags("fav:#{user.name}")
      assert_equal(1, relation.count)
      assert_equal(post1.id, relation.first.id)
    end
  
    should "return posts for the <pool> metatag" do
      post1 = Factory.create(:post)
      post2 = Factory.create(:post)
      post3 = Factory.create(:post)
      pool = Factory.create(:pool)
      post1.add_pool(pool)
      post1.save
      relation = Post.find_by_tags("pool:#{pool.name}")
      assert_equal(1, relation.count)
      assert_equal(post1.id, relation.first.id)
    end
  
    should "return posts for the <uploader> metatag" do
      user = Factory.create(:user)
      post1 = Factory.create(:post, :uploader => user)
      post2 = Factory.create(:post)
      post3 = Factory.create(:post)
      assert_equal("uploader:#{user.name}", post1.uploader_string)
      relation = Post.find_by_tags("uploader:#{user.name}")
      assert_equal(1, relation.count)
      assert_equal(post1.id, relation.first.id)
    end
  
    should "return posts for a list of md5 hashes" do
      post1 = Factory.create(:post, :md5 => "abcd")
      post2 = Factory.create(:post)
      post3 = Factory.create(:post)
      relation = Post.find_by_tags("md5:abcd")
      assert_equal(1, relation.count)
      assert_equal(post1.id, relation.first.id)
    end
  
    should "filter out deleted posts by default" do
      post1 = Factory.create(:post, :is_deleted => true)
      post2 = Factory.create(:post, :is_deleted => true)
      post3 = Factory.create(:post, :is_deleted => false)
      relation = Post.find_by_tags("")
      assert_equal(1, relation.count)
      assert_equal(post3.id, relation.first.id)
    end
  
    should "return posts for a particular status" do
      post1 = Factory.create(:post, :is_deleted => true)
      post2 = Factory.create(:post, :is_deleted => false)
      post3 = Factory.create(:post, :is_deleted => false)
      relation = Post.find_by_tags("status:deleted")
      assert_equal(1, relation.count)
      assert_equal(post1.id, relation.first.id)
    end
  
    should "return posts for a source search" do
      post1 = Factory.create(:post, :source => "abcd")
      post2 = Factory.create(:post, :source => "abcdefg")
      post3 = Factory.create(:post, :source => "xyz")
      relation = Post.find_by_tags("source:abcde")
      assert_equal(1, relation.count)
      assert_equal(post2.id, relation.first.id)
    end
  
    should "return posts for a tag subscription search"
  
    should "return posts for a particular rating" do
      post1 = Factory.create(:post, :rating => "s")
      post2 = Factory.create(:post, :rating => "q")
      post3 = Factory.create(:post, :rating => "e")
      relation = Post.find_by_tags("rating:e")
      assert_equal(1, relation.count)
      assert_equal(post3.id, relation.first.id)
    end
  
    should "return posts for a particular negated rating" do
      post1 = Factory.create(:post, :rating => "s")
      post2 = Factory.create(:post, :rating => "s")
      post3 = Factory.create(:post, :rating => "e")
      relation = Post.find_by_tags("-rating:s")
      assert_equal(1, relation.count)
      assert_equal(post3.id, relation.first.id)
    end
  
    should "return posts ordered by a particular attribute" do
      post1 = Factory.create(:post, :rating => "s")
      post2 = Factory.create(:post, :rating => "s")
      post3 = Factory.create(:post, :rating => "e", :score => 5, :image_width => 1000)
      relation = Post.find_by_tags("order:id")
      assert_equal(post1.id, relation.first.id)
      relation = Post.find_by_tags("order:mpixels")
      assert_equal(post3.id, relation.first.id)
      relation = Post.find_by_tags("order:landscape")
      assert_equal(post3.id, relation.first.id)      
    end
  end
end
