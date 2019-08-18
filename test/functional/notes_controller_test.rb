require 'test_helper'

class NotesControllerTest < ActionDispatch::IntegrationTest
  context "The notes controller" do
    setup do
      @user = create(:user)
      as_user do
        @note = create(:note, body: "000")
      end
    end

    context "index action" do
      should "list all notes" do
        get notes_path
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
            creator_name: @note.creator.name,
            creator_id: @note.creator_id,
          }
        }

        get notes_path, params: params
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        get note_path(@note), params: { format: "json" }
        assert_response :success
      end
    end

    context "create action" do
      should "create a note" do
        assert_difference("Note.count", 1) do
          as_user do
            @post = create(:post)
          end
          post_auth notes_path, @user, params: {:note => {:x => 0, :y => 0, :width => 10, :height => 10, :body => "abc", :post_id => @post.id}, :format => :json}
        end
      end
    end

    context "update action" do
      should "update a note" do
        put_auth note_path(@note), @user, params: {:note => {:body => "xyz"}}
        assert_equal("xyz", @note.reload.body)
      end

      should "not allow changing the post id to another post" do
        as(@admin) do
          @other = create(:post)
        end
        put_auth note_path(@note), @user, params: {:format => "json", :id => @note.id, :note => {:post_id => @other.id}}
        assert_not_equal(@other.id, @note.reload.post_id)
      end
    end

    context "destroy action" do
      should "destroy a note" do
        delete_auth note_path(@note), @user
        assert_equal(false, @note.reload.is_active?)
      end
    end

    context "revert action" do
      setup do
        as_user do
          travel(1.day) do
            @note.update(:body => "111")
          end
          travel(2.days) do
            @note.update(:body => "222")
          end
        end
      end

      should "revert to a previous version" do
        put_auth revert_note_path(@note), @user, params: {:version_id => @note.versions.first.id}
        assert_equal("000", @note.reload.body)
      end

      should "not allow reverting to a previous version of another note" do
        as_user do
          @note2 = create(:note, :body => "note 2")
        end
        put_auth revert_note_path(@note), @user, params: { :version_id => @note2.versions.first.id }
        assert_not_equal(@note.reload.body, @note2.body)
        assert_response :missing
      end
    end
  end
end
