module UrlTestHelper
  extend ActiveSupport::Concern
  # An abstract class to automate all parsing checks for external urls

  class_methods do
    def should_recognize_image_urls(*image_urls)
      image_urls.each do |image_url|
        should "identify #{image_url} as an image url" do
          assert(Source::URL.image_url?(image_url))
        end
      end
    end

    def should_recognize_profile_urls(*profile_urls)
      profile_urls.each do |profile_url|
        should "identify #{profile_url} as a profile url" do
          assert(Source::URL.profile_url?(profile_url))
        end
      end
    end

    def should_recognize_page_urls(*page_urls)
      page_urls.each do |page_url|
        should "identify #{page_url} as a page url" do
          assert(Source::URL.page_url?(page_url))
        end
      end
    end

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

    def url_parser_should_work(url, attributes = {})
      url = Source::URL.parse(url)

      context url do
        attributes.each do |attribute, expected_value|
          should "find the correct value for '#{attribute}'" do
            if expected_value.nil?
              assert_nil url.public_send(attribute)
            else
              assert_equal url.public_send(attribute), expected_value
            end
          end
        end
      end
    end
  end
end
