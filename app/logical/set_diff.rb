# frozen_string_literal: true

# Calculate a diff between two sets of strings. Used to calculate diffs between
# artist URLs and between other names. Tries to compare each set to detect which
# strings were added, which were removed, and which were changed.
class SetDiff
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
    changed = []

    removed.each do |removal|
      if addition = find_similar(removal, added)
        changed << [removal, addition]
        added -= [addition]
        removed -= [removal]
      end
    end

    [added, removed, changed]
  end

  # Finds the strings most similar to the `candidate` string among the `candidates` set.
  # @param string [String] the string to find closest matches with in the `candidates` set.
  # @param candidates [Array<String>] the set of candidate strings
  def find_similar(string, candidates, max_dissimilarity: 0.70)
    distance = ->(other) { ::DidYouMean::Levenshtein.distance(string, other) }
    max_distance = string.size * max_dissimilarity

    candidates.select { |candidate| distance[candidate] <= max_distance }.min_by(&distance)
  end
end
