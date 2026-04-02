# Source Tests

This directory contains the tests for the extractors and URL parsers defined in [app/logical/source](../../../app/logical/source).

## URL Tests

### URL type matchers

Use `be_image_url`, `be_page_url`, `be_profile_url`, `be_image_sample`, `be_bad_source`, and `be_bad_link` to assert that one or more URLs are of a given type:

```ruby
should be_image_url(
  "https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png"
)

should be_page_url(
  "https://www.pixiv.net/en/artworks/46324488",
  "https://www.pixiv.net/artworks/46324488",
)

should be_profile_url(
  "https://www.pixiv.net/users/9202877"
)

should_not be_image_sample(
  "https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png"
)
```

### Attribute matchers

Use `parse_url(...).into(...)` to assert that a URL parses to expected attribute values, or `parse_url(...).as(:predicate?)` to assert a boolean predicate is true:

```ruby
should parse_url("https://www.pixiv.net/artworks/46324488").into(
  work_id: "46324488",
  page_url: "https://www.pixiv.net/artworks/46324488",
)

should parse_url("https://www.pixiv.net/artworks/46324488").as(:page_url?)
```

## Extractor Tests

Use `strategy_should_work` to assert that a given URL extracts the correct values for all methods:

```ruby
  context "a post you want to test" do
    strategy_should_work(
      "https://site.name/artist/post_id",
      image_urls: ["https://site.name/artist/post_id/image_id"],
      profile_url: "https://site.name/artist",
      page_url: "https://site.name/artist/post_id",
      display_name: "artist",
      username: "artist",
      other_names: ["artist"],
      tags: ["tag1", "tag2"],
      artist_commentary_title: "title",
      artist_commentary_desc: "desc",
    )
  end
```

To generate a test case for a given URL, use `bin/rails console` and run the following command:

```ruby
puts Source::Extractor.find("https://example.com/posts/1234").test_case
```

You can also visit your local instance at http://localhost:3000/source to generate test cases. For example, to generate a test case for https://www.pixiv.net/en/artworks/12345678, you would visit http://localhost:3000/source?mode=test&url=https://www.pixiv.net/en/artworks/12345678.

## Coverage

To make sure every case is covered, run `COVERAGE=1 bin/rails test test/unit/source/` and open `tmp/coverage/index.html`. Go to the Extractors section to find the URL and extractor tests.

You can also use the SimpleCov extension in VS Code to see line coverage in your editor.

When writing URL tests, be sure to cover the following cases:

* Sample image URLs
* Full-size image URLs
* Other image URLs (profile banners, profile backgrounds, etc)
* Page URLs
* Profile URLs
* Bad links
* Legacy URL formats (use `/artist_urls` and `source:` searches to find these)
* Unhandled URL formats (help pages, etc)

When writing extractor tests, be sure to cover the following cases (where applicable):

* Sample images
* Full-size images
* Posts with a single image
* Posts with multiple images
* Posts with no images
* Posts with videos
* Posts that are replies to or reposts of another post.
* Posts that require authentication to view
* Complex commentaries that utilize all the features of the site's formatting language.
* Deleted posts
* Non-existent or invalid post IDs
* Followers-only or restricted posts

## Shoulda

`parse_url`, `be_image_url`, `be_page_url`, `be_profile_url`, `be_image_sample`, `be_bad_source`, and `be_bad_link` are custom Shoulda matchers defined in [test/test_helpers/url_test_helper.rb](../../test_helpers/url_test_helper.rb). `strategy_should_work` is defined in [test/test_helpers/extractor_test_helper.rb](../../test_helpers/extractor_test_helper.rb).

`should`, `should_not`, and `should_eventually` come from the `shoulda-matchers` gem. See the links below.

## External links

* [Shoulda-context Github](https://github.com/thoughtbot/shoulda-context)
* [Shoulda-matchers Github](https://matchers.shoulda.io/docs/)
* [Shoulda-matchers Documentation](https://matchers.shoulda.io/docs/)
