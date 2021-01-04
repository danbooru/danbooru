class TagAlias < TagRelationship
  validates_uniqueness_of :antecedent_name, scope: :status, conditions: -> { active }
  validate :absence_of_transitive_relation

  before_create :delete_conflicting_alias

  def self.to_aliased(names)
    names = Array(names).map(&:to_s)
    return [] if names.empty?

    aliases = active.where(antecedent_name: names).map { |ta| [ta.antecedent_name, ta.consequent_name] }.to_h

    abbreviations = names.select { |name| name.starts_with?("/") && !aliases.has_key?(name) }
    abbreviations.each do |abbrev|
      tag = Tag.nonempty.find_by_abbreviation(abbrev)
      aliases[abbrev] = tag.name if tag.present?
    end

    names.map { |name| aliases[name] || name }
  end

  def process!
    TagMover.new(antecedent_name, consequent_name, user: User.system).move!
  end

  # We don't want a -> b && b -> c chains if the b -> c alias was created
  # first. If the a -> b alias was created first, the new one will be allowed
  # and the old one will be moved automatically instead.
  def absence_of_transitive_relation
    return if is_rejected?

    tag_alias = TagAlias.active.find_by(antecedent_name: consequent_name)
    if tag_alias.present? && tag_alias.consequent_name != antecedent_name
      errors.add(:base, "#{tag_alias.antecedent_name} is already aliased to #{tag_alias.consequent_name}")
    end
  end

  # Allow aliases to be reversed. If A -> B already exists, but we're trying to
  # create B -> A, then automatically delete A -> B so we can make B -> A.
  def delete_conflicting_alias
    tag_alias = TagAlias.active.find_by(antecedent_name: consequent_name, consequent_name: antecedent_name)
    tag_alias.reject! if tag_alias.present?
  end
end
