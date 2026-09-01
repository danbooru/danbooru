require "application_system_test_case"

module AutocompleteTests
  extend ActiveSupport::Concern

  def assert_search_autocomplete_results(values, text)
    visit posts_path unless current_path == posts_path
    assert_autocomplete_results(values, text, selector: "#tags")
  end

  def assert_metatag_autocomplete_results(values, metatag)
    results = values.map { |value| "#{metatag.downcase}:#{value}" }
    assert_search_autocomplete_results(results, "#{metatag}:")
  end

  included do
    context "#{browser_name}:" do
      context "Post Search autocomplete" do
        should "work for static metatags" do
          assert_metatag_autocomplete_results(%w[any none] + AutocompleteService::POST_STATUSES, "child")
          assert_metatag_autocomplete_results(%w[any none] + AutocompleteService::POST_STATUSES, "parent")
          assert_metatag_autocomplete_results(Post::RATINGS.values.map(&:downcase), "rating")
          assert_metatag_autocomplete_results(MediaAsset::FILE_TYPES, "filetype")
          assert_metatag_autocomplete_results(%w[any] + AutocompleteService::POST_STATUSES, "status")
          assert_metatag_autocomplete_results(PostDisapproval::REASONS, "disapproved")
        end

        should "work for username metatags" do
          %w[user approver commenter comm noter noteupdater artcomm upvote downvote fav ordvote ordfav appealer flagger].each do |metatag|
            assert_search_autocomplete_results(["#{metatag}:DanbooruBot"], "#{metatag}:Danbo")
            assert_search_autocomplete_results(["#{metatag}:DanbooruBot"], "-#{metatag}:Danbo")
          end
        end

        should "work for pool metatags" do
          @user = create(:user)
          as(@user) { create(:pool, name: "Cute") }
          as(@user) { create(:post, tag_string: "pool:Cute") }

          assert_search_autocomplete_results(["pool:Cute"], "pool:c")
          assert_search_autocomplete_results(["pool:Cute"], "pool:cute")
          assert_search_autocomplete_results(["pool:Cute"], "pool:CUTE")
          assert_search_autocomplete_results(["pool:Cute"], "POOL:cute")
          assert_search_autocomplete_results(["pool:Cute"], "pool:*ute")
          assert_search_autocomplete_results(["pool:Cute"], "-pool:cute")
          assert_search_autocomplete_results(["pool:Cute"], "~pool:cute")

          assert_search_autocomplete_results(["ordpool:Cute"], "ordpool:cute")
          assert_search_autocomplete_results(["ordpool:Cute"], "ORDPOOL:cute")
        end

        should "work for regular tags" do
          create(:tag, name: "bkub", post_count: 42)

          assert_search_autocomplete_results(["bkub"], "b")
          assert_search_autocomplete_results(["bkub"], "bkub")
          assert_search_autocomplete_results(["bkub"], "BKUB")
          assert_search_autocomplete_results(["bkub"], " bkub")
          assert_search_autocomplete_results(["bkub"], "one two bkub")

          assert_search_autocomplete_results(["bkub"], "-bkub")
          assert_search_autocomplete_results(["bkub"], "~bkub")
          assert_search_autocomplete_results(["bkub"], "-BKUB")
          assert_search_autocomplete_results(["bkub"], "~BKUB")

          assert_search_autocomplete_results(["bkub"], "art:bkub")
          assert_search_autocomplete_results(["bkub"], "copy:bkub")
          assert_search_autocomplete_results(["bkub"], "char:bkub")
          assert_search_autocomplete_results(["bkub"], "gen:bkub")
          assert_search_autocomplete_results(["bkub"], "meta:bkub")

          assert_search_autocomplete_results(["bkub"], "b*")
          assert_search_autocomplete_results(["bkub"], "B*")
          assert_search_autocomplete_results(["bkub"], "*b")
          assert_search_autocomplete_results(["bkub"], "*bkub*")

          assert_search_autocomplete_results([], " ")
          assert_search_autocomplete_results([], "one")
          assert_search_autocomplete_results([], "one two")
        end

        should "not complete tags after a space" do
          create(:tag, name: "bkub", post_count: 42)
          assert_search_autocomplete_results([], "bkub ")
        end

        should "correct invalid operator combinations" do
          create(:tag, name: "bkub", post_count: 42)

          assert_search_autocomplete_results(["bkub"], "foo ---bkub")
          assert_search_autocomplete_results(["bkub"], "foo ~~~bkub")

          assert_search_autocomplete_results(["rating:sensitive"], "--rating:s")
          assert_search_autocomplete_results(["rating:sensitive"], "-~rating:s")
          assert_search_autocomplete_results(["rating:sensitive"], "~-rating:s")
          assert_search_autocomplete_results(["rating:sensitive"], "~~rating:s")
          assert_search_autocomplete_results(["rating:sensitive"], "---rating:s")
          assert_search_autocomplete_results(["rating:sensitive"], "~~~rating:s")
        end

        should "ignore invalid prefix + metatag combinations" do
          assert_search_autocomplete_results([], "char:rating:s")
        end

        should "insert completions on click" do
          visit posts_path

          create(:tag, name: "bkub", post_count: 42)
          assert_clicked_autocomplete_equals("bkub ", "b")
          assert_clicked_autocomplete_equals("-bkub ", "-b")
          assert_clicked_autocomplete_equals("~bkub ", "~b")
          assert_clicked_autocomplete_equals("tag bkub ", "tag b")
          assert_clicked_autocomplete_equals("tag char:bkub ", "tag char:b")

          assert_clicked_autocomplete_equals("rating:sensitive ", "rating:s")
          assert_clicked_autocomplete_equals("-rating:sensitive ", "-rating:s")
          assert_clicked_autocomplete_equals("tag rating:sensitive ", "tag rating:s")
        end
      end

      context "DText autocomplete" do
        setup do
          @user = create(:user, name: "oneuser")
          signin @user
          create(:tag, name: "1girl", post_count: 42)

          visit new_forum_topic_path
          @selector = "#new_forum_topic textarea.dtext"
        end

        should "work for tags" do
          assert_clicked_autocomplete_equals("[[1girl]] ", "[[1g", selector: @selector)
        end

        should "work for mentions" do
          assert_autocomplete_results(["@oneuser"], "@o", selector: @selector)
          assert_autocomplete_results(["@oneuser"], "@oneuser", selector: @selector)
          assert_autocomplete_results(["@oneuser"], "@ONEUSER", selector: @selector)
          assert_autocomplete_results(["@oneuser"], "one two @oneuser", selector: @selector)
        end

        should "work for searches" do
          create(:tag, name: "solo", post_count: 43)
          assert_clicked_autocomplete_equals("{{1girl solo}} ", "{{1girl so", selector: @selector)
        end

        should "work for emojis" do
          assert_clicked_autocomplete_equals(":smile: ", ":smi", selector: @selector)
        end

        should "preserve tag prefixes when a completion is inserted" do
          assert_clicked_autocomplete_equals("{{1girl}} ", "{{1gi", selector: @selector)
          assert_clicked_autocomplete_equals("{{-1girl}} ", "{{-1gi", selector: @selector)
          assert_clicked_autocomplete_equals("{{~1girl}} ", "{{~1gi", selector: @selector)
        end
      end
    end
  end
end

class AutocompleteChromeTest < ChromeSystemTestCase
  include AutocompleteTests
end

class AutocompleteFirefoxTest < FirefoxSystemTestCase
  include AutocompleteTests
end

class AutocompleteWebkitTest < WebkitSystemTestCase
  include AutocompleteTests
end
