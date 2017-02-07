require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  context "The notes controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @note = FactoryGirl.create(:note, body: "000")
    end

    teardown do
      CurrentUser.user = nil
    end

    context "index action" do
      should "list all notes" do
        get :index
        assert_response :success
      end

      should "list all notes (with search)" do
        params = {
          group_by: "note",
          search: {
            body_matches: "000",
            is_active: true,
            post_id: @note.post_id,
            post_tags_match: @note.post.tag_array.first,
            creator_name: @note.creator_name,
            creator_id: @note.creator_id,
          }
        }

        get :index, params
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        get :show, { id: @note.id, format: "json" }
        assert_response :success
      end
    end

    context "create action" do
      should "create a note" do
        assert_difference("Note.count", 1) do
          @post = FactoryGirl.create(:post)
          post :create, {:note => {:x => 0, :y => 0, :width => 10, :height => 10, :body => "abc", :post_id => @post.id}, :format => :json}, {:user_id => @user.id}
        end
      end
    end

    context "update action" do
      should "update a note" do
        post :update, {:id => @note.id, :note => {:body => "xyz"}}, {:user_id => @user.id}
        assert_equal("xyz", @note.reload.body)
      end

      should "not allow changing the post id to another post" do
        @other = FactoryGirl.create(:post)
        post :update, {:format => "json", :id => @note.id, :note => {:post_id => @other.id}}, {:user_id => @user.id}

        assert_not_equal(@other.id, @note.reload.post_id)
      end
    end

    context "destroy action" do
      should "destroy a note" do
        post :destroy, {:id => @note.id}, {:user_id => @user.id}
        assert_equal(false, @note.reload.is_active?)
      end
    end

    context "revert action" do
      setup do
        Timecop.travel(1.day.from_now) do
          @note.update_attributes(:body => "111")
        end
        Timecop.travel(2.days.from_now) do
          @note.update_attributes(:body => "222")
        end
      end

      should "revert to a previous version" do
        post :revert, {:id => @note.id, :version_id => @note.versions(true).first.id}, {:user_id => @user.id}
        assert_equal("000", @note.reload.body)
      end

      should "not allow reverting to a previous version of another note" do
        @note2 = FactoryGirl.create(:note, :body => "note 2")

        post :revert, { :id => @note.id, :version_id => @note2.versions(true).first.id }, {:user_id => @user.id}

        assert_not_equal(@note.reload.body, @note2.body)
        assert_response :missing
      end
    end
  end
end
