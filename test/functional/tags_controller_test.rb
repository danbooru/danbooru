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
            @miku = create(:character_tag, name: "miku")
            @hatsune_miku = create(:character_tag, name: "hatsune_miku")
            @wokada = create(:artist_tag, name: "wokada")
            @vocaloid = create(:copyright_tag, name: "vocaloid")
            @weapon = create(:tag, name: "weapon")
            @axe = create(:tag, name: "axe")
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

        should respond_to_search({}).with { [@empty, @axe, @weapon, @vocaloid, @wokada, @hatsune_miku, @miku, @tag] }
        should respond_to_search(name_matches: "hatsune_miku").with { @hatsune_miku }
        should respond_to_search(name_normalize: "HATSUNE_MIKU  ").with { @hatsune_miku }
        should respond_to_search(name_or_alias_matches: "miku").with { [@hatsune_miku, @miku] }
        should respond_to_search(fuzzy_name_matches: "hatsune_mika", order: "similarity").with { @hatsune_miku }
        should respond_to_search(name: "empty", hide_empty: "true").with { [] }
        should respond_to_search(name: "empty", hide_empty: "false").with { [@empty] }
        should respond_to_search(name: "empty", is_empty: "true").with { [@empty] }
        should respond_to_search(name: "empty", is_empty: "false").with { [] }

        context "using includes" do
          should respond_to_search(name: "wokada", has_artist: "true").with { @wokada }
          should respond_to_search(name: "hatsune_miku", has_artist: "false").with { @hatsune_miku }
          should respond_to_search(name: "hatsune_miku", has_wiki_page: "true").with { @hatsune_miku }
          should respond_to_search(name: "vocaloid", has_wiki_page: "false").with { @vocaloid }
          should respond_to_search(consequent_aliases: {antecedent_name: "miku"}).with { @hatsune_miku }
          should respond_to_search(consequent_implications: {antecedent_name: "axe"}).with { @weapon }
          should respond_to_search(wiki_page: {body_matches: "*vocaloid*"}).with { @hatsune_miku }
          should respond_to_search(artist: {is_banned: "false"}).with { @wokada }
          should respond_to_search(has_dtext_links: "true").with { @vocaloid }
        end
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

      context "for deprecation" do
        setup do
          @deprecated_tag = create(:tag, name: "bad_tag", category: Tag.categories.general, post_count: 0, is_deprecated: true)
          @nondeprecated_tag = create(:tag, name: "log", category: Tag.categories.general, post_count: 0)
          @normal_tag = create(:tag, name: "random", category: Tag.categories.general, post_count: 1000)
          create(:wiki_page, title: "bad_tag", body: "[[bad_tag]]")
          create(:wiki_page, title: "log", body: "[[log]]")
          create(:wiki_page, title: "random", body: "[[random]]")

          @tag_without_wiki = create(:tag, name: "no_wiki", category: Tag.categories.general, post_count: 0)

          @normal_user = create(:member_user)
          @admin = create(:admin_user)
        end

        should "not remove deprecated status if the user is not an admin" do
          put_auth tag_path(@deprecated_tag), @normal_user, params: {tag: { is_deprecated: false }}

          assert_response 403
          assert_equal(true, @deprecated_tag.reload.is_deprecated?)
        end

        should "remove the deprecated status if the user is admin" do
          put_auth tag_path(@deprecated_tag), @admin, params: {tag: { is_deprecated: false }}

          assert_redirected_to @deprecated_tag
          assert_equal(false, @deprecated_tag.reload.is_deprecated?)
        end

        should "allow marking a tag as deprecated if it's empty" do
          put_auth tag_path(@nondeprecated_tag), @normal_user, params: {tag: { is_deprecated: true }}

          assert_redirected_to @nondeprecated_tag
          assert_equal(true, @nondeprecated_tag.reload.is_deprecated?)
        end

        should "not allow marking a tag as deprecated if it's not empty" do
          put_auth tag_path(@normal_tag), @normal_user, params: {tag: { is_deprecated: true }}

          assert_response 403
          assert_equal(false, @normal_tag.reload.is_deprecated?)
        end

        should "allow admins to mark tags as deprecated" do
          put_auth tag_path(@normal_tag), @admin, params: {tag: { is_deprecated: true }}

          assert_redirected_to @normal_tag
          assert_equal(true, @normal_tag.reload.is_deprecated?)
        end

        should "not allow deprecation of a tag with no wiki" do
          put_auth tag_path(@tag_without_wiki), @user, params: {tag: { is_deprecated: true }}

          assert_response 403
          assert_equal(false, @tag_without_wiki.reload.is_deprecated?)
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
