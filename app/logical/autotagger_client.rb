# frozen_string_literal: true

# API client for the Danbooru Autotagger service. Used for the AI tagging feature.
#
# @see https://autotagger.donmai.us
# @see https://github.com/danbooru/autotagger
class AutotaggerClient
  class Error < StandardError; end

  attr_reader :autotagger_url, :http

  def initialize(autotagger_url: Danbooru.config.autotagger_url.to_s, http: Danbooru::Http.internal)
    @autotagger_url = autotagger_url.chomp("/")
    @http = http
  end

  # Get the AI tags for an image as a hash of (tag name, confidence) pairs. Returns nothing if the autotagger isn't
  # configured or if the API call fails.
  #
  # @param file [File] The image file.
  # @param limit [Integer] The maximum number of tags to return.
  # @param confidence [Float] The minimum confidence level for each tag.
  # @return [Hash<String, Float>] A hash of (tag name, confidence) pairs for this image. The confidence is a value from 0.0 to 1.0.
  def evaluate(file, limit: 50, confidence: 0.01)
    return {} if autotagger_url.blank?

    response = http.post("#{autotagger_url}/evaluate", form: { file: HTTP::FormData::File.new(file), threshold: confidence, format: "json" })
    return {} if !response.status.success?

    response.parse.first["tags"].with_indifferent_access
  end

  # Get the AI tags for an image as an array of AITags. Creates new tags if they don't already exist. Raises an error
  # if the API call fails.
  #
  # @param file [File] The image file.
  # @param limit [Integer] The maximum number of tags to return.
  # @param confidence [Float] The minimum confidence level for each tag.
  # @return [Array<AITag>] A list of new AI tags for this image. The `media_asset` field will be nil.
  def evaluate!(file, limit: 50, confidence: 0.01)
    return [] if autotagger_url.blank?

    response = http.post("#{autotagger_url}/evaluate", form: { file: HTTP::FormData::File.new(file), threshold: confidence, format: "json" })
    raise Error, "Autotagger failed (code #{response.code})" if !response.status.success?

    tag_names_with_scores = response.parse.first["tags"]
    tag_names = tag_names_with_scores.keys
    tags = Tag.where(name: tag_names).to_a

    missing_tags = tag_names - tags.pluck(:name)
    missing_tags.each do |name|
      tags << Tag.find_or_create_by_name(name, skip_name_validation: true)
    end

    tags.map do |tag|
      score = (100 * tag_names_with_scores[tag.name]).round
      AITag.new(tag: tag, score: score)
    end.sort_by(&:score)
  end
end
