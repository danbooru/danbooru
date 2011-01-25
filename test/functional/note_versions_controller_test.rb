require 'test_helper'

class NoteVersionsControllerTest < ActionController::TestCase
  context "The note versions controller" do
    setup do
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "index action" do
      setup do
        @note = Factory.create(:note)
        CurrentUser.id = 20
        @note.body = "1 2"
        @note.create_version
        CurrentUser.id = 30
        @note.body = "1 2 3"
        @note.create_version
      end
      
      should "list all versions" do
        get :index
        assert_response :success
        assert_not_nil(assigns(:note_versions))
        assert_equal(3, assigns(:note_versions).size)
      end
      
      should "list all versions that match the search criteria" do
        get :index, {:search => {:updater_id_equals => "20"}}
        assert_response :success
        assert_not_nil(assigns(:note_versions))
        assert_equal(1, assigns(:note_versions).size)
      end
    end
  end
end
