# frozen_string_literal: true

# A custom Shoulda matcher for testing Source::URL.parse behavior.
#
# Usage:
#
#   should parse_url("https://www.pixiv.net/artworks/46324488").as(:page_url?)
#   should parse_url("https://www.pixiv.net/artworks/46324488").into(illust_id: "46324488")
#
#   should be_page_url("https://www.pixiv.net/artworks/46324488") # shorthand for `should parse_url(...).as(:page_url?)`
#   should be_image_url("https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png")
#   should be_image_sample("https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg")
#   should be_profile_url("https://www.pixiv.net/en/users/9202877")
#   should_not be_image_sample("https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png")
#
# The above are equivalent to:
#
#   should "parse https://www.pixiv.net/artworks/46324488 into page_url? = true" do
#     assert_equal(true, Source::URL.parse("https://www.pixiv.net/artworks/46324488").page_url?)
#   end
#
#   should "parse https://www.pixiv.net/artworks/46324488 into illust_id = 46324488" do
#     assert_equal("46324488", Source::URL.parse("https://www.pixiv.net/artworks/46324488").illust_id)
#   end

module UrlTestHelper
  extend ActiveSupport::Concern

  class_methods do
    # @param urls [Array<String>] The URL(s) to test.
    # @return [ParseUrlMatcher] A matcher that is used with `should` to test that the given URL(s) have the expected attributes.
    def parse_url(*urls)
      subject { urls }

      callsite = caller_locations(3, 1).first
      source_location = "#{callsite.path}:#{callsite.lineno}"
      ParseUrlMatcher.new(urls, source_location:)
    end

    # @return [ParseUrlMatcher] A matcher that asserts that all the given URLs are image URLs.
    def be_image_url(*urls) = parse_url(*urls).as(:image_url?)

    # @return [ParseUrlMatcher] A matcher that asserts that all the given URLs are page URLs.
    def be_page_url(*urls) = parse_url(*urls).as(:page_url?)

    # @return [ParseUrlMatcher] A matcher that asserts that all the given URLs are profile URLs.
    def be_profile_url(*urls) = parse_url(*urls).as(:profile_url?)

    # @return [ParseUrlMatcher] A matcher that asserts that all the given URLs are image sample URLs.
    def be_image_sample(*urls) = parse_url(*urls).as(:image_sample?)

    # @return [ParseUrlMatcher] A matcher that asserts that all the given URLs are bad source URLs.
    def be_bad_source(*urls) = parse_url(*urls).as(:bad_source?)

    # @return [ParseUrlMatcher] A matcher that asserts that all the given URLs are bad links.
    def be_bad_link(*urls) = parse_url(*urls).as(:bad_link?)

    # @return [ParseUrlMatcher] A matcher that asserts that all the given URLs are secondary profile URLs.
    def be_secondary_url(*urls) = parse_url(*urls).as(:secondary_url?)
  end

  class ParseUrlMatcher
    attr_reader :urls, :parsed_urls, :expected_attributes, :errors, :source_location

    # @param urls [Array<String>] The URL(s) under test.
    # @param source_location [String] The file name and line number of the test.
    def initialize(urls, source_location: nil)
      @urls = urls
      @source_location = source_location
      @parsed_urls = urls.map { |url| Source::URL.parse(url) }
      @expected_attributes = {}
      @errors = []
    end

    # @param predicate [Symbol] The name of a method on the URL that is expected to return true (e.g. `:image_url?`, `:profile_url?`, etc)
    # @return [ParseUrlMatcher] A matcher that asserts that the predicate returns true for the tested URLs.
    def as(predicate)
      into(predicate => true)
    end

    # @param expected_attributes [Hash<Symbol, String>] The attributes the parsed URL(s) are expected to have.
    # @return [ParseUrlMatcher] A matcher that asserts that the tested URLs have the expected attributes.
    def into(expected_attributes)
      @expected_attributes = expected_attributes.deep_merge(expected_attributes)
      self
    end

    # Called by Shoulda to perform the test.
    # @param _subject [Class] The value of the `subject` block.
    # @return [Boolean] Whether the test passed.
    def matches?(_subject)
      parsed_urls.each do |parsed_url|
        if parsed_url.nil?
          @errors << "`#{parsed_url}` to parse"
          next
        end

        expected_attributes.each do |attribute, expected_value|
          actual_value = parsed_url.try(attribute)
          next if actual_value == expected_value

          @errors << "`Source::URL.parse('#{parsed_url}').#{attribute}` to be `#{expected_value.inspect}` not `#{actual_value.inspect}` at #{source_location}"
        end
      end

      @errors.blank?
    end

    # @return [Class] The class of the URLs under test.
    def described_type
      parsed_urls.map(&:class).uniq.sole
    end

    # @return [String] The name of the test case. Must be unique.
    def description
      description = "parse `#{urls.to_sentence}`"
      description += " into #{expected_attributes.map { |k, v| "#{k} = #{v}" }.to_sentence}" if expected_attributes.present?

      description
    end

    # @return [String] The error message if the tests fail in a `should` call
    def failure_message
      errors.map { "expected #{it}" }.join("\n")
    end

    # @return [String] The error message if the tests fail in a `should_not` call.
    def failure_message_when_negated
      errors.map { "didn't expect #{it}" }.join("\n")
    end
  end
end
