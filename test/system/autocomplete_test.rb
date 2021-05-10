require "application_system_test_case"

class AutocompleteTest < ApplicationSystemTestCase
  def autocomplete(id, *keys)
    fill_in id: id, with: ""
    find_by_id(id).send_keys(keys)
  end

  def assert_autocomplete_equals(expected_results, text, id:)
    autocomplete(id, text)
    sleep 1 if expected_results.empty?

    assert_selector 'ul.ui-autocomplete li', count: expected_results.size
    expected_results.each do |result|
      assert_selector "li[data-autocomplete-value='#{result}']", count: 1
    end
  end

  def assert_search_autocomplete_equals(values, text)
    visit posts_path unless current_path == posts_path
    assert_autocomplete_equals(values, text, id: "tags")
  end

  def assert_metatag_autocomplete_equals(values, metatag)
    results = values.map { |value| "#{metatag.downcase}:#{value}" }
    assert_search_autocomplete_equals(results, "#{metatag}:")
  end

  def assert_mention_autocomplete_equals(values, text)
    visit new_forum_post_path unless current_path == new_forum_post_path
    assert_autocomplete_equals(values, text, id: "forum_post_body")
  end

  def assert_inserted_completion(result, query, id: "tags")
    autocomplete(id, query)
    first("ul.ui-autocomplete li").click
    assert_equal(result, find_field(id: id).value)
  end

  context "Autocomplete" do
    context "for post searches" do
      should "work for static metatags" do
        assert_metatag_autocomplete_equals(%w[any none], "child")
        assert_metatag_autocomplete_equals(%w[any none], "parent")
        assert_metatag_autocomplete_equals(%w[rating note status], "locked")
        assert_metatag_autocomplete_equals(%w[safe questionable explicit], "rating")
        assert_metatag_autocomplete_equals(%w[gif jpg mp4 png swf webm zip], "filetype")
        assert_metatag_autocomplete_equals(%w[active any banned deleted flagged modqueue pending unmoderated], "status")
        assert_metatag_autocomplete_equals(PostDisapproval::REASONS, "disapproval")
      end

      should "work for username metatags" do
        %w[user approver commenter comm noter noteupdater artcomm fav ordfav appealer flagger upvote downvote].each do |metatag|
          assert_search_autocomplete_equals(["#{metatag}:DanbooruBot"], "#{metatag}:Danbo")
          assert_search_autocomplete_equals(["#{metatag}:DanbooruBot"], "-#{metatag}:Danbo")
        end
      end

      should "work for pool metatags" do
        @user = create(:user)
        as(@user) { create(:pool, name: "Cute") }
        as(@user) { create(:post, tag_string: "pool:Cute") }

        assert_search_autocomplete_equals(["pool:Cute"], "pool:c")
        assert_search_autocomplete_equals(["pool:Cute"], "pool:cute")
        assert_search_autocomplete_equals(["pool:Cute"], "pool:CUTE")
        assert_search_autocomplete_equals(["pool:Cute"], "POOL:cute")
        assert_search_autocomplete_equals(["pool:Cute"], "pool:*ute")
        assert_search_autocomplete_equals(["pool:Cute"], "-pool:cute")
        assert_search_autocomplete_equals(["pool:Cute"], "~pool:cute")

        assert_search_autocomplete_equals(["ordpool:Cute"], "ordpool:cute")
        assert_search_autocomplete_equals(["ordpool:Cute"], "ORDPOOL:cute")
      end

      should "work for regular tags" do
        create(:tag, name: "bkub", post_count: 42)

        assert_search_autocomplete_equals(["bkub"], "b")
        assert_search_autocomplete_equals(["bkub"], "bkub")
        assert_search_autocomplete_equals(["bkub"], "BKUB")
        assert_search_autocomplete_equals(["bkub"], " bkub")
        assert_search_autocomplete_equals(["bkub"], "one two bkub")

        assert_search_autocomplete_equals(["bkub"], "-bkub")
        assert_search_autocomplete_equals(["bkub"], "~bkub")
        assert_search_autocomplete_equals(["bkub"], "-BKUB")
        assert_search_autocomplete_equals(["bkub"], "~BKUB")

        assert_search_autocomplete_equals(["bkub"], "art:bkub")
        assert_search_autocomplete_equals(["bkub"], "copy:bkub")
        assert_search_autocomplete_equals(["bkub"], "char:bkub")
        assert_search_autocomplete_equals(["bkub"], "gen:bkub")
        assert_search_autocomplete_equals(["bkub"], "meta:bkub")

        assert_search_autocomplete_equals(["bkub"], "b*")
        assert_search_autocomplete_equals(["bkub"], "B*")
        assert_search_autocomplete_equals(["bkub"], "*b")
        assert_search_autocomplete_equals(["bkub"], "*bkub*")

        assert_search_autocomplete_equals([], " ")
        assert_search_autocomplete_equals([], "one")
        assert_search_autocomplete_equals([], "one two")
      end

      should "not complete tags after a space" do
        create(:tag, name: "bkub", post_count: 42)
        assert_search_autocomplete_equals([], "bkub ")
      end

      should "correct invalid operator combinations" do
        create(:tag, name: "bkub", post_count: 42)

        assert_search_autocomplete_equals(["bkub"], "foo ---bkub")
        assert_search_autocomplete_equals(["bkub"], "foo ~~~bkub")

        assert_search_autocomplete_equals(["rating:safe"], "--rating:s")
        assert_search_autocomplete_equals(["rating:safe"], "-~rating:s")
        assert_search_autocomplete_equals(["rating:safe"], "~-rating:s")
        assert_search_autocomplete_equals(["rating:safe"], "~~rating:s")
        assert_search_autocomplete_equals(["rating:safe"], "---rating:s")
        assert_search_autocomplete_equals(["rating:safe"], "~~~rating:s")
      end

      should "ignore invalid prefix + metatag combinations" do
        assert_search_autocomplete_equals([], "char:rating:s")
      end

      should "insert completions on click" do
        visit posts_path

        create(:tag, name: "bkub", post_count: 42)
        assert_inserted_completion("bkub ", "b")
        assert_inserted_completion("-bkub ", "-b")
        assert_inserted_completion("~bkub ", "~b")
        assert_inserted_completion("tag bkub ", "tag b")
        assert_inserted_completion("tag char:bkub ", "tag char:b")

        assert_inserted_completion("rating:safe ", "rating:s")
        assert_inserted_completion("-rating:safe ", "-rating:s")
        assert_inserted_completion("-rating:safe ", "---rating:s")
        assert_inserted_completion("tag rating:safe ", "tag rating:s")
      end
    end

    context "for username mentions" do
      should "work" do
        signup "member"

        assert_mention_autocomplete_equals(["@member"], "@m")
        assert_mention_autocomplete_equals(["@member"], "@member")
        assert_mention_autocomplete_equals(["@member"], "@MEMBER")
        assert_mention_autocomplete_equals(["@member"], "one two @member")

        # assert_mention_autocomplete_equals(["@member"], "<@member")
      end
    end
  end
end
