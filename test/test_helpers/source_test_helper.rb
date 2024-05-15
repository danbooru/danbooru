module SourceTestHelper
  extend ActiveSupport::Concern

  # A helper method to automate all the checks needed to make sure that a strategy does not break.
  #
  # * If media_files is present, then it tests that the downloaded files have the given attributes.
  # * If deleted is true, it skips the downloading check, but it still tries everything else and makes sure nothing breaks.
  # * Any passed kwargs parameter is tested against the strategy.

  class_methods do
    def strategy_should_work(url, arguments = {})
      # XXX: can't use **kwargs because of a bug with shoulda-context
      referer = arguments.delete(:referer)
      deleted = arguments.delete(:deleted)
      media_files = arguments.delete(:media_files)
      options = arguments.delete(:options).to_h

      should "work" do
        strategy = Source::Extractor.find(url, referer, **options)

        assert_nothing_raised { strategy.to_h }

        assert_equal(Array, strategy.image_urls.class, "image_urls should be an Array")
        assert_not(strategy.image_urls.include?(nil), "image_urls should not contain nil")
        assert(strategy.image_urls.all?(String), "image_urls should contain only strings")

        if media_files.present?
          files = strategy.image_urls.map { |image_url| strategy.download_file!(image_url) }

          assert_equal(media_files.size, files.size, "expected #{media_files.size} images; got #{files.size}")

          media_files.zip(files).each do |expected_file_attributes, actual_file|
            expected_file_attributes.each do |attribute, expected_value|
              actual_value = actual_file.send(attribute)
              assert_equal(expected_value, actual_value, "expected #{attribute} to be #{expected_value}; got #{actual_value}")
            end
          end
        end

        if arguments.include?(:profile_url)
          profile_url = arguments.delete(:profile_url)
          should_handle_artists_correctly(strategy, profile_url)
        end

        if arguments.include?(:tags)
          tags = arguments.delete(:tags)
          should_validate_tags(strategy, tags)
        end

        if arguments.include?(:translated_tags)
          translated_tags = arguments.delete(:translated_tags)
          assert_equal(translated_tags.sort, strategy.translated_tags.map(&:name).sort)
        end

        should_match_source_data(strategy, arguments)
      end
    end
  end

  def should_handle_artists_correctly(strategy, profile_url)
    if profile_url.present?
      artist = create(:artist, name: strategy.tag_name || SecureRandom.uuid, url_string: profile_url)
      assert_equal(profile_url, strategy.profile_url)
      assert_equal([artist], strategy.artists.to_a, "should find the artist with the same profile url")
    end
  end

  def should_validate_tags(strategy, tags = nil)
    assert_equal(Array, strategy.tags.class, "tags should be an Array")
    assert(strategy.tags.all?(Array), "tags should be an Array of Arrays")

    return unless tags.present?

    if tags&.first.instance_of?(Array)
      assert_equal(tags.sort, strategy.tags.sort)
    elsif tags&.first.instance_of?(String)
      assert_equal(tags.map(&:downcase).sort, strategy.tags.map(&:first).map(&:downcase).sort)
    end
  end

  def should_match_source_data(strategy, methods_to_test)
    # check any method that is passed as kwargs, in order to hardcode as few things as possible
    # XXX can't use **kwargs because of a bug with shoulda-context, so we're using a hash temporarily
    methods_to_test.each do |method_name, expected_value|
      actual_value = strategy.public_send(method_name)

      if expected_value.is_a?(Regexp)
        assert_match(expected_value, actual_value, "#{method_name}: #{expected_value} should match #{actual_value}")
      elsif expected_value.is_a?(Array) && expected_value.grep(Regexp).any?
        expected_value.zip(actual_value).each do |expected, actual|
          assert_match(expected, actual)
        end
      elsif expected_value.is_a?(Array)
        assert_equal(expected_value.sort, actual_value.sort, "#{method_name}: #{expected_value} should match #{actual_value}")
      elsif expected_value.nil?
        assert_nil(actual_value, "#{method_name}: #{actual_value} should be nil")
      else
        assert_equal(expected_value, actual_value, "#{method_name}: #{expected_value} should match #{actual_value}")
      end
    end
  end
end
