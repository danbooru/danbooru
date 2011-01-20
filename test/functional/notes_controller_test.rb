require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  context "The notes controller" do
    setup do
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @post = Factory.create(:post)
    end
    
    teardown do
      CurrentUser.user = nil
    end
    
    context "index action" do
      setup do
        Factory.create(:note)
      end
      
      should "list all notes" do
        get :index
        assert_response :success
      end
      
      should "list all notes (with search)" do
        get :index, {:search => {:body_matches => "abc"}}
        assert_response :success
      end
    end
    
    context "show action" do
      setup do
        @note = Factory.create(:note)
      end
      
      should "render" do
        get :show, {:id => @note.id}
        assert_response :success
      end
    end
    
    context "create action" do
      should "create a note" do
        assert_difference("Note.count", 1) do
          post :create, {:note => {:x => 100, :y => 100, :width => 100, :height => 100, :body => "abc", :post_id => @post.id}}, {:user_id => @user.id}
        end
      end
    end
    
    context "update action" do
      setup do
        @note = Factory.create(:note)
      end
      
      should "update a note" do
        post :update, {:id => @note.id, :note => {:body => "xyz"}}, {:user_id => @user.id}
        @note.reload
        assert_equal("xyz", @note.body)
      end
    end
    
    context "destroy action" do
      setup do
        @note = Factory.create(:note)
      end
      
      should "destroy a note" do
        assert_difference("Note.count", -1) do
          post :destroy, {:id => @note.id}, {:user_id => @user.id}
        end
      end
    end
    
    context "revert action" do
      setup do
        @note = Factory.create(:note, :body => "000")
        @note.update_attributes(:body => "111")
        @note.update_attributes(:body => "222")
      end
      
      should "revert to a previous version" do
        post :revert, {:id => @note.id, :version_id => @note.versions(true).first.id}
        @note.reload
        assert_equal("000", @note.body)
      end
    end
  end
end
