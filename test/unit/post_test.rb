require 'test_helper'

class PostTest < ActiveSupport::TestCase
  setup do
    user = Factory.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
    MEMCACHE.flush_all
  end
  
  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end
  
  context "Deletion:" do
    context "Deleting a post" do
      should "update the fast count" do
        post = Factory.create(:post, :tag_string => "aaa")
        assert_equal(1, Post.fast_count)
        assert_equal(1, Post.fast_count("aaa"))
        post.delete!
        assert_equal(0, Post.fast_count)
        assert_equal(0, Post.fast_count("aaa"))
      end
      
      should "toggle the is_deleted flag" do
        post = Factory.create(:post)
        assert_equal(false, post.is_deleted?)
        post.delete!
        assert_equal(true, post.is_deleted?)
      end
      
      should "decrement the tag counts" do
        post = Factory.create(:post, :tag_string => "aaa")
        assert_equal(1, Tag.find_by_name("aaa").post_count)
        post.delete!
        assert_equal(0, Tag.find_by_name("aaa").post_count)
      end
    end
  end
  
  context "Parenting:" do
    context "Assignining a parent to a post" do
      should "update the has_children flag on the parent" do
        p1 = Factory.create(:post)
        assert(!p1.has_children?, "Parent should not have any children")
        c1 = Factory.create(:post, :parent_id => p1.id)
        p1.reload
        assert(p1.has_children?, "Parent not updated after child was added")
      end
      
      should "update the has_children flag on the old parent" do
        p1 = Factory.create(:post)
        p2 = Factory.create(:post)
        c1 = Factory.create(:post, :parent_id => p1.id)
        c1.parent_id = p2.id
        c1.save
        p1.reload
        p2.reload
        assert(!p1.has_children?, "Old parent should not have a child")
        assert(p2.has_children?, "New parent should have a child")
      end

      should "validate that the parent exists" do
        post = Factory.build(:post, :parent_id => 1_000_000)
        post.save
        assert(post.errors[:parent].any?, "Parent should be invalid")
      end
      
      should "fail if the parent has a parent" do
        p1 = Factory.create(:post)
        c1 = Factory.create(:post, :parent_id => p1.id)
        c2 = Factory.build(:post, :parent_id => c1.id)
        c2.save
        assert(c2.errors[:parent].any?, "Parent should be invalid")
      end
    end
        
    context "Destroying a post with a parent" do
      should "reassign favorites to the parent" do
        p1 = Factory.create(:post)
        c1 = Factory.create(:post, :parent_id => p1.id)
        user = Factory.create(:user)
        c1.add_favorite!(user)
        c1.delete!
        p1.reload
        assert(!Favorite.exists?(:post_id => c1.id, :user_id => user.id))
        assert(Favorite.exists?(:post_id => p1.id, :user_id => user.id))
      end

      should "update the parent's has_children flag" do
        p1 = Factory.create(:post)
        c1 = Factory.create(:post, :parent_id => p1.id)
        c1.delete!
        p1.reload
        assert(!p1.has_children?, "Parent should not have children")
      end
    end
    
    context "Destroying a post with" do
      context "one child" do
        should "remove the parent of that child" do
          p1 = Factory.create(:post)
          c1 = Factory.create(:post, :parent_id => p1.id)
          p1.delete!
          c1.reload
          assert_nil(c1.parent)
        end
      end
      
      context "two or more children" do
        should "reparent all children to the first child" do
          p1 = Factory.create(:post)
          c1 = Factory.create(:post, :parent_id => p1.id)
          c2 = Factory.create(:post, :parent_id => p1.id)
          c3 = Factory.create(:post, :parent_id => p1.id)
          p1.delete!
          c1.reload
          c2.reload
          c3.reload
          assert_nil(c1.parent)
          assert_equal(c1.id, c2.parent_id)
          assert_equal(c1.id, c3.parent_id)
        end
      end
    end
    
    context "Undestroying a post with a parent" do
      should "not preserve the parent's has_children flag" do
        p1 = Factory.create(:post)
        c1 = Factory.create(:post, :parent_id => p1.id)
        c1.delete!
        c1.undelete!
        p1.reload
        assert_nil(p1.parent_id)
        assert(!p1.has_children?, "Parent should not have children")
      end
    end
  end

  context "Moderation:" do
    context "A deleted post" do
      setup do
        @post = Factory.create(:post, :is_deleted => true)
      end
      
      should "be appealed" do
        assert_difference("PostAppeal.count", 1) do
          @post.appeal!("xxx")
        end
        assert(@post.is_deleted?, "Post should still be deleted")
        assert_equal(1, @post.appeals.count)
      end
    end
    
    context "An approved post" do
      should "be flagged" do
        post = Factory.create(:post)
        assert_difference("PostFlag.count", 1) do
          post.flag!("bad")
        end
        assert(post.is_flagged?, "Post should be flagged.")
        assert_equal(1, post.flags.count)
      end
  
      should "not be flagged if no reason is given" do
        post = Factory.create(:post)
        assert_difference("PostFlag.count", 0) do
          assert_raises(PostFlag::Error) do
            post.flag!("")
          end
        end
      end
    end
    
    context "An unapproved post" do      
      should "preserve the approver's identity when approved" do
        post = Factory.create(:post, :is_pending => true)
        post.approve!
        assert_equal(post.approver_id, CurrentUser.id)
      end
      
      context "that was previously approved by person X" do
        should "not allow person X to reapprove that post" do
          user = Factory.create(:janitor_user, :name => "xxx")
          post = Factory.create(:post, :approver_id => user.id)
          post.flag!("bad")
          CurrentUser.scoped(user, "127.0.0.1") do
            assert_raises(Post::ApprovalError) do
              post.approve!
            end
          end
        end
      end
      
      context "that has been reapproved" do
        should "no longer be flagged or pending" do
          post = Factory.create(:post)
          post.flag!("bad")
          post.approve!
          assert(post.errors.empty?, post.errors.full_messages.join(", "))
          post.reload
          assert_equal(false, post.is_flagged?)
          assert_equal(false, post.is_pending?)
        end
      end
    end
  end

  context "Tagging:" do
    context "A post" do
      should "have an array representation of its tags" do
        post = Factory.create(:post)
        post.set_tag_string("aaa bbb")
        assert_equal(%w(aaa bbb), post.tag_array)
        assert_equal(%w(tag1 tag2), post.tag_array_was)
      end
      
      context "that has been updated" do
        should "reset its tag array cache" do
          post = Factory.create(:post, :tag_string => "aaa bbb ccc")
          user = Factory.create(:user)
          assert_equal(%w(aaa bbb ccc), post.tag_array)
          post.tag_string = "ddd eee fff"
          post.tag_string = "ddd eee fff"
          post.save
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
          post3.tag_string = "xxx"
          post3.save
          assert_equal(1, Tag.find_by_name("aaa").post_count)
          assert_equal(2, Tag.find_by_name("bbb").post_count)
          assert_equal(2, Tag.find_by_name("ccc").post_count)      
          assert_equal(1, Tag.find_by_name("ddd").post_count)      
          assert_equal(0, Tag.find_by_name("eee").post_count)
          assert_equal(1, Tag.find_by_name("xxx").post_count)
        end
        
        should "update its tag counts" do
          artist_tag = Factory.create(:artist_tag)
          copyright_tag = Factory.create(:copyright_tag)
          general_tag = Factory.create(:tag)
          new_post = Factory.create(:post, :tag_string => "#{artist_tag.name} #{copyright_tag.name} #{general_tag.name}")
          assert_equal(1, new_post.tag_count_artist)
          assert_equal(1, new_post.tag_count_copyright)
          assert_equal(1, new_post.tag_count_general)
          assert_equal(0, new_post.tag_count_character)
          assert_equal(3, new_post.tag_count)

          new_post.tag_string = "babs"
          new_post.save
          assert_equal(0, new_post.tag_count_artist)
          assert_equal(0, new_post.tag_count_copyright)
          assert_equal(1, new_post.tag_count_general)
          assert_equal(0, new_post.tag_count_character)
          assert_equal(1, new_post.tag_count)
        end
        
        should "merge any changes that were made after loading the initial set of tags part 1" do
          post = Factory.create(:post, :tag_string => "aaa bbb ccc")

          # user a adds <ddd>
          post_edited_by_user_a = Post.find(post.id)
          post_edited_by_user_a.old_tag_string = "aaa bbb ccc"
          post_edited_by_user_a.tag_string = "aaa bbb ccc ddd"
          post_edited_by_user_a.save

          # user b removes <ccc> adds <eee>
          post_edited_by_user_b = Post.find(post.id)
          post_edited_by_user_b.old_tag_string = "aaa bbb ccc"
          post_edited_by_user_b.tag_string = "aaa bbb eee"
          post_edited_by_user_b.save

          # final should be <aaa>, <bbb>, <ddd>, <eee>
          final_post = Post.find(post.id)      
          assert_equal(%w(aaa bbb ddd eee), Tag.scan_tags(final_post.tag_string).sort)
        end
        
        should "merge any changes that were made after loading the initial set of tags part 2" do
          # This is the same as part 1, only the order of operations is reversed.
          # The results should be the same.

          post = Factory.create(:post, :tag_string => "aaa bbb ccc")

          # user a removes <ccc> adds <eee>
          post_edited_by_user_a = Post.find(post.id)
          post_edited_by_user_a.old_tag_string = "aaa bbb ccc"
          post_edited_by_user_a.tag_string = "aaa bbb eee"
          post_edited_by_user_a.save

          # user b adds <ddd>
          post_edited_by_user_b = Post.find(post.id)
          post_edited_by_user_b.old_tag_string = "aaa bbb ccc"
          post_edited_by_user_b.tag_string = "aaa bbb ccc ddd"
          post_edited_by_user_b.save

          # final should be <aaa>, <bbb>, <ddd>, <eee>
          final_post = Post.find(post.id)      
          assert_equal(%w(aaa bbb ddd eee), Tag.scan_tags(final_post.tag_string).sort)
        end
      end

      context "that has been tagged with a metatag" do
        should "not include the metatag in its tag string" do
          post = Factory.create(:post)
          post.tag_string = "aaa pool:1234 pool:test rating:s fav:bob"
          post.save
          assert_equal("aaa", post.tag_string)
        end
      end
    end
  end
  
  context "Favorites:" do
    context "Adding a post to a user's favorites" do
      should "update the fav strings ont he post" do
        user = Factory.create(:user)
        post = Factory.create(:post)
        post.add_favorite!(user)
        post.reload
        assert_equal("fav:#{user.id}", post.fav_string)
        assert(Favorite.exists?(:user_id => user.id, :post_id => post.id))

        post.add_favorite!(user)
        post.reload
        assert_equal("fav:#{user.id}", post.fav_string)
        assert(Favorite.exists?(:user_id => user.id, :post_id => post.id))

        post.remove_favorite!(user)
        post.reload
        assert_equal("", post.fav_string)
        assert(!Favorite.exists?(:user_id => user.id, :post_id => post.id))
      
        post.remove_favorite!(user)
        post.reload
        assert_equal("", post.fav_string)
        assert(!Favorite.exists?(:user_id => user.id, :post_id => post.id))
      end
    end
  end
  
  context "Pools:" do
    context "Removing a post from a pool" do
      should "update the post's pool string" do
        post = Factory.create(:post)
        pool = Factory.create(:pool)
        post.add_pool!(pool)
        post.remove_pool!(pool)
        post.reload
        assert_equal("", post.pool_string)
        post.remove_pool!(pool)
        post.reload
        assert_equal("", post.pool_string)
      end
    end
    
    context "Adding a post to a pool" do
      should "update the post's pool string" do
        post = Factory.create(:post)
        pool = Factory.create(:pool)
        post.add_pool!(pool)
        post.reload
        assert_equal("pool:#{pool.id}", post.pool_string)
        post.add_pool!(pool)
        post.reload
        assert_equal("pool:#{pool.id}", post.pool_string)
        post.remove_pool!(pool)
        post.reload
        assert_equal("", post.pool_string)
      end
    end
  end
  
  context "Uploading:" do
    context "Uploading a post" do
      should "capture who uploaded the post" do
        post = Factory.create(:post)
        user1 = Factory.create(:user)
        user2 = Factory.create(:user)
        user3 = Factory.create(:user)

        post.uploader = user1
        assert_equal(user1.id, post.uploader_id)

        post.uploader_id = user2.id
        assert_equal(user2.id, post.uploader_id)
        assert_equal(user2.id, post.uploader_id)
        assert_equal(user2.name, post.uploader_name)
      end
    end
  end

  context "Searching:" do
    should "return posts for 1 tag" do
      post1 = Factory.create(:post, :tag_string => "aaa")
      post2 = Factory.create(:post, :tag_string => "aaa bbb")
      post3 = Factory.create(:post, :tag_string => "bbb ccc")
      relation = Post.tag_match("aaa")
      assert_equal(2, relation.count)
      assert_equal(post2.id, relation.all[0].id)
      assert_equal(post1.id, relation.all[1].id)
    end

    should "return posts for a 2 tag join" do
      post1 = Factory.create(:post, :tag_string => "aaa")
      post2 = Factory.create(:post, :tag_string => "aaa bbb")
      post3 = Factory.create(:post, :tag_string => "bbb ccc")
      relation = Post.tag_match("aaa bbb")
      assert_equal(1, relation.count)
      assert_equal(post2.id, relation.first.id)
    end
  
    should "return posts for 1 tag with exclusion" do
      post1 = Factory.create(:post, :tag_string => "aaa")
      post2 = Factory.create(:post, :tag_string => "aaa bbb")
      post3 = Factory.create(:post, :tag_string => "bbb ccc")
      relation = Post.tag_match("aaa -bbb")
      assert_equal(1, relation.count)
      assert_equal(post1.id, relation.first.id)
    end
  
    should "return posts for 1 tag with a pattern" do
      post1 = Factory.create(:post, :tag_string => "aaa")
      post2 = Factory.create(:post, :tag_string => "aaab bbb")
      post3 = Factory.create(:post, :tag_string => "bbb ccc")
      relation = Post.tag_match("a*")
      assert_equal(2, relation.count)
      assert_equal(post2.id, relation.all[0].id)
      assert_equal(post1.id, relation.all[1].id)          
    end
  
    should "return posts for 2 tags, one with a pattern" do
      post1 = Factory.create(:post, :tag_string => "aaa")
      post2 = Factory.create(:post, :tag_string => "aaab bbb")
      post3 = Factory.create(:post, :tag_string => "bbb ccc")
      relation = Post.tag_match("a* bbb")
      assert_equal(1, relation.count)
      assert_equal(post2.id, relation.first.id)
    end
  
    should "return posts for the <id> metatag" do
      post1 = Factory.create(:post)
      post2 = Factory.create(:post)
      post3 = Factory.create(:post)
      relation = Post.tag_match("id:#{post2.id}")
      assert_equal(1, relation.count)
      assert_equal(post2.id, relation.first.id)
      relation = Post.tag_match("id:>#{post2.id}")
      assert_equal(1, relation.count)
      assert_equal(post3.id, relation.first.id)
      relation = Post.tag_match("id:<#{post2.id}")
      assert_equal(1, relation.count)
      assert_equal(post1.id, relation.first.id)
    end
  
    should "return posts for the <fav> metatag" do
      post1 = Factory.create(:post)
      post2 = Factory.create(:post)
      post3 = Factory.create(:post)
      user = Factory.create(:user)
      post1.add_favorite!(user)
      relation = Post.tag_match("fav:#{user.name}")
      assert_equal(1, relation.count)
      assert_equal(post1.id, relation.first.id)
    end
  
    should "return posts for the <pool> metatag" do
      post1 = Factory.create(:post)
      post2 = Factory.create(:post)
      post3 = Factory.create(:post)
      pool = Factory.create(:pool)
      post1.add_pool!(pool)
      relation = Post.tag_match("pool:#{pool.name}")
      assert_equal(1, relation.count)
      assert_equal(post1.id, relation.first.id)
    end
  
    should "return posts for the <uploader> metatag" do
      second_user = Factory.create(:user)
      post1 = Factory.create(:post, :uploader => CurrentUser.user)
      
      assert_equal(CurrentUser.id, post1.uploader_id)
      
      CurrentUser.scoped(second_user, "127.0.0.2") do
        post2 = Factory.create(:post)
        post3 = Factory.create(:post)
      end

      relation = Post.tag_match("uploader:#{CurrentUser.user.name}")
      assert_equal(1, relation.count)
      assert_equal(post1.id, relation.first.id)
    end
  
    should "return posts for a list of md5 hashes" do
      post1 = Factory.create(:post, :md5 => "abcd")
      post2 = Factory.create(:post)
      post3 = Factory.create(:post)
      relation = Post.tag_match("md5:abcd")
      assert_equal(1, relation.count)
      assert_equal(post1.id, relation.first.id)
    end
    
    should "return posts for a source search" do
      post1 = Factory.create(:post, :source => "abcd")
      post2 = Factory.create(:post, :source => "abcdefg")
      post3 = Factory.create(:post, :source => "xyz")
      relation = Post.tag_match("source:abcde")
      assert_equal(1, relation.count)
      assert_equal(post2.id, relation.first.id)
    end
  
    should "return posts for a tag subscription search" do
      post1 = Factory.create(:post, :tag_string => "aaa")
      sub = Factory.create(:tag_subscription, :tag_query => "aaa", :name => "zzz")
      TagSubscription.process_all
      relation = Post.tag_match("sub:#{CurrentUser.name}")
      assert_equal(1, relation.count)
    end
  
    should "return posts for a particular rating" do
      post1 = Factory.create(:post, :rating => "s")
      post2 = Factory.create(:post, :rating => "q")
      post3 = Factory.create(:post, :rating => "e")
      relation = Post.tag_match("rating:e")
      assert_equal(1, relation.count)
      assert_equal(post3.id, relation.first.id)
    end
  
    should "return posts for a particular negated rating" do
      post1 = Factory.create(:post, :rating => "s")
      post2 = Factory.create(:post, :rating => "s")
      post3 = Factory.create(:post, :rating => "e")
      relation = Post.tag_match("-rating:s")
      assert_equal(1, relation.count)
      assert_equal(post3.id, relation.first.id)
    end
  
    should "return posts ordered by a particular attribute" do
      post1 = Factory.create(:post, :rating => "s")
      post2 = Factory.create(:post, :rating => "s")
      post3 = Factory.create(:post, :rating => "e", :score => 5, :image_width => 1000)
      relation = Post.tag_match("order:id")
      assert_equal(post1.id, relation.first.id)
      relation = Post.tag_match("order:mpixels")
      assert_equal(post3.id, relation.first.id)
      relation = Post.tag_match("order:landscape")
      assert_equal(post3.id, relation.first.id)      
    end
  end

  context "Voting:" do
    should "not allow duplicate votes" do
      user = Factory.create(:user)
      post = Factory.create(:post)
      CurrentUser.scoped(user, "127.0.0.1") do
        assert_nothing_raised {post.vote!("up")}
        assert_raise(PostVote::Error) {post.vote!("up")}
        post.reload
        assert_equal(1, PostVote.count)
        assert_equal(1, post.score)
      end
    end
  end

  context "Counting:" do
    context "Creating a post" do
      should "increment the post count" do
        assert_equal(0, Post.fast_count(""))
        post = Factory.create(:post, :tag_string => "aaa bbb")
        assert_equal(1, Post.fast_count(""))
        assert_equal(1, Post.fast_count("aaa"))
        assert_equal(1, Post.fast_count("bbb"))
        assert_equal(0, Post.fast_count("ccc"))
      
        post.tag_string = "ccc"
        post.save
      
        assert_equal(1, Post.fast_count(""))
        assert_equal(0, Post.fast_count("aaa"))
        assert_equal(0, Post.fast_count("bbb"))
        assert_equal(1, Post.fast_count("ccc"))
      end
    end
  end

  context "Reverting: " do
    context "a post that has been updated" do
      setup do
        @post = Factory.create(:post, :rating => "q", :tag_string => "aaa")
        @post.update_attributes(:tag_string => "aaa bbb ccc ddd")
        @post.update_attributes(:tag_string => "bbb xxx yyy", :source => "xyz")
        @post.update_attributes(:tag_string => "bbb mmm yyy", :source => "abc")
      end
    
      context "and then reverted to an early version" do
        setup do
          @post.revert_to(@post.versions[1])
        end
        
        should "correctly revert all fields" do
          assert_equal("aaa bbb ccc ddd", @post.tag_string)
          assert_equal(nil, @post.source)
          assert_equal("q", @post.rating)
        end
      end
      
      context "and then reverted to a later version" do
        setup do
          @post.revert_to(@post.versions[-2])
        end
        
        should "correctly revert all fields" do
          assert_equal("bbb xxx yyy", @post.tag_string)
          assert_equal("xyz", @post.source)
          assert_equal("q", @post.rating)
        end
      end
    end
  end
end
