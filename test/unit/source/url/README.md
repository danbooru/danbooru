# Url Tests

This directory contains the tests for parsers of external urls.

The following methods are defined under test/test_helpers/extractor_test_helper.rb:

```ruby
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
```

These two methods support any boolean method provided by `Source::URL`. For example, to test for `.bad_source?` you would write:

```ruby
      should_identify_url_types(
        bad_sources: [
           # true bad sources
        ]
      )

      should_not_find_false_positives(
        bad_sources: [
           # false bad sources
        ]
      )
```



An additional method that dynamically matches arbitrary arguments for `Source::URL` is also provided:
```ruby
      url_parser_should_work("https://my.url/artist/post/image_id",
                             page_url: "https://my.url/artist/post",)
```
