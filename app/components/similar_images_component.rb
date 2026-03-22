# frozen_string_literal: true

# A component that displays the results of an IQDB reverse image search, showing high and low similarity post matches.
class SimilarImagesComponent < ApplicationComponent
  extend Memoist

  LOW_SIMILARITY_THRESHOLD = 0.0
  HIGH_SIMILARITY_THRESHOLD = 40.0
  DUPLICATE_THRESHOLD = 85.0

  attr_reader :matches, :current_user, :low_similarity, :high_similarity

  # @param matches [Array<Hash>] The matches returned by the IQDB search.
  # @param current_user [User] The current user.
  # @param low_similarity [Float, nil] The minimum score threshold to be considered a low similarity match.
  # @param high_similarity [Float, nil] The minimum score threshold to be considered a high similarity match.
  def initialize(matches:, current_user:, low_similarity: LOW_SIMILARITY_THRESHOLD, high_similarity: HIGH_SIMILARITY_THRESHOLD)
    super
    @matches = matches.map(&:with_indifferent_access)
    @low_similarity = low_similarity || LOW_SIMILARITY_THRESHOLD
    @high_similarity = high_similarity || HIGH_SIMILARITY_THRESHOLD
    @current_user = current_user
  end

  memoize def any_similarity_matches
    matches.select { |match| match[:score] >= low_similarity }
  end

  memoize def low_similarity_matches
    matches.select { |match| similarity_level(match) == :low }
  end

  memoize def high_similarity_matches
    matches.select { |match| similarity_level(match) == :high }
  end

  memoize def duplicates
    matches.select { |match| match[:score].in?(DUPLICATE_THRESHOLD..) }
  end

  def similarity_level(match)
    if match[:score] >= high_similarity
      :high
    elsif match[:score] >= low_similarity
      :low
    else
      :none
    end
  end
end
