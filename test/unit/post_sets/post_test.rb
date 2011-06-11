require_relative '../../test_helper'

module PostSets
  class PostTest < ActiveSupport::TestCase
    context "In all cases" do
      setup do
        @user = Factory.create(:user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        MEMCACHE.flush_all

        @post_1 = Factory.create(:post, :tag_string => "a")
        @post_2 = Factory.create(:post, :tag_string => "b")
        @post_3 = Factory.create(:post, :tag_string => "c")
      end
      
      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end
      
      context "a sequential set for the 'a' tag query" do
        setup do
          @post_4 = Factory.create(:post, :tag_string => "a")
          @post_5 = Factory.create(:post, :tag_string => "a")
        end
        
        context "with no before_id parameter" do
          setup do
            @set = PostSets::Base.new(:tags => "a")
            @set.extend(PostSets::Sequential)
            @set.extend(PostSets::Post)
            @set.stubs(:limit).returns(1)
          end
          
          should "return the first element" do
            assert_equal(@post_5.id, @set.posts.first.id)
          end
        end
        
        context "with a before_id parameter for the first element" do
          setup do
            @set = PostSets::Base.new(:tags => "a", :before_id => @post_5.id)
            @set.extend(PostSets::Sequential)
            @set.extend(PostSets::Post)
            @set.stubs(:limit).returns(1)
          end
          
          should "return the second element" do
            assert_equal(@post_4.id, @set.posts.first.id)
          end
        end

        context "with an after_id parameter for the second element" do
          setup do
            @set = PostSets::Base.new(:tags => "a", :after_id => @post_4.id)
            @set.extend(PostSets::Sequential)
            @set.extend(PostSets::Post)
            @set.stubs(:limit).returns(1)
          end
          
          should "return the first element" do
            assert_equal(@post_5.id, @set.posts.first.id)
          end
        end
      end
      
      context "a new numbered set for the 'a b' tag query" do
        setup do
          @set = PostSets::Base.new(:tags => "a b")
          @set.extend(PostSets::Numbered)
          @set.extend(PostSets::Post)
        end
        
        should "know it isn't a single tag" do
          assert(!@set.is_single_tag?)
        end
      end
      
      context "a new numbered set going to the 1,001st page" do
        setup do
          @set = PostSets::Base.new(:tags => "a", :page => 1_001)
          @set.extend(PostSets::Numbered)
          @set.extend(PostSets::Post)
        end
        
        should "not validate" do
          assert_raises(PostSets::Error) do
            @set.validate
          end
        end
      end
      
      context "a new numbered set for the 'a b c' tag query" do
        setup do
          @set = PostSets::Base.new(:tags => "a b c")
          @set.extend(PostSets::Numbered)
          @set.extend(PostSets::Post)
        end
        
        context "for a non-privileged user" do
          should "not validate" do
            assert_raises(PostSets::Error) do
              @set.validate
            end
          end
        end
        
        context "for a privileged user" do
          setup do
            CurrentUser.user = Factory.create(:privileged_user)
          end
          
          should "not validate" do
            assert_nothing_raised do
              @set.validate
            end
          end
        end
      end
      
      context "a new numbered set for the 'a' tag query" do
        setup do
          @set = PostSets::Base.new(:tags => "A")
          @set.extend(PostSets::Numbered)
          @set.extend(PostSets::Post)
        end
        
        should "validate" do
          assert_nothing_raised do
            @set.validate
          end
        end
        
        should "know it is a single tag" do
          assert(@set.is_single_tag?)
        end
        
        should "normalize its tag query" do
          assert_equal("a", @set.tag_string)
        end
        
        should "find the count" do
          assert_equal(1, @set.count)
        end
        
        should "find the posts" do
          assert_equal(@post_1.id, @set.posts.first.id)
        end
        
        context "that has a matching wiki page" do
          setup do
            @wiki_page = Factory.create(:wiki_page, :title => "a")
          end
          
          should "find the wiki page" do
            assert_not_nil(@set.wiki_page)
            assert_equal(@wiki_page.id, @set.wiki_page.id)
          end
        end
        
        context "that has a matching artist" do
          setup do
            @artist = Factory.create(:artist, :name => "a")
          end
          
          should "find the artist" do
            assert_not_nil(@set.artist)
            assert_equal(@artist.id, @set.artist.id)
          end
        end
      end
    end
  end
end
