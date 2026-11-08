# frozen_string_literal: true

# Calculate a diff between two sets of strings. Used to calculate diffs between
# artist URLs and between other names. Tries to compare each set to detect which
# strings were added, which were removed, and which were changed.
class SetDiff
  # Skip fuzzy matching when the total number of character comparisons would be greater than this, because
  # computing the edit distance between every pair of strings is too slow for large diffs.
  MAX_FUZZY_MATCH_COST = 2_000_000

  attr_reader :additions, :removals, :added, :removed, :changed, :unchanged

  # Initialize a diff between two sets of strings.
  # @param this_list [Array<String>] the new list of strings
  # @param other_list [Array<String>] the old list of strings
  def initialize(this_list, other_list)
    this, other = this_list.to_a, other_list.to_a

    @additions = this - other
    @removals = other - this
    @unchanged = this & other
    @added, @removed, @changed = changes(additions, removals)
  end

  # Returns the strings that were either completely newly added, completely
  # removed, or simply updated.
  # @param added [Array<String>] the strings that were added to this_list
  # @param removed [Array<String>] the strings that were removed from other_list
  # @return [Array<(Array<String>, Array<String>, Array<String>)>] the list of
  #   additions, removals, and changed strings.
  def changes(added, removed)
    return [added, removed, []] if added.sum(&:size) * removed.sum(&:size) > MAX_FUZZY_MATCH_COST

    changed = removed.reduce([]) do |pairs, removal|
      addition = find_similar(removal, added - pairs.map(&:second))
      addition ? pairs + [[removal, addition]] : pairs
    end

    [added - changed.map(&:second), removed - changed.map(&:first), changed]
  end

  # Finds the strings most similar to the `candidate` string among the `candidates` set.
  # @param string [String] the string to find closest matches with in the `candidates` set.
  # @param candidates [Array<String>] the set of candidate strings
  def find_similar(string, candidates, max_dissimilarity: 0.70)
    max_distance = string.size * max_dissimilarity

    # The edit distance is at least the difference in length, so skip candidates that can never match.
    candidates
      .reject { |candidate| (candidate.size - string.size).abs > max_distance }
      .map { |candidate| [candidate, ::DidYouMean::Levenshtein.distance(string, candidate)] }
      .select { |_candidate, distance| distance <= max_distance }
      .min_by(&:second)
      &.first
  end
end
