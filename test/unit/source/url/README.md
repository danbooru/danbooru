# Url Tests

This directory contains the tests for parsers of external urls.

The following methods are defined under test/test_helpers/extractor_test_helper.rb:

```ruby
  context "a bunch of urls you want to test parsing for" do
      should_identify_url_types(
        image_urls: [
          # list your image urls here
        ],
        page_urls: [
          # list your page urls here
        ],
        profile_urls: [
          # list your profile urls here
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          # list urls that should not be misidentified
        ],
      )
    end
  end
```


An additional method that dynamically matches arbitrary arguments for `Source::URL` is also provided:
```ruby
  context "An url you want to test parsing of attributes for" do
      url_parser_should_work(
        "https://my.url/my_artist/post/abcdefg/image/0",
        page_url: "https://my.url/artist/post",
        artist_name: "my_artist",
        post_id: "abcdefg",
        image_id: 0,
      )
  end
```
