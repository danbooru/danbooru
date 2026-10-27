require "test_helper"

class DanbooruFormBuilderTest < ActionView::TestCase
  def builder(object)
    Danbooru::FormBuilder.new(:tag, object, self, {})
  end

  context "Danbooru::FormBuilder" do
    context "submit_button method" do
      should "say Create for new records and Update for existing ones" do
        assert_dom_equal(%{<input type="submit" name="commit" value="Create" class="button-primary" data-disable-with="Create">}, builder(Tag.new).submit_button)
        assert_dom_equal(%{<input type="submit" name="commit" value="Update" class="button-primary" data-disable-with="Update">}, builder(create(:tag)).submit_button)
      end

      should "allow custom create and update labels" do
        assert_match(/value="Post"/, builder(Tag.new).submit_button(create: "Post", update: "Save"))
        assert_match(/value="Save"/, builder(create(:tag)).submit_button(create: "Post", update: "Save"))
      end

      should "allow a fixed label" do
        assert_match(/value="Login"/, builder(Tag.new).submit_button("Login"))
        assert_match(/value="Login"/, builder(create(:tag)).submit_button("Login"))
      end

      should "allow overriding the class" do
        assert_match(/class="button-danger"/, builder(Tag.new).submit_button("Ban", class: "button-danger"))
      end
    end

    context "cancel_button method" do
      should "render an outlined button" do
        assert_match(%r{<button[^>]*name="cancel"[^>]*>Cancel</button>}, builder(Tag.new).cancel_button)
        assert_match(/class="[^"]*button-outline-primary/, builder(Tag.new).cancel_button)
      end
    end
  end
end
