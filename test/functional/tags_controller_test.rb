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

      should "render for a sitemap" do
        get tags_path(format: :sitemap)
        assert_response :success
        assert_equal(Tag.count, response.parsed_body.css("urlset url loc").size)
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
            @miku = create(:character_tag, name: "hatsune_miku")
            @wokada = create(:artist_tag, name: "wokada")
            @vocaloid = create(:copyright_tag, name: "vocaloid")
            @weapon = create(:tag, name: "weapon")
            @empty = create(:tag, name: "empty", post_count: 0)

            create(:tag_alias, antecedent_name: "miku", consequent_name: "hatsune_miku")
            create(:tag_implication, antecedent_name: "axe", consequent_name: "weapon")
            create(:wiki_page, title: "hatsune_miku", body: "[[vocaloid]]")
            create(:artist, name: "wokada")
          end
        end

      should "render" do
        get tags_path
        assert_response :success
      end

        should respond_to_search({}).with { [@weapon, @vocaloid, @wokada, @miku, @tag] }
        should respond_to_search(name_matches: "hatsune_miku").with { @miku }
        should respond_to_search(name_normalize: "HATSUNE_MIKU  ").with { @miku }
        should respond_to_search(name_or_alias_matches: "miku").with { @miku }
        should respond_to_search(fuzzy_name_matches: "miku_hatsune", order: "similarity").with { @miku }
        should respond_to_search(name: "empty", hide_empty: "true").with { [] }
        should respond_to_search(name: "empty", hide_empty: "false").with { [@empty] }

        context "using includes" do
          should respond_to_search(name: "wokada", has_artist: "true").with { @wokada }
          should respond_to_search(name: "hatsune_miku", has_artist: "false").with { @miku }
          should respond_to_search(name: "hatsune_miku", has_wiki_page: "true").with { @miku }
          should respond_to_search(name: "vocaloid", has_wiki_page: "false").with { @vocaloid }
          should respond_to_search(consequent_aliases: {antecedent_name: "miku"}).with { @miku }
          should respond_to_search(consequent_implications: {antecedent_name: "axe"}).with { @weapon }
          should respond_to_search(wiki_page: {body_matches: "*vocaloid*"}).with { @miku }
          should respond_to_search(artist: {is_banned: "false"}).with { @wokada }
          should respond_to_search(has_dtext_links: "true").with { @vocaloid }
        end
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
