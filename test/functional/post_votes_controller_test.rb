require 'test_helper'

class PostVotesControllerTest < ActionController::TestCase
  context "The post vote controller" do
    setup do
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @post = Factory.create(:post)
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "create action" do
      should "increment a post's score if the score is positive" do
        post :create, {:post_id => @post.id, :score => "up", :format => "js"}, {:user_id => @user.id}
        @post.reload
        assert_equal(1, @post.score)
      end
      
      context "for a post that has already been voted on" do
        setup do
          @post.vote!("up")
        end
        
        should "fail silently on an error" do
          assert_nothing_raised do
            post :create, {:post_id => @post.id, :score => "up", :format => "js"}, {:user_id => @user.id}
          end
        end
      end
    end
  end
end
