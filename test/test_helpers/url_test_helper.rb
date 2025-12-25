module UrlTestHelper
  extend ActiveSupport::Concern
  # A helper class to automate all parsing checks for external urls

  class_methods do
    # Takes arbitrary input parameters, such as
    # should_identify_url_types(
    # profile_urls: [],
    # secondary_urls: []
    # )
    # Each url in each array is then matched with the corresponding method such as profile_url? and secondary_url?
    def should_identify_url_types(arguments = {})
      arguments.each do |url_type, urls|
        url_type = url_type.to_s.singularize
        urls.each do |url|
          should "correctly identify #{url} as a #{url_type.tr("_", " ")}" do
            assert Source::URL.public_send("#{url_type}?", url)
          end
        end
      end
    end

    # Works the same as the method above but with negative assert
    def should_not_find_false_positives(arguments = {})
      arguments.each do |url_type, false_positives|
        url_type = url_type.to_s.singularize
        false_positives.each do |false_positive|
          should "not wrongly identify #{false_positive} as a #{url_type.tr("_", " ")}" do
            assert_not Source::URL.public_send("#{url_type}?", false_positive)
          end
        end
      end
    end

    # Takes an url and arbitrary properties to match against it.
    # url_parser_should_work(image_url, page_url: page_url, full_image_url: full_image_url)
    def url_parser_should_work(url, attributes = {})
      url = Source::URL.parse(url)

      context "the parser #{url.class} for #{url}" do
        attributes.each do |attribute, expected_value|
          should "find the correct value for '#{attribute}'" do
            if expected_value.nil?
              assert_nil url.try(attribute)
            else
              assert_equal url.try(attribute), expected_value
            end
          end
        end
      end
    end
  end
end
