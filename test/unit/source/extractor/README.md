# Extractor Tests

This directory contains the tests for extractors of external urls.

The following method is defined under test/test_helpers/extractor_test_helper.rb:

```ruby
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
```

This method takes dynamic argument matching the ones available on Source::Extractor.

To generate a new test case for a given url you can copy paste the output of the following command into the strategy's test file:

```

puts Source::Extractor.find("https://my.url").test_case

```
