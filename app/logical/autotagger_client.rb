# frozen_string_literal: true

# API client for the Danbooru Autotagger service. Used for the AI tagging feature.
#
# @see https://autotagger.donmai.us
# @see https://github.com/danbooru/autotagger
class AutotaggerClient
  attr_reader :autotagger_url, :http

  def initialize(autotagger_url: Danbooru.config.autotagger_url.to_s, http: Danbooru::Http.internal)
    @autotagger_url = autotagger_url.chomp("/")
    @http = http
  end

  def evaluate(file, limit: 50, confidence: 0.01)
    return {} if autotagger_url.blank?

    response = http.post("#{autotagger_url}/evaluate", form: { file: HTTP::FormData::File.new(file), threshold: confidence, format: "json" })
    return {} if !response.status.success?

    tag_names_with_scores = response.parse.first["tags"]
    tags = Tag.where(name: tag_names_with_scores.keys).index_by(&:name)
    bad_tags = []

    if tags.size < tag_names_with_scores.size
      # The autotagger gave us tags we aren't aware of
      missing_tags = tag_names_with_scores.keys - tags.keys
      missing_tags.each do |tag_name|
        new_tag = Tag.create(name: tag_name)
        if new_tag.errors.any? then
          # If we fail to create a tag for any reason (such as an invalid tag name), we silently drop it
          bad_tags << tag_name
        end
      end
      Tag.uncached do
        tags = Tag.where(name: tag_names_with_scores.keys).index_by(&:name)
      end
    end

    tag_names_with_scores.reject { |tag, score| bad_tags.include?(tag) }.transform_keys(&tags)
  end
end
