module UrlTestHelper
  extend ActiveSupport::Concern
  # An abstract class to automate all parsing checks for external urls

  class_methods do
    def should_recognize_image_urls(*image_urls)
      image_urls.each do |image_url|
        context image_url do
          should "be parsed as an image url" do
            assert(Source::URL.image_url?(image_url))
          end
        end
      end
    end

    def should_recognize_profile_urls(*profile_urls)
      profile_urls.each do |profile_url|
        context profile_url do
          should "be parsed as a profile url" do
            assert(Source::URL.profile_url?(profile_url))
          end
        end
      end
    end

    def should_recognize_page_urls(*page_urls)
      page_urls.each do |page_url|
        context page_url do
          should "be parsed as a page url" do
            assert(Source::URL.page_url?(page_url))
          end
        end
      end
    end

    def should_extract_from_url(url, **attributes)
      setup do
        url = Source::URL.parse(url)
      end

      context url do
        attributes.each do |attribute, expected_value|
          should "find the correct value for '#{attribute}'" do
            assert_equal url.public_send(attribute), expected_value
          end
        end
      end
    end
  end
end
