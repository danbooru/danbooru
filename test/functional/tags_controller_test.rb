require 'test_helper'

class TagsControllerTest < ActionDispatch::IntegrationTest
  context "The tags controller" do
    setup do
      @user = create(:builder_user)
      as_user do
        @tag = create(:tag, name: "touhou", category: Tag.categories.copyright, post_count: 1)
      end
    end

    context "edit action" do
      should "render" do
        get_auth tag_path(@tag), @user, params: {:id => @tag.id}
        assert_response :success
      end
    end

    context "index action" do
      should "render" do
        get tags_path
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get tags_path, params: {:search => {:name_matches => "touhou"}}
          assert_response :success
        end
      end

      context "with blank search parameters" do
        should "strip the blank parameters with a redirect" do
          get tags_path, params: { search: { name: "touhou", category: "" } }
          assert_redirected_to tags_path(search: { name: "touhou" })
        end
      end
    end

    context "autocomplete action" do
      should "render" do
        get autocomplete_tags_path, params: { search: { name_matches: "t" }, format: :json }
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        get tag_path(@tag)
        assert_response :success
      end
    end

    context "update action" do
      setup do
        @mod = create(:moderator_user)
      end

      should "update the tag" do
        put_auth tag_path(@tag), @user, params: {:tag => {:category => Tag.categories.general}}
        assert_redirected_to tag_path(@tag)
        assert_equal(Tag.categories.general, @tag.reload.category)
      end

      should "lock the tag for a moderator" do
        put_auth tag_path(@tag), @mod, params: { tag: { is_locked: true } }

        assert_redirected_to @tag
        assert_equal(true, @tag.reload.is_locked)
      end

      should "not lock the tag for a user" do
        put_auth tag_path(@tag), @user, params: {tag: { is_locked: true }}

        assert_equal(false, @tag.reload.is_locked)
      end

      context "for a tag with >50 posts" do
        setup do
          as_user do
            @tag.update(post_count: 100)
          end
        end

        should "not update the category for a member" do
          @member = create(:member_user)
          put_auth tag_path(@tag), @member, params: {tag: { category: Tag.categories.general }}

          assert_not_equal(Tag.categories.general, @tag.reload.category)
        end

        should "update the category for a builder" do
          put_auth tag_path(@tag), @user, params: {tag: { category: Tag.categories.general }}

          assert_redirected_to @tag
          assert_equal(Tag.categories.general, @tag.reload.category)
        end
      end

      should "not change category when the tag is too large to be changed by a builder" do
        as_user do
          @tag.update(category: Tag.categories.general, post_count: 1001)
        end
        put_auth tag_path(@tag), @user, params: {:tag => {:category => Tag.categories.artist}}

        assert_response :forbidden
        assert_equal(Tag.categories.general, @tag.reload.category)
      end
    end
  end
end
