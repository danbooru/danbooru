require 'test_helper'

class NoteVersionsControllerTest < ActionController::TestCase
  context "The note versions controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "index action" do
      setup do
        @note = FactoryGirl.create(:note)
        @user_2 = FactoryGirl.create(:user)
        
        CurrentUser.scoped(@user_2, "1.2.3.4") do
          @note.update_attributes(:body => "1 2")
        end
        
        CurrentUser.scoped(@user, "1.2.3.4") do
          @note.update_attributes(:body => "1 2 3")
        end
      end
      
      should "list all versions" do
        get :index
        assert_response :success
        assert_not_nil(assigns(:note_versions))
        assert_equal(3, assigns(:note_versions).size)
      end
      
      should "list all versions that match the search criteria" do
        get :index, {:search => {:updater_id_equals => @user_2.id}}
        assert_response :success
        assert_not_nil(assigns(:note_versions))
        assert_equal(1, assigns(:note_versions).size)
      end
    end
  end
end
