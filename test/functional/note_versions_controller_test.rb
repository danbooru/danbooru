require 'test_helper'

class NoteVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The note versions controller" do
    setup do
      @user = create(:user)
    end

    context "index action" do
      setup do
        as_user do
          @note = create(:note)
        end
        @user_2 = create(:user)

        CurrentUser.scoped(@user_2, "1.2.3.4") do
          @note.update(body: "1 2")
        end

        CurrentUser.scoped(@user, "1.2.3.4") do
          @note.update(body: "1 2 3")
        end
      end

      should "list all versions" do
        get note_versions_path
        assert_response :success
      end

      should "list all versions that match the search criteria" do
        get note_versions_path, params: {:search => {:updater_id => @user_2.id}}
        assert_response :success
      end
    end
  end
end
