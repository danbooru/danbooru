require "application_system_test_case"

module AutocompleteTests
  extend ActiveSupport::Concern

  def autocomplete(id, keys)
    fill_in id: id, with: ""
    find_by_id(id).send_keys(keys)
  end

  def assert_autocomplete_equals(expected_results, text, id:)
    autocomplete(id, text)
    sleep 1 if expected_results.empty?

    assert_selector "ul.ui-autocomplete li", count: expected_results.size
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
    visit new_forum_post_path(topic_id: create(:forum_topic).id) unless current_path == new_forum_post_path
    assert_autocomplete_equals(values, text, id: "forum_post_body")
  end

  def assert_inserted_completion(result, query, id: "tags")
    autocomplete(id, query)
    click_first_autocomplete_result
    assert_equal(result, find_field(id: id).value)
  end

  # The dropdown can be re-rendered mid-click if an earlier (slower) autocomplete request resolves after
  # a later (faster) one, detaching the <li> we already grabbed ("Element is not attached to the DOM").
  # Capybara-playwright's driver-level stale-element retry doesn't cover Node#click, so retry it here.
  def click_first_autocomplete_result(attempts: 3)
    first("ul.ui-autocomplete li").click
  rescue Playwright::Error => e
    raise unless e.message.include?("Element is not attached to the DOM") && attempts > 1

    click_first_autocomplete_result(attempts: attempts - 1)
  end

  included do
    context "#{browser_name}:" do
      context "Post Search autocomplete" do
        should "work for static metatags" do
          assert_metatag_autocomplete_equals(%w[any none] + AutocompleteService::POST_STATUSES, "child")
          assert_metatag_autocomplete_equals(%w[any none] + AutocompleteService::POST_STATUSES, "parent")
          assert_metatag_autocomplete_equals(Post::RATINGS.values.map(&:downcase), "rating")
          assert_metatag_autocomplete_equals(MediaAsset::FILE_TYPES, "filetype")
          assert_metatag_autocomplete_equals(%w[any] + AutocompleteService::POST_STATUSES, "status")
          assert_metatag_autocomplete_equals(PostDisapproval::REASONS, "disapproved")
        end

        should "work for username metatags" do
          %w[user approver commenter comm noter noteupdater artcomm upvote downvote fav ordvote ordfav appealer flagger].each do |metatag|
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

          assert_search_autocomplete_equals(["rating:sensitive"], "--rating:s")
          assert_search_autocomplete_equals(["rating:sensitive"], "-~rating:s")
          assert_search_autocomplete_equals(["rating:sensitive"], "~-rating:s")
          assert_search_autocomplete_equals(["rating:sensitive"], "~~rating:s")
          assert_search_autocomplete_equals(["rating:sensitive"], "---rating:s")
          assert_search_autocomplete_equals(["rating:sensitive"], "~~~rating:s")
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

          assert_inserted_completion("rating:sensitive ", "rating:s")
          assert_inserted_completion("-rating:sensitive ", "-rating:s")
          assert_inserted_completion("-rating:sensitive ", "---rating:s")
          assert_inserted_completion("tag rating:sensitive ", "tag rating:s")
        end
      end

      context "Username Autocomplete" do
        should "work" do
          signup "member1"

          assert_mention_autocomplete_equals(["@member1"], "@m")
          assert_mention_autocomplete_equals(["@member1"], "@member1")
          assert_mention_autocomplete_equals(["@member1"], "@MEMBER1")
          assert_mention_autocomplete_equals(["@member1"], "one two @member1")
        end
      end

      context "DText Autocomplete" do
        context "for search" do
          should "preserve tag prefixes when a completion is inserted" do
            signup "member1"
            create(:tag, name: "1girl", post_count: 42)
            visit new_forum_post_path(topic_id: create(:forum_topic).id)

            assert_inserted_completion("{{1girl}} ", "{{1gi", id: "forum_post_body")
            assert_inserted_completion("{{-1girl}} ", "{{-1gi", id: "forum_post_body")
            assert_inserted_completion("{{~1girl}} ", "{{~1gi", id: "forum_post_body")
          end
        end

        context "for wiki pages" do
          should "work" do
            signup "member1"
            create(:tag, name: "1girl", post_count: 42)
            visit new_forum_post_path(topic_id: create(:forum_topic).id)

            assert_autocomplete_equals(["1girl"], "[[1gi", id: "forum_post_body")
          end
        end

        context "for emojis" do
          should "work" do
            signup "member1"
            visit new_forum_post_path(topic_id: create(:forum_topic).id)

            assert_autocomplete_equals([":smile:"], ":smi", id: "forum_post_body")
          end
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
