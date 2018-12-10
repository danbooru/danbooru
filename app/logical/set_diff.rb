class SetDiff
  attr_reader :additions, :removals, :added, :removed, :obsolete_added, :obsolete_removed, :changed, :unchanged

  def initialize(new, old, latest)
    new, old, latest = new.to_a, old.to_a, latest.to_a

    @additions = new - old
    @removals = old - new
    @unchanged = new & old
    @obsolete_added = additions - latest
    @obsolete_removed = removals & latest
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

  def find_similar(string, candidates, max_dissimilarity: 0.75)
    distance = ->(other) { DidYouMean::Levenshtein.distance(string, other) }
    max_distance = string.size * max_dissimilarity

    candidates.select { |candidate| distance[candidate] <= max_distance }.sort_by(&distance).first
  end
end
