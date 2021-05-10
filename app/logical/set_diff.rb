class SetDiff
  attr_reader :additions, :removals, :added, :removed, :changed, :unchanged

  def initialize(this_list, other_list)
    this, other = this_list.to_a, other_list.to_a

    @additions = this - other
    @removals = other - this
    @unchanged = this & other
    @added, @removed, @changed = changes(additions, removals)
  end

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

  def find_similar(string, candidates, max_dissimilarity: 0.70)
    distance = ->(other) { ::DidYouMean::Levenshtein.distance(string, other) }
    max_distance = string.size * max_dissimilarity

    candidates.select { |candidate| distance[candidate] <= max_distance }.min_by(&distance)
  end
end
