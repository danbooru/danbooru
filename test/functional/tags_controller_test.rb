require 'test_helper'

class TagsControllerTest < ActionDispatch::IntegrationTest
  context "The tags controller" do
    setup do
      @user = create(:builder_user)
      @tag = create(:tag, name: "touhou", category: Tag.categories.copyright, post_count: 1)
    end

    context "edit action" do
      should "render" do
        get_auth edit_tag_path(@tag), @user
        assert_response :success
      end
    end

    context "index action" do
      should "render" do
        get tags_path
        assert_response :success
      end

      context "with blank search parameters" do
        should "strip the blank parameters with a redirect" do
          get tags_path, params: { search: { name: "touhou", category: "" } }
          assert_redirected_to tags_path(search: { name: "touhou" })
        end
      end

      context "searching" do
        setup do
          as(@user) do
            @miku = create(:tag, name: "hatsune_miku", category: Tag.categories.character)
            @wokada = create(:tag, name: "wokada", category: Tag.categories.artist)
            @vocaloid = create(:tag, name: "vocaloid", category: Tag.categories.copyright)
            @empty = create(:tag, name: "empty", post_count: 0)

            create(:tag_alias, antecedent_name: "miku", consequent_name: "hatsune_miku")
            create(:wiki_page, title: "hatsune_miku")
            create(:artist, name: "wokada")
          end
        end

        should respond_to_search(name_matches: "hatsune_miku").with { @miku }
        should respond_to_search(name_normalize: "HATSUNE_MIKU  ").with { @miku }
        should respond_to_search(name_or_alias_matches: "miku").with { @miku }
        should respond_to_search(fuzzy_name_matches: "miku_hatsune", order: "similarity").with { @miku }
        should respond_to_search(name: "empty", hide_empty: "true").with { [] }
        should respond_to_search(name: "empty", hide_empty: "false").with { [@empty] }
        should respond_to_search(name: "wokada", has_artist: "true").with { @wokada }
        should respond_to_search(name: "hatsune_miku", has_artist: "false").with { @miku }
        should respond_to_search(name: "hatsune_miku", has_wiki: "true").with { @miku }
        should respond_to_search(name: "vocaloid", has_wiki: "false").with { @vocaloid }
      end
    end

    context "autocomplete action" do
      should "render" do
        get autocomplete_tags_path, params: { search: { name_matches: "t" }, format: :json }
        assert_response :success
      end

      should "respect the only param" do
        get autocomplete_tags_path, params: { search: { name_matches: "t", only: "name" }, format: :json }

        assert_response :success
        assert_equal "touhou", response.parsed_body.first["name"]
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

        assert_response 403
        assert_equal(false, @tag.reload.is_locked)
      end

      context "for a tag with >50 posts" do
        setup do
          @tag.update(post_count: 100)
        end

        should "not update the category for a member" do
          @member = create(:member_user)
          put_auth tag_path(@tag), @member, params: {tag: { category: Tag.categories.general }}

          assert_response 403
          assert_not_equal(Tag.categories.general, @tag.reload.category)
        end

        should "update the category for a builder" do
          put_auth tag_path(@tag), @user, params: {tag: { category: Tag.categories.general }}

          assert_redirected_to @tag
          assert_equal(Tag.categories.general, @tag.reload.category)
        end
      end

      should "not change category when the tag is too large to be changed by a builder" do
        @tag.update(category: Tag.categories.general, post_count: 1001)
        put_auth tag_path(@tag), @user, params: {:tag => {:category => Tag.categories.artist}}

        assert_response :forbidden
        assert_equal(Tag.categories.general, @tag.reload.category)
      end
    end
  end
end
