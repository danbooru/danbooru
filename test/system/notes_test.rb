require "application_system_test_case"

class NotesChromeTest < ChromeSystemTestCase
  # Draw a note box by dragging on the image, starting at (x, y) and dragging by (width, height) pixels.
  def draw_note(x:, y:, width:, height:)
    image_box = find("#image").with_playwright_element_handle(&:bounding_box)

    page.driver.with_playwright_page do |playwright_page|
      playwright_page.mouse.move(image_box["x"] + x, image_box["y"] + y)
      playwright_page.mouse.down
      playwright_page.mouse.move(image_box["x"] + x + width, image_box["y"] + y + height, steps: 5)
      playwright_page.mouse.up
    end
  end

  # Hover over the note box to reveal its body, then click the body to open the edit dialog.
  def open_note_edit_dialog
    find(".note-box").hover
    find(".note-body").click
  end

  context "Notes:" do
    setup do
      @user = create(:user, created_at: 1.month.ago)
      @post = create(:post, tag_string: "tagme")
      fast_signin @user
    end

    context "creating a note" do
      setup do
        visit post_path(@post)
        click_link "Add note"
        draw_note(x: 50, y: 50, width: 100, height: 80)
        open_note_edit_dialog
      end

      should "show the note edit dialog" do
        assert_selector ".note-edit-dialog", text: "Creating new note"
      end

      should "preview the note" do
        textarea = find(".note-edit-dialog textarea")
        textarea.hover
        assert_no_selector ".note-body", visible: true

        textarea.set("Preview text")
        within(".note-edit-dialog") { click_button "Preview" }

        assert_selector ".note-body", text: "Preview text"
        assert_equal 0, @post.notes.count
      end

      should "save the note" do
        find(".note-edit-dialog textarea").set("This is a note")
        within(".note-edit-dialog") { click_button "Save" }

        assert_no_selector ".note-edit-dialog"
        assert_no_selector ".note-box.unsaved"
        assert_equal 1, @post.notes.count
        assert_equal "This is a note", @post.notes.last.body
      end

      should "show an error if the post has too many notes" do
        stub_const(Note, :MAX_NOTES_PER_POST, 0) do
          find(".note-edit-dialog textarea").set("This is a note")
          within(".note-edit-dialog") { click_button "Save" }

          assert_notice(/Post can't have more than 0 notes/)
          assert_selector ".note-edit-dialog"
          assert_selector ".note-box.unsaved"
          assert_equal 0, @post.notes.count
        end
      end
    end

    context "a note containing a link" do
      setup do
        as(@user) { create(:note, post: @post, x: 50, y: 50, width: 100, height: 80, body: '<a href="#plain">plain link</a> <a href="#bold"><b>bold link</b></a>') }
        visit post_path(@post)
        find(".note-box").hover
      end

      should "follow the link instead of opening the edit dialog when the link is clicked" do
        find(".note-body a", text: "plain link").click

        assert page.current_url.end_with?("#plain")
        assert_no_selector ".note-edit-dialog"
      end

      should "follow the link instead of opening the edit dialog when formatted text inside the link is clicked" do
        find(".note-body a b", text: "bold link").click

        assert page.current_url.end_with?("#bold")
        assert_no_selector ".note-edit-dialog"
      end
    end

    context "an existing note" do
      setup do
        @note = as(@user) { create(:note, post: @post, x: 50, y: 50, width: 100, height: 80, body: "Existing note") }
        visit post_path(@post)
        open_note_edit_dialog
      end

      should "show the note edit dialog" do
        assert_selector ".note-edit-dialog", text: "Editing note ##{@note.id}"
      end

      should "save changes to the note" do
        find(".note-edit-dialog textarea").set("Updated note")
        within(".note-edit-dialog") { click_button "Save" }

        assert_no_selector ".note-edit-dialog"
        assert_equal "Updated note", @note.reload.body
      end

      should "delete the note" do
        within(".note-edit-dialog") do
          accept_confirm do
            click_button "Delete"
          end
        end

        assert_no_selector ".note-box"
        assert_not @note.reload.is_active?
      end
    end

    context "translation mode" do
      should "turn off when the link in the notice is clicked" do
        visit post_path(@post)
        assert_no_navigation { click_link "Add note" }
        assert_selector "body.mode-translation"

        assert_no_navigation { click_link "Turn translation mode off" }
        assert_no_selector "body.mode-translation"
      end
    end
  end
end
