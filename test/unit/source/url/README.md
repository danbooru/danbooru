# URL Tests

This directory contains the tests for Source::URL parsers. When adding a new URL parser, you should add tests for it here.

## URL type matchers

Use `be_image_url`, `be_page_url`, `be_profile_url`, `be_image_sample`, `be_bad_source`, and `be_bad_link` to assert
that one or more URLs are of a given type:

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

## Attribute matchers

Use `parse_url(...).into(...)` to assert that a URL parses to expected attribute values, or
`parse_url(...).as(:predicate?)` to assert a boolean predicate is true:

```ruby
should parse_url("https://www.pixiv.net/artworks/46324488").into(
  work_id: "46324488",
  page_url: "https://www.pixiv.net/artworks/46324488",
)

should parse_url("https://www.pixiv.net/artworks/46324488").as(:page_url?)
```

## Coverage

To make sure every case is covered, run `COVERAGE=1 bin/rails test test/unit/source/url` and open
`tmp/coverage/index.html`. Go to the Extractors section to find the URL tests.

You can also use the SimpleCov extension in VS Code to see line coverage in your editor.

## Shoulda

`parse_url`, `be_image_url`, `be_page_url`, `be_profile_url`, `be_image_sample`, `be_bad_source`, and `be_bad_link` are
custom Shoulda matchers defined in `test/test_helpers/url_test_helper.rb`.

`should`, `should_not`, and `should_eventually` come from the `shoulda-matchers` gem. See the links below.

* [Shoulda-context Github](https://github.com/thoughtbot/shoulda-context)
* [Shoulda-matchers Github](https://matchers.shoulda.io/docs/)
* [Shoulda-matchers Documentation](https://matchers.shoulda.io/docs/)
