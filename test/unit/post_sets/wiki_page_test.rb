require 'test_helper'

module PostSets
  class WikiPageTest < ActiveSupport::TestCase
    context "In all cases" do
      setup do
        @user = Factory.create(:user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        MEMCACHE.flush_all

        @wiki_page = Factory.create(:wiki_page, :title => "a")
        @post_1 = Factory.create(:post, :tag_string => "a")
        @post_2 = Factory.create(:post, :tag_string => "a")
        @post_3 = Factory.create(:post, :tag_string => "a")
      end
      
      context "a numbered wiki page set" do
        setup do
          @set = PostSets::Base.new(:page => 2, :id => @wiki_page.id)
          @set.extend(PostSets::Numbered)
          @set.extend(PostSets::WikiPage)
          @set.stubs(:limit).returns(1)
        end
        
        should "return the count" do
          assert_equal(3, @set.count)
        end
      end
      
      context "a sequential wiki page set" do
        context "with a before_id for the first element" do
          setup do
            @set = PostSets::Base.new(:id => @wiki_page.id, :before_id => @post_3.id)
            @set.extend(PostSets::Sequential)
            @set.extend(PostSets::WikiPage)
            @set.stubs(:limit).returns(1)
          end
          
          should "return the second element" do
            assert_equal(@post_2.id, @set.posts.first.id)
          end
        end
        
        context "with an after_id for the second element" do
          setup do
            @set = PostSets::Base.new(:after_id => @post_2.id, :id => @wiki_page.id)
            @set.extend(PostSets::Sequential)
            @set.extend(PostSets::WikiPage)
            @set.stubs(:limit).returns(1)
          end
          
          should "return the first element" do
            assert_equal(@post_3.id, @set.posts.first.id)
          end
        end
      end
      
      context "a numbered wiki page set for page 2" do
        setup do
          @set = PostSets::Base.new(:page => 2, :id => @wiki_page.id)
          @set.extend(PostSets::Numbered)
          @set.extend(PostSets::WikiPage)
          @set.stubs(:limit).returns(1)
        end
        
        should "return the second element" do
          assert_equal(@post_2.id, @set.posts.first.id)
        end
      end
    end
  end
end
