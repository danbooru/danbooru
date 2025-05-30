# Extractor Tests

This directory contains the tests for extractors of external urls.

The following method is defined under test/test_helpers/extractor_test_helper.rb:

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

This method takes dynamic argument matching the ones available on `Source::Extractor`.

To generate a new test case for a given url you can copy paste the output of the following command into the strategy's test file:

```

puts Source::Extractor.find("https://my.url").test_case

```

You can also visit your local instance at `http://your-instance-url/source?mode=test&url=your-url` to see this test case:
for example, if you are using the default GitHub codespace, and you wanted to generate the test case for https://www.pixiv.net/en/artworks/12345678, you would visit http://127.0.0.1:3000/source?mode=test&url=https://www.pixiv.net/en/artworks/12345678.
