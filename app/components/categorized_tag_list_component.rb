# frozen_string_literal: true

# A vertical tag list, with tags split into categories. Used in app/views/posts/show.html.erb.
class CategorizedTagListComponent < TagListComponent
  NESTABLE_TAG_CATEGORIES = %w[copyright character meta]

  def implications
    @implications ||= TagImplication.active.where(antecedent_name: tags.map(&:name)).to_a
  end

  def antecedent_names
    @antecedent_names ||= implications.to_set(&:antecedent_name)
  end

  # @return [Hash<String, Array<Tag>>] A hash from each tag name to the list of tags that imply it.
  def subtags_by_name
    @subtags_by_name ||= begin
      consequents_by_antecedent = implications.group_by(&:antecedent_name)
      tags.flat_map { |t| consequents_by_antecedent.fetch(t.name, []).map { |ti| [ti.consequent_name, t] } }.group_by(&:first).transform_values { |pairs| pairs.map(&:second) }
    end
  end

  # Given a list of tags, build a list of nested tags, with the tags nested according to their implication hierarchy.
  #
  # @return An array of tag trees. Each tag tree is an array, where the first element is the parent tag, and the second
  #   element is an optional tree of subtags. An empty array denotes an empty subtree.
  def tag_tree(tag_list = tags)
    # Ignore subtags (tags that imply another tag) at the top level, since they will be included beneath their parent tag.
    tag_list.reject { |tag| tag.name.in?(antecedent_names) }.map { |tag| [tag, subtree(tag)] }
  end

  # @return The tree of tags that imply the given tag.
  def subtree(tag)
    subtags_by_name.fetch(tag.name, []).map { |subtag| [subtag, subtree(subtag)] }
  end
end
