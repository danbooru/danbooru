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

      assert_autocomplete_equals(["search:artists"], "search:art", :tag_query, current_user: user)
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
