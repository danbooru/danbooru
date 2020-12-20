require 'test_helper'

class AutocompleteServiceTest < ActiveSupport::TestCase
  def autocomplete(query, type, **options)
    results = AutocompleteService.new(query, type, **options).autocomplete_results
    results.map { |r| r[:value] }
  end

  def assert_autocomplete_includes(expected_value, query, type, **options)
    assert_includes(autocomplete(query, type, **options), expected_value)
  end

  def assert_autocomplete_equals(expected_value, query, type, **options)
    assert_equal(expected_value, autocomplete(query, type, **options))
  end

  context "#autocomplete method" do
    should "autocomplete artists" do
      create(:artist, name: "bkub")
      assert_autocomplete_includes("bkub", "bk", :artist)
    end

    should "autocomplete wiki pages" do
      create(:wiki_page, title: "help:home")
      assert_autocomplete_includes("help:home", "help", :wiki_page)
    end

    should "autocomplete users" do
      @user = create(:user, name: "fumimi")

      as(@user) do
        assert_autocomplete_includes("fumimi", "fu", :user)
        assert_autocomplete_includes("@fumimi", "fu", :mention)
        assert_autocomplete_includes("user:fumimi", "user:fu", :tag_query)
      end
    end

    should "autocomplete pools" do
      as(create(:user)) do
        create(:pool, name: "Disgustingly_Adorable")
      end

      assert_autocomplete_includes("Disgustingly_Adorable", "disgust", :pool)
      assert_autocomplete_includes("pool:Disgustingly_Adorable", "pool:disgust", :tag_query)
      assert_autocomplete_includes("pool:Disgustingly_Adorable", "-pool:disgust", :tag_query)
    end

    should "autocomplete favorite groups" do
      user = create(:user)
      create(:favorite_group, name: "Stuff", creator: user)

      assert_autocomplete_equals(["Stuff"], "stu", :favorite_group, current_user: user)
      assert_autocomplete_equals([], "stu", :favorite_group, current_user: User.anonymous)

      assert_autocomplete_equals(["favgroup:Stuff"], "favgroup:stu", :tag_query, current_user: user)
      assert_autocomplete_equals([], "favgroup:stu", :tag_query, current_user: User.anonymous)
    end

    should "autocomplete saved search labels" do
      user = create(:user)
      create(:saved_search, query: "bkub", labels: ["artists"], user: user)

      assert_autocomplete_equals(["artists"], "art", :saved_search_label, current_user: user)
      assert_autocomplete_equals([], "art", :saved_search_label, current_user: User.anonymous)

      assert_autocomplete_equals(["search:artists"], "search:art", :tag_query, current_user: user)
      assert_autocomplete_equals([], "search:art", :saved_search_label, current_user: User.anonymous)
    end

    should "autocomplete single tags" do
      create(:tag, name: "touhou")
      assert_autocomplete_includes("touhou", "tou", :tag)
    end

    context "for a tag search" do
      should "autocomplete tags" do
        create(:tag, name: "touhou")

        assert_autocomplete_includes("touhou", "tou", :tag_query)
        assert_autocomplete_includes("touhou", "TOU", :tag_query)
        assert_autocomplete_includes("touhou", "-tou", :tag_query)
        assert_autocomplete_includes("touhou", "~tou", :tag_query)
      end

      context "for a tag abbreviation" do
        should "autocomplete abbreviations" do
          create(:tag, name: "mole", post_count: 150)
          create(:tag, name: "mole_under_eye", post_count: 100)
          create(:tag, name: "mole_under_mouth", post_count: 50)

          assert_autocomplete_equals(%w[mole mole_under_eye mole_under_mouth], "/m", :tag_query)
          assert_autocomplete_equals(%w[mole_under_eye mole_under_mouth], "/mu", :tag_query)
          assert_autocomplete_equals(%w[mole_under_mouth], "/mum", :tag_query)
          assert_autocomplete_equals(%w[mole_under_eye], "/mue", :tag_query)
          assert_autocomplete_equals(%w[mole_under_eye], "/*ue", :tag_query)

          assert_autocomplete_includes("mole_under_eye", "-/mue", :tag_query)
          assert_autocomplete_includes("mole_under_eye", "~/mue", :tag_query)
        end

        should "list aliases before abbreviations" do
          create(:tag, name: "hair_ribbon", post_count: 300_000)
          create(:tag, name: "hakurei_reimu", post_count: 50_000)
          create(:tag_alias, antecedent_name: "/hr", consequent_name: "hakurei_reimu")

          assert_autocomplete_equals(%w[hakurei_reimu hair_ribbon], "/hr", :tag_query)
        end
      end

      should "autocomplete tags from wiki and artist other names" do
        create(:tag, name: "touhou")
        create(:tag, name: "bkub", category: Tag.categories.artist)
        create(:wiki_page, title: "touhou", other_names: %w[東方 东方 동방])
        create(:artist, name: "bkub", other_names: %w[大川ぶくぶ フミンバイン])

        assert_autocomplete_equals(["touhou"], "東", :tag_query)
        assert_autocomplete_equals(["touhou"], "东", :tag_query)
        assert_autocomplete_equals(["touhou"], "동", :tag_query)

        assert_autocomplete_equals(["touhou"], "*東*", :tag_query)
        assert_autocomplete_equals(["touhou"], "東*", :tag_query)
        assert_autocomplete_equals([], "*東", :tag_query)

        assert_autocomplete_equals(["touhou"], "*方*", :tag_query)
        assert_autocomplete_equals(["touhou"], "*方", :tag_query)
        assert_autocomplete_equals([], "方", :tag_query)

        assert_autocomplete_equals(["bkub"], "*大*", :tag_query)
        assert_autocomplete_equals(["bkub"], "大", :tag_query)
        assert_autocomplete_equals([], "*大", :tag_query)

        assert_autocomplete_equals(["bkub"], "*川*", :tag_query)
        assert_autocomplete_equals([], "*川", :tag_query)
        assert_autocomplete_equals([], "川", :tag_query)
      end

      should "autocomplete wildcard searches" do
        create(:tag, name: "mole", post_count: 150)
        create(:tag, name: "mole_under_eye", post_count: 100)
        create(:tag, name: "mole_under_mouth", post_count: 50)

        assert_autocomplete_equals(%w[mole mole_under_eye mole_under_mouth], "mole*", :tag_query)
        assert_autocomplete_equals(%w[mole_under_eye mole_under_mouth], "*under*", :tag_query)
        assert_autocomplete_equals(%w[mole_under_eye], "*eye", :tag_query)
      end

      should "autocorrect misspelled tags" do
        create(:tag, name: "touhou")

        assert_autocomplete_equals(%w[touhou], "touhuo", :tag_query)
      end

      should "ignore unsupported metatags" do
        assert_autocomplete_equals([], "date:2020", :tag_query)
        assert_autocomplete_equals([], "score:20", :tag_query)
        assert_autocomplete_equals([], "favcount:>20", :tag_query)
        assert_autocomplete_equals([], "age:<1w", :tag_query)
        assert_autocomplete_equals([], "limit:200", :tag_query)
      end

      should "autocomplete static metatags" do
        assert_autocomplete_equals(["status:active"], "status:act", :tag_query)
        assert_autocomplete_equals(["parent:active"], "parent:act", :tag_query)
        assert_autocomplete_equals(["child:active"], "child:act", :tag_query)

        assert_autocomplete_equals(["rating:safe"], "rating:s", :tag_query)
        assert_autocomplete_equals(["rating:questionable"], "rating:q", :tag_query)
        assert_autocomplete_equals(["rating:explicit"], "rating:e", :tag_query)

        assert_autocomplete_equals(["locked:rating"], "locked:r", :tag_query)
        assert_autocomplete_equals(["locked:status"], "locked:s", :tag_query)
        assert_autocomplete_equals(["locked:note"], "locked:n", :tag_query)

        assert_autocomplete_equals(["embedded:true"], "embedded:t", :tag_query)
        assert_autocomplete_equals(["embedded:false"], "embedded:f", :tag_query)

        assert_autocomplete_equals(["filetype:jpg"], "filetype:j", :tag_query)
        assert_autocomplete_equals(["filetype:png"], "filetype:p", :tag_query)
        assert_autocomplete_equals(["filetype:gif"], "filetype:g", :tag_query)
        assert_autocomplete_equals(["filetype:swf"], "filetype:s", :tag_query)
        assert_autocomplete_equals(["filetype:zip"], "filetype:z", :tag_query)
        assert_autocomplete_equals(["filetype:webm"], "filetype:w", :tag_query)
        assert_autocomplete_equals(["filetype:mp4"], "filetype:m", :tag_query)

        assert_autocomplete_equals(["commentary:true"], "commentary:tru", :tag_query)
        assert_autocomplete_equals(["commentary:false"], "commentary:fal", :tag_query)
        assert_autocomplete_equals(["commentary:translated"], "commentary:trans", :tag_query)
        assert_autocomplete_equals(["commentary:untranslated"], "commentary:untrans", :tag_query)

        assert_autocomplete_equals(["disapproved:breaks_rules"], "disapproved:break", :tag_query)
        assert_autocomplete_equals(["disapproved:poor_quality"], "disapproved:poor", :tag_query)
        assert_autocomplete_equals(["disapproved:disinterest"], "disapproved:dis", :tag_query)

        assert_autocomplete_equals(["order:score", "order:score_asc"], "order:sco", :tag_query)
      end
    end
  end
end
